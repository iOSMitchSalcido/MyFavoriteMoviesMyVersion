//
//  LoginViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/7/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // 
    let api = TMDBApi()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in

            // error test
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            else if appDelegate.userID != nil, let params = params {
                
                // if success retrieving useID, then last params passed in are TMDB Config dictionary
                // ..set in appDelegate
                appDelegate.config = params
                
                // invoke Genres tvc
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "GenresTableViewController") as! GenresTableViewController
                let nc = UINavigationController(rootViewController: controller)
                
                // re-enable login button..push Genres tvc
                DispatchQueue.main.async {
                    self.loginButton.isEnabled = true
                    self.present(nc, animated: true, completion: nil)
                }
                
                return nil
            }
            
            DispatchQueue.main.async {
                self.loginButton.isEnabled = true
            }
            
            return nil
        }

        if !(usernameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! {
            loginButton.isEnabled = false
            api.loginWithUserName(usernameTextField.text!, password: passwordTextField.text!, completion: completion)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
