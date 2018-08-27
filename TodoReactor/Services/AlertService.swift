//
//  AlertService.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 28..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

import RxSwift

protocol AlertServiceType: class {
    func show() -> Observable<Bool>
}

final class AlertService: AlertServiceType {
    func show() -> Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: "떠나시겠습니까?", message: "작성중이던것이 있습니다.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "예", style: UIAlertActionStyle.default, handler: { _ in
                observer.onNext(true)
                observer.onCompleted()
            }))
            alert.addAction(UIAlertAction(title: "아니오", style: UIAlertActionStyle.cancel, handler: { _ in
                observer.onNext(false)
                observer.onCompleted()
            }))
            
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
            
            rootViewController?.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
}
