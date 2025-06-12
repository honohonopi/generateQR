//
//  GeneratePasscodeModalViewController.swift
//  generateQR
//
//  Created by Honoka Nishiyama on 2025/06/11.
//

import UIKit

class GeneratePasscodeModalViewController: UIViewController {

    var onPasscodesGenerated: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    func setupUI() {
        let button = UIButton(type: .system)
        button.setTitle("パスコードを生成", for: .normal)
        button.addTarget(self, action: #selector(generate), for: .touchUpInside)
        button.frame = CGRect(x: 40, y: 100, width: 300, height: 50)
        view.addSubview(button)
    }

    @objc func generate() {
        // 関係者情報は仮で固定 or 入力UIを追加可能
        generatePasscodeIfNeeded(relationship: "保護者") { code in
            DispatchQueue.main.async {
                if let _ = code {
                    self.onPasscodesGenerated?()
                    self.dismiss(animated: true)
                } else {
                    let alert = UIAlertController(title: "上限", message: "パスコードは最大3つまでです", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
