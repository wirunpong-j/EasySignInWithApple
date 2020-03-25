//
//  ViewController.swift
//  EasySignInWithApple
//
//  Created by Wirunpong Jaingamlertwong on 23/3/2563 BE.
//  Copyright © 2563 Wirunpong Jaingamlertwong. All rights reserved.
//

import AuthenticationServices
import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        addObservable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performExistingAccountSetupFlows()
    }
    
    private func addObservable() {
        NotificationCenter.default.addObserver(self, selector: #selector(authCredentialStateDidChange), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }
    
    private func commonInit() {
        overrideUserInterfaceStyle = .dark
        let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        signInWithAppleButton.cornerRadius = 20
        signInWithAppleButton.addTarget(self, action: #selector(signInWithAppleDidTap), for: .touchUpInside)
        stackView.addArrangedSubview(signInWithAppleButton)
    }
    
    private func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func authCredentialStateDidChange() {
        let authProvider = ASAuthorizationAppleIDProvider()
        authProvider.getCredentialState(forUserID: KeychainItem.currentUserId) { [weak self] state, error in
            guard let self = self else { return }
            switch state {
            case .authorized:
                print("Status: authorized")
                
                DispatchQueue.main.async {
                    self.showMyProfilePage(userId: KeychainItem.currentUserId)
                }
            case .revoked:
                print("Status: revoked")
            case .notFound:
                print("Status: notFound")
            default:
                return
            }
        }
    }
    
    @objc private func signInWithAppleDidTap() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    private func showMyProfilePage(userId: String, email: String? = nil, fullName: PersonNameComponents? = nil) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyProfileViewController") as! MyProfileViewController
        viewController.user = User(userId: userId, email: email ?? "", fullName: "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
        present(viewController, animated: true)
    }
    
    private func saveUserIdInKeychain(userId: String) {
        do {
            try KeychainItem(service: "com.bellkung.EasySignInWithApplez", account: "userId").saveItem(userId)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.saveUserIdInKeychain(userId: appleIdCredential.user)
            self.showMyProfilePage(userId: appleIdCredential.user, email: appleIdCredential.email, fullName: appleIdCredential.fullName)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            print("passwordCredential: In")
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

