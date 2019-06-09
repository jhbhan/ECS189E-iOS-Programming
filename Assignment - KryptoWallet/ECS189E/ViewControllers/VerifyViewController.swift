//
//  LoginView2.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 9/23/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit
import Foundation

class VerifyViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var displayPhoneNumber: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorInfo: UILabel!
    
    var phoneNumber = String()
    var phoneNumberInFormat = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        displayPhoneNumber.text = phoneNumberInFormat
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
        guard let code = inputField.text else {
            self.errorInfo.text = "Please enter the code we sent you via SMS."
            self.errorInfo.textColor = UIColor.red
            self.errorInfo.isHidden = false
            return
        }
        
        Api.verifyCode(phoneNumber: phoneNumber, code: code) { response, error in
            
            guard response != nil, error == nil else {
                self.errorInfo.text = error?.message
                self.errorInfo.textColor = UIColor.red
                self.errorInfo.isHidden = false
                return
            }
            
            // Last Valid User Phone Number Stored
            Storage.phoneNumberInE164 = self.phoneNumber
            let authorizationToken = response?["auth_token"] as? String
            Storage.authToken = authorizationToken
            
            self.performSegue(withIdentifier: "verifyToWallet", sender: self)
            
            // Present Success Info
            self.errorInfo.text = "You are logged in!"
            self.errorInfo.textColor = UIColor.init(red: 0.0, green: 200/255, blue: 0.0, alpha: 1.0)
            self.errorInfo.isHidden = false
        }
    }
    
    @IBAction func resendOnTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
