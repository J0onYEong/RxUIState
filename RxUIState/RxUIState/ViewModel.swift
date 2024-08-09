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
    
    /// Casting
    let renderObject: Driver<RenderObject>
    
    /// Editing
    let editingObject: BehaviorRelay<StateObject> = .init(value: .init())
    
    let textInput: PublishRelay<String> = .init()
    private(set) var inputValidation: Driver<Bool>?
    
    /// State
    let stateObject = StateObject()
    
    init() {
        
        // Input -> Output
        
        renderObject = editingObject
            .map({ stateObject in
                RenderObject.createRo(stateObject: stateObject)
            })
            .asDriver(onErrorJustReturn: .init(text: "에러"))
        
        inputValidation = textInput
            .map { [weak self] userInputString in
                guard let self else { return false }
                
                return userInputValidation(text: userInputString)
            }
            .asDriver(onErrorJustReturn: false)
    }
    
    func userInputValidation(text: String) -> Bool {
        text.count >= 5
    }
    
    /// Editing -> State
    func saveData() {
        stateObject.textInput = editingObject.value.textInput
    }
    
    /// State -> NewState -> Editing -> Rendering
    func fetchData() {
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
    
    static func createRo(stateObject: StateObject) -> RenderObject {
        
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
