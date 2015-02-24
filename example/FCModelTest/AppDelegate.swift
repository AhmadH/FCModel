//
//  AppDelegate.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    var window : UIWindow?
    var cachedColors : [Color]?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Test closing before anything has been opened, shouldn't crash or do anything weird (#79)
        FCModel.closeDatabase()
        
        let dbPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent("testDB.sqlite3")
        NSLog("DB path: %@", dbPath)

        // New DB on every launch for testing (comment out for persistence testing)
        NSFileManager.defaultManager().removeItemAtPath(dbPath, error: nil)
        FCModel.openDatabaseAtPath(dbPath, withDatabaseInitializer:nil, schemaBuilder:{
            (db : FMDatabase!, schemaVersion : UnsafeMutablePointer<Int32>) -> Void in
            
            db.crashOnErrors = true
//          db.traceExecution = true // Log every query (useful to learn what FCModel is doing or analyze performance)
            db.beginTransaction()
            
            let failedAt = {
                (statement : Int) -> Void in
                let lastErrorCode = db.lastErrorCode()
                let lastErrorMessage = db.lastErrorMessage()
                db.rollback()
                assert(false, "Migration statement \(statement) failed, code \(lastErrorCode): \(lastErrorMessage)")
            }
            
            if (schemaVersion.memory < 1) {
                let sql1 = "CREATE TABLE Person ("
                         + "    id           INTEGER PRIMARY KEY,"
                         + "    name         TEXT NOT NULL DEFAULT '',"
                         + "    colorName    TEXT NOT NULL,"
                         + "    taps         INTEGER NOT NULL DEFAULT 0,"
                         + "    createdTime  INTEGER NOT NULL,"
                         + "    modifiedTime INTEGER NOT NULL"
                         + ");"
                if !db.executeUpdate(sql1, withArgumentsInArray:nil) {
                    failedAt(1)
                }
                
                
                let sql2 = "CREATE UNIQUE INDEX IF NOT EXISTS name ON Person (name);"
                if !db.executeUpdate(sql2, withArgumentsInArray:nil) {
                        failedAt(2)
                }
                
                let sql3 = "CREATE TABLE Color ("
                         + "    name         TEXT NOT NULL PRIMARY KEY,"
                         + "    hex          TEXT NOT NULL"
                         + ");"
                if !db.executeUpdate(sql3,  withArgumentsInArray:nil) {
                        failedAt(3)
                }
                
                // Create any other tables...
                
                schemaVersion.memory = 1
            }
            
            // If you wanted to change the schema in a later app version, you'd add something like this here:
            /*
            if (schemaVersion.memory < 2) {
                if (!db.executeUpdate("ALTER TABLE Person ADD COLUMN lastModified INTEGER NULL")) {
                    failedAt(2)
                }
                schemaVersion.memory = 2;
            }
            */
            
            db.commit()
            
        })
        
        FCModel.inDatabaseSync({
            (db : FMDatabase!) -> Void in
            FCModel.inDatabaseSync({
                (db : FMDatabase!) -> Void in
            
            })
        })
        
        
        let testUniqueRed0 = Color.instanceWithPrimaryKey("red")
        
        // Prepopulate the Color table
        for (name, hex) in ["red" : "FF3838",
            "orange" : "FF9335",
            "yellow" : "FFC947",
            "green" : "44D875",
            "blue1" : "2DAAD6",
            "blue2" : "007CF4",
            "purple" : "5959CE",
            "pink" : "FF2B56",
            "gray1" : "8E8E93",
            "gray2" : "C6C6CC",]
        {
            var c = Color.instanceWithPrimaryKey(name)
            c.hex = hex
            c.save()
        }
        
        let testUniqueRed1 = Color.instanceWithPrimaryKey("red")
        let allColors = Color.allInstances() as! [Color]
        let testUniqueRed2 = Color.instanceWithPrimaryKey("red")

        assert(testUniqueRed0 !== testUniqueRed1, "Instance-non-uniqueness check 1 failed")
        assert(testUniqueRed1 !== testUniqueRed2, "Instance-non-uniqueness check 2 failed")
        
        // Comment/uncomment this to see caching/retention behavior.
        // Without retaining these, scroll the collectionview, and you'll see each cell performing a SELECT to look up its color.
        // By retaining these, all of the colors are kept in memory by primary key, and those requests become cache hits.
        self.cachedColors = allColors
        
        var colorsUsedAlready = Set<Color>()
        
        // Put some data in the table if there's not enough
        var numPeople = Person.numberOfInstances()
        while (numPeople < 26) {
            var p = Person()
            do {
                p.name = RandomThings.randomName()
            } while (Person.firstInstanceWhere("name = ?", arguments: [p.name]) != nil);
            
            if (count(colorsUsedAlready) >= count(allColors)) {
                colorsUsedAlready.removeAll()
            }
            
            var color : Color
            do {
                color = allColors[(Int(RandomThings.randomUInt32())) % count(allColors)];
            } while (colorsUsedAlready.contains(color) && count(colorsUsedAlready) < count(allColors));
            
            colorsUsedAlready.insert(color)
            p.color = color
            
            if (p.save()) {
                numPeople++
            }
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()

        return true
    }
}
