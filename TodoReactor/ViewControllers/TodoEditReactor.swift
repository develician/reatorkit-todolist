//
//  TodoEditReactor.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

enum TodoEditViewMode {
    case new
    case edit(TodoItem)
}

class TodoEditReactor: Reactor {
    
    let mode: TodoEditViewMode
    let initialState: State
    let provider: ServiceProvderType
    
    init(mode: TodoEditViewMode, provider: ServiceProvderType) {
        self.mode = mode
        self.provider = provider
        
        switch mode {
        case .new:
            self.initialState = State(todo: "", title: "New", canSubmit: false)
        case let .edit(todoItem):
            self.initialState = State(todo: todoItem.todo, title: "Edit", canSubmit: true)
        }
    }
    
    struct State {
        var todo: String
        var title: String
        var shouldConfirmCancel: Bool
        var isDismissed: Bool
        var canSubmit: Bool
        
        init(todo: String, title: String, canSubmit: Bool) {
            self.todo = todo
            self.title = title
            self.shouldConfirmCancel = false
            self.isDismissed = false
            self.canSubmit = canSubmit
        }
    }
    
    enum Action {
        case cancel
        case submit
        case updateTodo(String)
    }
    
    enum Mutation {
        case dismiss
        case updateTodo(String)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cancel:
            if !self.currentState.shouldConfirmCancel {
                return Observable.just(Mutation.dismiss)
            }
            
            return self.provider.alertService.show().flatMap({ (isDismissed) -> Observable<Mutation> in
                if isDismissed {
                    return Observable.just(Mutation.dismiss)
                }
                return Observable.empty()
            })
        case .submit:
            guard self.currentState.canSubmit else { return Observable.empty() }
            switch self.mode {
            case .new:
                return self.provider.todoService.create(todo: self.currentState.todo).map { _ in Mutation.dismiss }
            case let .edit(todoItem):
                return self.provider.todoService.update(todoId: todoItem.id, todo: self.currentState.todo).map { _ in Mutation.dismiss }
            }
        case let .updateTodo(todo):
            return Observable.just(Mutation.updateTodo(todo))
        }
    }
    
    

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .dismiss:
            state.isDismissed = true
            return state
        case let .updateTodo(todo):
            state.todo = todo
            state.canSubmit = !todo.isEmpty
            state.shouldConfirmCancel = todo != self.initialState.todo
            return state
        }
        
    }
}

