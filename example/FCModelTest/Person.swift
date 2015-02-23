//
//  Person.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

@objc(Person)
class Person : FCModel {
    // database columns:
    var id : UInt64 = 0
    var name : String = ""
    var colorName : String = ""
    var taps : Int = 0
    var createdTime : NSDate?
    var modifiedTime : NSDate?
    
    // non-columns:
    var color : Color {
        get {
            return Color.instanceWithPrimaryKey(self.colorName)
        }
        
        set {
            self.colorName = newValue.name
        }
    }
    
    override func save() -> Bool {
        if (self.hasUnsavedChanges) {
            self.modifiedTime = NSDate()
        }
        if (!self.existsInDatabase) {
            self.createdTime = NSDate()
        }
        return super.save()
    }
}
