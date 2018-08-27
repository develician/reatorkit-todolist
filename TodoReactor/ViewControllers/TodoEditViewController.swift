//
//  TodoEditViewController.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class TodoEditViewController: BaseViewController, View {
    typealias Reactor = TodoEditReactor
    
    init(reactor: TodoEditReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cancelButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    let doneButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)
    
    let todoInput: UITextField = UITextField().then {
        $0.borderStyle = .roundedRect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationItem.rightBarButtonItem = doneButtonItem
        
        self.view.addSubview(todoInput)
    }
    
    override func setupConstraints() {
        self.view.backgroundColor = .white
        
        self.todoInput.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
    }
    
    
    func bind(reactor: TodoEditViewController.Reactor) {
        
//        action
        self.cancelButtonItem.rx.tap.map { Reactor.Action.cancel }
            .bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.doneButtonItem.rx.tap.map { Reactor.Action.submit }
            .bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.todoInput.rx.text.filter { (todo) -> Bool in
            guard let todo = todo else { return false }
            return !todo.isEmpty
            }.map { (todo) in
                let todo = todo ?? ""
                return Reactor.Action.updateTodo(todo)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        
//        state
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.rx.title).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.todo }
            .distinctUntilChanged()
            .bind(to: self.todoInput.rx.text).disposed(by: disposeBag)
        
        reactor.state.map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.canSubmit }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(to: self.doneButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    


}
