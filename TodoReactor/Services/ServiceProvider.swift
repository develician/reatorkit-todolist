//
//  ServiceProvider.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 28..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

protocol ServiceProvderType {
    var todoService: TodoServiceType { get }
    var alertService: AlertServiceType { get }
}

final class ServiceProvider: ServiceProvderType {
    lazy var todoService: TodoServiceType = TodoService()
    lazy var alertService: AlertServiceType = AlertService()
}
