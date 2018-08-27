//
//  ViewController.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import Then
import SnapKit
import RxViewController
import ReusableKit

class TodoListViewController: BaseViewController, View {
    
    
    init(reactor: TodoListReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = TodoListReactor
    
    struct Reusable {
        static let todoCell = ReusableCell<TodoCell>()
    }

    let tableView = UITableView().then {
        $0.register(Reusable.todoCell)
        $0.allowsSelectionDuringEditing = true
    }
    
    let addButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Todo List"
        self.navigationItem.rightBarButtonItem = self.addButtonItem
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func setupConstraints() {
        
        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func createDataSource() -> TodoDataSourceType {
        return TodoDataSourceType(configureCell: { (dataSource, tableView, indexPath, todoItem) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.todoCell) ?? TodoCell()
            cell.update(item: todoItem)
            return cell
        }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
            return true
        }, canMoveRowAtIndexPath: { (dataSource, indexPath) -> Bool in
            return true
        })
    }
    

    func bind(reactor: TodoListReactor) {
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
//        action
        self.rx.viewDidLoad.map { Reactor.Action.getExistingTodos }
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        self.editButtonItem.rx.tap.map { Reactor.Action.toggleEditing }
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        self.tableView.rx.itemMoved.map { (sourceIndexPath: IndexPath, destIndexPath: IndexPath) in
            return Reactor.Action.moveTodoItem(sourceIndexPath.item, destIndexPath.item)
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.map { (indexPath) in
            let index = indexPath.item
            return Reactor.Action.toggleTodoDone(index)
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        self.tableView.rx.itemDeleted.map { (indexPath) in
            let index = indexPath.item
            return Reactor.Action.removeTodoItem(index)
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(TodoDataSourceType.Section.Item.self)
            .filter(reactor.state.map { $0.isEditing })
            .map(reactor.reactorForEditTodo)
            .subscribe(onNext: { [weak self] (reactor) in
                guard let `self` = self else { return }
                let viewController = TodoEditViewController(reactor: reactor)
                let navigationController = UINavigationController(rootViewController: viewController)
                self.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        
        
        self.addButtonItem.rx.tap
            .map { _ in
               return reactor.reactorForCreatingTodo()
            }.subscribe(onNext: { [weak self] (todoEditReactor) in
                guard let `self` = self else { return }
                let viewController = TodoEditViewController(reactor: todoEditReactor)
                let navigationController = UINavigationController(rootViewController: viewController)
                self.present(navigationController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
//        state
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: createDataSource()))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isEditing }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (isEditing) in
                guard let `self` = self else { return }
                self.tableView.setEditing(isEditing, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    

}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


