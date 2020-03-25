//
//  MyProfileViewController.swift
//  EasySignInWithApple
//
//  Created by Wirunpong Jaingamlertwong on 23/3/2563 BE.
//  Copyright © 2563 Wirunpong Jaingamlertwong. All rights reserved.
//

import UIKit

final class MyProfileViewController: UIViewController {
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
    }
    
    private func commonInit() {
        overrideUserInterfaceStyle = .dark
        userIdLabel.text = "User Id: \(user.userId)"
        emailLabel.text = "Email: \(user.email)"
        nameLabel.text = "Full Name: \(user.fullName)"
    }
    
    @IBAction private func logoutDidTap(_ sender: UIButton) {
        KeychainItem.deleteUserIdFromKeychain()
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
