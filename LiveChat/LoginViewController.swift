//
//  ViewController.swift
//  LiveChat
//
//  Created by robot on 15/4/9.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import UIKit
protocol LoginViewControllerDelegate{
    func loginViewControllerSucceeded(auth: LoginViewController)
}

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverURLField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var authenticationLabel: UILabel!
    
    var delegate:LoginViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: -- Custom Actions
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        showWaitUI()
        dismissViewControllerAnimated(true, completion: { () -> Void in
            let weakself = self
            let user = self.usernameField.text
            let password = self.passwordField.text
            let loginServer = self.serverURLField.text
            NSUserDefaults.standardUserDefaults().setValue(user, forKey: "userID")
            NSUserDefaults.standardUserDefaults().setValue(password, forKey: "userPassword")
            NSUserDefaults.standardUserDefaults().setValue(loginServer, forKey: "loginServer")
            NSUserDefaults.standardUserDefaults().synchronize()
        })
    }
    
    //MARK: -- Helpers
    func showWaitUI(){
        signInButton.hidden = true
        waitView.hidden = false
    }
    func hideWaitUI(){
        signInButton.hidden = false
        waitView.hidden = true
    }
    
    func checkTextFieldsForButtonState() {
        let usernameReady:Bool = usernameField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        let passwordReady:Bool = passwordField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        let serverURL = serverURLField.text
        
        let sitePattern = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let matcher = RegexHelper(sitePattern)
        let serverReady:Bool = matcher.match(serverURL)
        
        signInButton.enabled = usernameReady && passwordReady && serverReady
    }
}

extension LoginViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //checkTextFieldsForButtonState()
        return true
    }
}
