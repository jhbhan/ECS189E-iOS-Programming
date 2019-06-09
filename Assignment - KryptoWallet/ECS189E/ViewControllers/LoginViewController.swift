//
//  ViewController.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 9/22/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorInfo: UILabel!
    
    let phoneNumberPrefix = "+1"
    var asYouTypeFormatter: NBAsYouTypeFormatter?
    var phoneNumber = String()
    var phoneNumberInFormat = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
        phoneNumber = Storage.phoneNumberInE164 ?? ""
        if phoneNumber != "" {
            
            // Removing +1
            phoneNumber =  String(phoneNumber[2...])
            phoneNumberInFormat = asYouTypeFormatter?.inputString(phoneNumber) ?? ""
            inputField.text = phoneNumberInFormat
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewInit()
    }

    func viewInit() {
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        errorInfo.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func nextOnTap(_ sender: UIButton) {
        self.view.endEditing(true)
        if let input = inputField.text {
            phoneNumber = input.filter { $0 >= "0" && $0 <= "9" }
            if phoneNumber.count == 0 {
                errorInfo.text = "Please enter your phone number."
                errorInfo.isHidden = false
            }
            else if phoneNumber.count != 10 {
                errorInfo.text = "Your phone number is invalid."
                errorInfo.isHidden = false
            } else {
                if let storageNum = Storage.phoneNumberInE164{
                    let prefixNumber = phoneNumberPrefix + phoneNumber
                    if storageNum == prefixNumber{
                    performSegue(withIdentifier: "loginToWallet", sender: self)
                    return
                    }
                    
                    else{
                        Api.sendVerificationCode(phoneNumber: phoneNumber) { response, error in
                            self.nextButton.setTitle("Next", for: .normal)
                            guard response != nil && error == nil else {
                                self.errorInfo.isHidden = false
                                self.errorInfo.text = error?.message
                                return
                            }
                            self.phoneNumberInFormat = input
                            self.performSegue(withIdentifier: "verifySMS", sender: self)
                        }
                    }
                }else{
                
                Api.sendVerificationCode(phoneNumber: phoneNumber) { response, error in
                    self.nextButton.setTitle("Next", for: .normal)
                    guard response != nil && error == nil else {
                        self.errorInfo.isHidden = false
                        self.errorInfo.text = error?.message
                        return
                    }
                    self.phoneNumberInFormat = input
                    self.performSegue(withIdentifier: "verifySMS", sender: self)
                }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifySMS" {
            let dest = segue.destination as! VerifyViewController
            dest.phoneNumber = phoneNumberPrefix + phoneNumber
            dest.phoneNumberInFormat = phoneNumberInFormat
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 {
            inputField.text = asYouTypeFormatter?.inputDigit(string)
        } else {
            inputField.text = asYouTypeFormatter?.removeLastDigit()
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        asYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
        return true
    }
    
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue){
    }
}

