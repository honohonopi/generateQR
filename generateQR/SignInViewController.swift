//
//  SignInViewController.swift
//  generateQR
//
//  Created by Honoka Nishiyama on 2025/06/11.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signInButton = UIButton(type: .system)
        signInButton.setTitle("Sign in with Google", for: .normal)
        signInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        signInButton.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
        view.addSubview(signInButton)
    }
    
    @objc func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let googleUser = result?.user,
                  let idToken = googleUser.idToken?.tokenString else {
                print("No ID token")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: googleUser.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }

                let isNewUser = authResult?.additionalUserInfo?.isNewUser ?? false
                print(isNewUser ? "🆕 新規ユーザー" : "✅ 既存ユーザー")

                if isNewUser {
                    // Googleプロフィール情報を取得
                    let email = googleUser.profile?.email ?? ""
                    let name = googleUser.profile?.name ?? ""
                    let imageURL = googleUser.profile?.imageURL(withDimension: 100)?.absoluteString ?? ""

                    // ProfileRegisterViewControllerに渡す
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileRegisterViewController") as? ProfileRegisterViewController {
                        profileVC.userName = name
                        profileVC.email = email
                        profileVC.profileImageURL = imageURL
                        profileVC.modalPresentationStyle = .fullScreen
                        self?.present(profileVC, animated: true)
                    }
                } else {
                    // SignInViewController.swift のログイン成功時
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let nav = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
                        nav.modalPresentationStyle = .fullScreen
                        self?.present(nav, animated: true)
                    }
                }
            }
        }
    }
}
