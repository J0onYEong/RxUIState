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
    public let textInput: PublishRelay<String> = .init()
    
    
    
    
    /// 유저 입력에 대한 검증
    private(set) var inputValidation: Driver<Bool>?
    
    
    /// 1. 수정 홀드합니다.
    /// 2. accept된 값을 RenderObject로 방출합니다.
    private let editingObject: BehaviorRelay<StateObject> = .init(value: .init())
    
    
    /// 저장 상태를 홀드합니다.
    private let stateObject = StateObject()
    
    
    
    
    init() {
        
        
        
        // Editing -> RenderObject
        renderObject = editingObject
            .map({ stateObject in
                RenderObject.createRoFrom(stateObject: stateObject)
            })
            .asDriver(onErrorJustReturn: .init(text: "에러"))
        
        
        
        // UIState를 서정하는옵저버블과 인풋은 모두 검증과정을 거친다.
        let userInput = textInput
            .map({ [editingObject] userInputString in
                
                // editing value update
                // 값을 업데이트 하지만 방출이 이뤄지지 않음(class특성)
                editingObject.value.textInput = userInputString
                
                return userInputString
            })
            .asObservable()
        
        
        
        let emittedByViewModel = editingObject.map({ $0.textInput })
        
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
    
    
    
    func userInputValidation(text: String) -> Bool {
        text.count >= 5
    }
    
    
    
    func emitInitialState() {
        
        let initialText: String = "Initial value"
        
        // ⚠️ State와 editing 오브젝트의 크기가 커지면 값을 설정하기 힘들어짐 ⚠️
        
        editingObject.accept(.init(textInput: initialText))
        
        stateObject.textInput = initialText
    }
    
    
    
    /// Editing -> State
    func saveData() {
        
        // ⚠️ 두타입이 클래스임으로 할당이 안됨, 프로퍼티를 일일히 대입해야함 ⚠️
        
        stateObject.textInput = editingObject.value.textInput
    }
    
    
    
    /// State -> NewState -> Editing -> Rendering
    func fetchData() {
        
        // ⚠️ 두타입이 클래스임으로 할당이 안됨, 프로퍼티를 일일히 대입하거나 인스턴스를 새로 생성해야함 ⚠️
        
        let savedText = stateObject.textInput
        let newStateObject = StateObject(textInput: savedText)
        
        // 새로운 StateObject를 emit
        editingObject.accept(newStateObject)
    }
}

// MARK: RenderObject
class RenderObject {
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
class StateObject {
    var textInput: String
    
    init(textInput: String = "") {
        self.textInput = textInput
    }
}
