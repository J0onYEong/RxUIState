//
//  ViewController.swift
//  RxUIState
//
//  Created by choijunios on 8/9/24.
//

import UIKit

class ViewController: UIViewController {

    // 🖥️ 텍스트필드
    let textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .red.withAlphaComponent(0.3)
        field.font = UIFont.systemFont(ofSize: 40)
        return field
    }()
    // 🖥️ 저장한값 가져오기 버튼
    let fetchButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("저장한값 가져오기", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .blue.withAlphaComponent(0.3)
        return btn
    }()
    // 🖥️ 값 저장하기 버튼
    let saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("값 저장하기", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .green.withAlphaComponent(0.3)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        [
            fetchButton,
            saveButton,
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [
            textField,
            stackView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    ViewController()
}
