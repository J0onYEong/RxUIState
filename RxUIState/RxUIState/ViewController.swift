//
//  ViewController.swift
//  RxUIState
//
//  Created by choijunios on 8/9/24.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    // 🖥️ 텍스트필드
    let textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .red.withAlphaComponent(0.3)
        field.font = UIFont.systemFont(ofSize: 40)
        return field
    }()
    let inValidColor: UIColor = .red.withAlphaComponent(0.3)
    let validColor: UIColor = .green.withAlphaComponent(0.3)
    
    // 🖥️ 저장한값 가져오기 버튼
    let fetchButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("RollBack", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .blue.withAlphaComponent(0.3)
        return btn
    }()
    // 🖥️ 값 저장하기 버튼
    let saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .green.withAlphaComponent(0.3)
        return btn
    }()
    
    let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setLayout()
    }
    
    func setLayout() {
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
    
    func bind(viewModel: ViewModel) {
        
        // Input
        textField
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.editingTextInput)
            .disposed(by: disposeBag)
        
        fetchButton
            .rx.tap
            .subscribe(onNext: { [viewModel] _ in
                viewModel.fetchData()
            })
            .disposed(by: disposeBag)
        
        saveButton
            .rx.tap
            .subscribe(onNext: { [viewModel] _ in
                viewModel.saveData()
            })
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .renderObject
            .map { rederObject in
                
                rederObject.text
            }
            .drive(textField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .inputValidation?
            .drive(onNext: { [weak self] isValid in
                
                guard let self else { return }
                textField.backgroundColor = isValid ?  validColor : inValidColor
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let view = ViewController()
    let viewModel = ViewModel()
    view.bind(viewModel: viewModel)
    return view
}
