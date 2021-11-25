//
//  Category.swift
//  SimpleTodo
//
//  Created by Gilang Persada on 23/11/2021.
//

import Foundation
import RealmSwift

class Category:Object{
    @Persisted var id:UUID
    @Persisted var title:String = ""
    @Persisted var todos = List<Todo>()
    
}
