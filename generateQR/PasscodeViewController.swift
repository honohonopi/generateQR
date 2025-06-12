//
//  GeneratePasscodeViewController.swift
//  generateQR
//
//  Created by Honoka Nishiyama on 2025/06/11.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PasscodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var passcodes: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchPasscodes()
        setupAddButton()
    }

    func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showPasscodeModal))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc func showPasscodeModal() {
        let modalVC = GeneratePasscodeModalViewController()
        modalVC.onPasscodesGenerated = { [weak self] in
            self?.fetchPasscodes()
        }
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(modalVC, animated: true)
    }

    func fetchPasscodes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("qr_requests").whereField("uid", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.passcodes = documents.map { $0.data() }
                    self.tableView.reloadData()
                }
            }
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(passcodes.count)
        return passcodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasscodeCell", for: indexPath)
        let data = passcodes[indexPath.row]
        cell.textLabel?.text = data["passcode"] as? String ?? "-"
        cell.detailTextLabel?.text = data["relationship"] as? String ?? ""
        return cell
    }
}
