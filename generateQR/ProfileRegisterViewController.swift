//
//  ProfileRegisterViewController.swift
//  generateQR
//
//  Created by Honoka Nishiyama on 2025/06/11.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileRegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var studentNumberTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    var userName: String?
    var email: String?
    var profileImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = userName
        if let urlString = profileImageURL, let url = URL(string: urlString) {
                    loadImage(from: url)
                }
        setupKeyboardDismissGesture()
    }

    func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // ボタンなどのタッチを妨げないように
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveProfileTapped(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ ユーザー未ログイン")
            return
        }

        guard let name = nameTextField.text,
              let grade = gradeTextField.text,
              let studentClass = classTextField.text,
              let studentNumber = studentNumberTextField.text,
              let email = email else {
            print("❌ フォーム未入力")
            return
        }

        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "fullName": name,
            "grade": grade,
            "studentClass": studentClass,
            "studentNumber": studentNumber,
            "email": email
        ]

        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("❌ Firestore保存失敗: \(error.localizedDescription)")
            } else {
                print("✅ プロフィール保存成功")

                // ホーム画面に遷移
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: true)
                }
            }
        }
    }
    
    func loadImage(from url: URL) {
            // 簡易的な画像読み込み（実際はキャッシュ処理推奨）
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
}
