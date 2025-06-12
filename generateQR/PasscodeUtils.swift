//
//  PasscodeUtils.swift.swift
//  generateQR
//
//  Created by Honoka Nishiyama on 2025/06/11.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

func generatePasscodeIfNeeded(relationship: String, completion: @escaping (String?) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("❌ ユーザー未ログイン")
        completion(nil)
        return
    }

    let db = Firestore.firestore()
    let qrCollection = db.collection("qr_requests")

    qrCollection.whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
        if let error = error {
            print("❌ 取得エラー: \(error.localizedDescription)")
            completion(nil)
            return
        }

        let count = snapshot?.documents.count ?? 0
        if count >= 3 {
            completion(nil)
            return
        }

        let passcode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })

        db.collection("users").document(uid).getDocument { userSnapshot, error in
            guard let data = userSnapshot?.data(),
                  let name = data["fullName"] as? String,
                  let studentClass = data["studentClass"] as? String,
                  let studentNumber = data["studentNumber"] as? String else {
                completion(nil)
                return
            }

            let qrData: [String: Any] = [
                "uid": uid,
                "studentName": name,
                "studentClass": studentClass,
                "studentNumber": studentNumber,
                "relationship": relationship,
                "passcode": passcode,
                "timestamp": Timestamp()
            ]

            qrCollection.addDocument(data: qrData) { error in
                if let error = error {
                    print("❌ 保存エラー: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(passcode)
                }
            }
        }
    }
}

