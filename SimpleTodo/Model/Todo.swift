//
//  Todo.swift
//  SimpleTodo
//
//  Created by Gilang Persada on 23/11/2021.
//

import Foundation
import RealmSwift

class Todo:Object{
    @Persisted var title:String = ""
    @Persisted var isDone:Bool = false
    @Persisted var createdAt:Date?
    var category = LinkingObjects(fromType:Category.self, property:"todos")
}
