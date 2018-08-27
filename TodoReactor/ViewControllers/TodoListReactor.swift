//
//  TodoListReactor.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxDataSources
import RxSwift
import RxCocoa
import Then

typealias TodoSection = SectionModel<Int, TodoItem>
typealias TodoDataSourceType = RxTableViewSectionedReloadDataSource<TodoSection>

class TodoListReactor: Reactor {
    
    init(provider: ServiceProvderType) {
        self.initialState = State(isEditing: false, sections: [TodoSection(model: 0, items: [])])
        self.provider = provider
    }
    
    enum Action {
        case getExistingTodos
        case toggleEditing
        case moveTodoItem(Int, Int)
        case toggleTodoDone(Int)
        case removeTodoItem(Int)
    }
    
    enum Mutation {
        case setSections([TodoSection])
        case toggleEditing
        case moveTodoItem(Int, Int)
        case deleteItem(Int)
        case updateItem(Int, TodoItem)
        case insertItem(TodoItem)
    }
    
    struct State {
        var isEditing: Bool
        var sections: [TodoSection]
    }
    
    let initialState: State
    let provider: ServiceProvderType
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getExistingTodos:
            return self.provider.todoService.fetchTodos().map { (todoItems: [TodoItem]) in
                let todoSections: [TodoSection] = [TodoSection(model: 0, items: todoItems)]
                return Mutation.setSections(todoSections)
            }
        case .toggleEditing:
            return Observable.just(Mutation.toggleEditing)
        case let .moveTodoItem(sourceIndex, destIndex):
            let todoId = self.currentState.sections[0].items[sourceIndex].id
            return self.provider.todoService.moveTodos(todoId: todoId, to: destIndex).flatMap { _ in Observable.empty() }
        case let .toggleTodoDone(index):
            var todos = self.currentState.sections[0].items
            let todo = todos[index]
            if todo.isDone {
                return self.provider.todoService.markAsUndone(id: todo.id).flatMap { _ in Observable.empty() }
            } else {
                return self.provider.todoService.markAsDone(id: todo.id).flatMap { _ in Observable.empty() }
            }
            
        case let .removeTodoItem(index):
            let todo = self.currentState.sections[0].items[index]
            return self.provider.todoService.delete(todoId: todo.id).flatMap { _ in Observable.empty() }
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let todoEventMutation = self.provider.todoService.event.flatMap { [weak self] (todoEvent: TodoEvent) -> Observable<Mutation> in
            return self?.mutate(todoEvent: todoEvent) ?? Observable.empty()
        }
        return Observable.of(mutation, todoEventMutation).merge()
    }
    
    private func mutate(todoEvent: TodoEvent) -> Observable<Mutation> {
        let state = self.currentState
        
        switch todoEvent {
        case let .create(todoItem):
            return Observable.just(Mutation.insertItem(todoItem))
            
        case let .delete(id):
            guard let index = state.sections[0].items.index(where: { (todoItem) -> Bool in
                return todoItem.id == id
            }) else { return Observable.empty() }
            return Observable.just(Mutation.deleteItem(index))
            
        case let .update(todoItem):
            guard let index = state.sections[0].items.index(where: { (todoItemArg) -> Bool in
                return todoItemArg.id == todoItem.id
            }) else { return Observable.empty() }
            return Observable.just(Mutation.updateItem(index, todoItem))
        
        case let .move(id, to):
            guard let sourceIndex = state.sections[0].items.index(where: { (todoItem) -> Bool in
                return id == todoItem.id
            }) else { return Observable.empty() }
            return Observable.just(Mutation.moveTodoItem(sourceIndex, to))
            
        case let .markAsDone(id):
            guard let index = state.sections[0].items.index(where: { (todoItem) -> Bool in
                return todoItem.id == id
            }) else { return Observable.empty() }
            var todoItem = state.sections[0].items[index]
            todoItem.isDone = true
            return Observable.just(Mutation.updateItem(index, todoItem))
            
        case let .markAsUndone(id):
            guard let index = state.sections[0].items.index(where: { (todoItem) -> Bool in
                return todoItem.id == id
            }) else { return Observable.empty() }
            var todoItem = state.sections[0].items[index]
            todoItem.isDone = false
            return Observable.just(Mutation.updateItem(index, todoItem))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(todoSections):
            state.sections = todoSections
        case .toggleEditing:
            state.isEditing = !state.isEditing
        case let .moveTodoItem(sourceIndex, destIndex):
            let todoItem = state.sections[0].items.remove(at: sourceIndex)
            state.sections[0].items.insert(todoItem, at: destIndex)
        case let .deleteItem(index):
            state.sections[0].items.remove(at: index)
        case let .updateItem(index, todoItem):
            state.sections[0].items[index] = todoItem
        case let .insertItem(todoItem):
            state.sections[0].items.insert(todoItem, at: 0)
        }
        
        return state
    }
    
    func reactorForCreatingTodo() -> TodoEditReactor {
        return TodoEditReactor(mode: TodoEditViewMode.new, provider: self.provider)
    }
    
    func reactorForEditTodo(todoItem: TodoItem) -> TodoEditReactor {
        return TodoEditReactor(mode: TodoEditViewMode.edit(todoItem), provider: self.provider)
    }
    
}
