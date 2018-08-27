//
//  TodoItem.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

struct TodoItem {
    var id: String = UUID().uuidString
    var todo: String
    var isDone: Bool = false
    
    init(todo: String) {
        self.todo = todo
    }
    
    init(id: String, todo: String, isDone: Bool) {
        self.id = id
        self.todo = todo
        self.isDone = isDone
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let todo = dictionary["todo"] as? String else { return nil }
        
        self.id = id
        self.todo = todo
        self.isDone = dictionary["isDone"] as? Bool ?? false
    }
    
    func asDictionary() -> [String: Any] {
        let dictionary: [String: Any] = [
            "id": self.id,
            "todo": self.todo,
            "isDone": self.isDone,
            ]
        return dictionary
    }

}

