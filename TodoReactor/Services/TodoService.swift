//
//  TodoService.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 28..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import RxCocoa
import RxSwift

enum TodoEvent {
    case create(TodoItem)
    case update(TodoItem)
    case delete(id: String)
    case move(id: String, to: Int)
    case markAsDone(id: String)
    case markAsUndone(id: String)
}

protocol TodoServiceType {
    var event: PublishSubject<TodoEvent> { get }
    
    func fetchTodos() -> Observable<[TodoItem]>
    
    func saveTodos(todos: [TodoItem]) -> Observable<Void>
    
    func create(todo: String) -> Observable<TodoItem>
    func update(todoId: String, todo: String) -> Observable<TodoItem>
    func delete(todoId: String) -> Observable<TodoItem>
    func moveTodos(todoId: String, to: Int) -> Observable<TodoItem>
    func markAsDone(id: String) -> Observable<TodoItem>
    func markAsUndone(id: String) -> Observable<TodoItem>
    
}

final class TodoService: TodoServiceType {
    
    var event: PublishSubject<TodoEvent> = PublishSubject<TodoEvent>()
    
    func create(todo: String) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap({ (todoItems: [TodoItem]) -> Observable<TodoItem> in
            let newTodo = TodoItem(todo: todo)
            return self.saveTodos(todos: todoItems + [newTodo]).map { newTodo }
        }).do(onNext: { (todoItem) in
            self.event.onNext(TodoEvent.create(todoItem))
        })
    }
    
    func fetchTodos() -> Observable<[TodoItem]> {
        if let savedTodos = UserDefaults.standard.array(forKey: "todos") as? [[String: Any]] {
            let todos: [TodoItem] = savedTodos.flatMap(TodoItem.init)
            return Observable.just(todos)
        }
        
        let defaultTodos: [TodoItem] = [
            TodoItem(todo: "Go to https://github.com/devxoul"),
            TodoItem(todo: "Star repositories I am intersted in"),
            TodoItem(todo: "Make a pull request"),
            ]
        
        let defaultTodoDictionaries = defaultTodos.map { $0.asDictionary() }
        UserDefaults.standard.set(defaultTodoDictionaries, forKey: "todos")
        return Observable.just(defaultTodos)
    }
    
    func update(todoId: String, todo: String) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap { [weak self] (todoItems: [TodoItem]) -> Observable<TodoItem> in
            guard let `self` = self else { return Observable.empty() }
            guard let index = todoItems.index(where: { (todoItem: TodoItem) -> Bool in
                return todoItem.id == todoId
            }) else { return Observable.empty() }
            var todos = todoItems
            todos[index] = TodoItem(id: todos[index].id, todo: todo, isDone: todos[index].isDone)
            return self.saveTodos(todos: todos).map { todos[index] }
            }.do(onNext: { (todoItem: TodoItem) in
                self.event.onNext(.update(todoItem))
            })
        
    }
    
    func saveTodos(todos: [TodoItem]) -> Observable<Void> {
        let dict = todos.map { $0.asDictionary() }
        UserDefaults.standard.set(dict, forKey: "todos")
        return Observable.just(Void())
    }
    
    func delete(todoId: String) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap({ (todoItems: [TodoItem]) -> Observable<TodoItem> in
            guard let index = todoItems.index(where: { (todoItem: TodoItem) -> Bool in
                return todoItem.id == todoId
            }) else { return Observable.empty() }
            var todos = todoItems
            let deletedTodo = todos.remove(at: index)
            
            return self.saveTodos(todos: todos).map { deletedTodo }
        }).do(onNext: { (todoItem: TodoItem) in
            self.event.onNext(.delete(id: todoItem.id))
        })
    }
    
    func moveTodos(todoId: String, to: Int) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap({ (todoItems: [TodoItem]) -> Observable<TodoItem> in
            guard let sourceIndex = todoItems.index(where: { (todoItem) -> Bool in
                return todoItem.id == todoId
            }) else { return Observable.empty() }
            var todos = todoItems
            let todo = todos.remove(at: sourceIndex)
            todos.insert(todo, at: to)
            return self.saveTodos(todos: todos).map { todo }
        }).do(onNext: { (todoItem) in
            self.event.onNext(.move(id: todoItem.id, to: to))
        })
    }
    
    func markAsDone(id: String) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap({ (todoItems: [TodoItem]) -> Observable<TodoItem> in
            guard let index = todoItems.index(where: { (todoItem) -> Bool in
                return todoItem.id == id
            }) else { return Observable.empty() }
            var todos = todoItems
            var todo = todos[index]
            todo.isDone = true
            return self.saveTodos(todos: todos).map { todo }
        }).do(onNext: { (todoItem) in
            self.event.onNext(.markAsDone(id: todoItem.id))
        })
    }
    
    func markAsUndone(id: String) -> Observable<TodoItem> {
        return self.fetchTodos().flatMap({ (todoItems: [TodoItem]) -> Observable<TodoItem> in
            guard let index = todoItems.index(where: { (todoItem) -> Bool in
                return todoItem.id == id
            }) else { return Observable.empty() }
            var todos = todoItems
            var todo = todos[index]
            todo.isDone = false
            return self.saveTodos(todos: todos).map { todo }
        }).do(onNext: { (todoItem) in
            self.event.onNext(.markAsUndone(id: todoItem.id))
        })
    }
   
    
    
}








