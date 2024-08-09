//
//  ViewModel.swift
//  RxUIState
//
//  Created by choijunios on 8/9/24.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    /// UI가 값을 전달받는 Driver
    public let renderObject: Driver<RenderObject>
    
    
    /// 유저의 텍스트 입력
    public let editingTextInput: PublishRelay<String> = .init()
    
    
    
    
    /// 유저 입력에 대한 검증
    private(set) var inputValidation: Driver<Bool>?
    
    
    /// 현재 State를 방출합니다.
    private let statePublisher: PublishRelay<StateObject> = .init()
    
    
    /// 저장 상태를 홀드합니다.
    private var editingState: StateObject!
    private var savedState: StateObject!
    

    
    init() {
        
        // Editing -> RenderObject
        renderObject = statePublisher
            .map({ stateObject in
                RenderObject.createRoFrom(stateObject: stateObject)
            })
            .asDriver(onErrorJustReturn: .init(text: "에러"))
        
        
        
        // UIState를 서정하는옵저버블과 인풋은 모두 검증과정을 거친다.
        let userInput = editingTextInput
            .map({ [weak self] (userInputString: String) in

                self?.editingState.textInput = userInputString
                
                return userInputString
            })
        
        
        
        let emittedByViewModel = statePublisher.map({ $0.textInput })
        
        inputValidation = Observable
            .merge(
                userInput,
                emittedByViewModel
            )
            .map { [weak self] targetString in
                guard let self else { return false }
                
                return userInputValidation(text: targetString)
            }
            .asDriver(onErrorJustReturn: false)
        
    }
    
    func setInitialState() {
        // 초기 상태 설정
        let initialState = getInitialState()
        editingState = initialState
        savedState = initialState
        
        // 초기상태 이벤트를 방출
        statePublisher.accept(initialState)
    }
    
    
    func userInputValidation(text: String) -> Bool {
        text.count >= 5
    }
    
    
    
    func getInitialState() -> StateObject {
        
        let initialText: String = "Initial value"
        
        return .init(textInput: initialText)
    }
    
    
    
    /// Editing -> State
    func saveData() {
        
        savedState = editingState
    }
    
    
    
    /// State -> NewState -> Editing -> Rendering
    func fetchData() {
        
        editingState = savedState
        
        // 새로운 StateObject를 emit
        statePublisher.accept(editingState)
    }
}

// MARK: RenderObject
struct RenderObject {
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    static func createRoFrom(stateObject: StateObject) -> RenderObject {
        
        // View에 맞춰 변형
        let formattedString = stateObject.textInput
        
        return .init(
            text: formattedString
        )
    }
}

// MARK: StateObject
struct StateObject {
    var textInput: String
    
    init(textInput: String = "") {
        self.textInput = textInput
    }
}
