//
//  PersonCell.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

@objc(PersonCell)
class PersonCell : UICollectionViewCell {
    @IBOutlet var idLabel : UILabel?
    @IBOutlet var nameLabel : UILabel?
    @IBOutlet var tapsLabel : UILabel?
    @IBOutlet var colorLabel : UILabel?

    private var person : Person?

    func configureWithPerson(person : Person) {
        if let oldPerson = self.person {
            oldPerson.removeObserver(self, forKeyPath: "name")
            oldPerson.removeObserver(self, forKeyPath: "colorName")
            oldPerson.removeObserver(self, forKeyPath: "taps")
        }
        
        self.person = person
        
        if let newPerson = self.person {
            newPerson.addObserver(self, forKeyPath: "name", options:.Initial, context:nil)
            newPerson.addObserver(self, forKeyPath: "colorName", options:.Initial, context:nil)
            newPerson.addObserver(self, forKeyPath: "taps", options:.Initial, context:nil)
            
            self.idLabel?.text = String(newPerson.id)
        }
    }
    
    deinit {
        if let person = self.person {
            person.removeObserver(self, forKeyPath: "name")
            person.removeObserver(self, forKeyPath: "colorName")
            person.removeObserver(self, forKeyPath: "taps")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
            case "name":
                self.nameLabel?.text = person?.name
            case "colorName":
                if let c = person?.color {
                    self.backgroundColor = c.colorValue
                    self.colorLabel?.text = c.name
                } else {
                    self.backgroundColor = UIColor.clearColor()
                    self.colorLabel?.text = "(invalid)"
                }
            case "taps":
                self.tapsLabel?.text = "\(person!.taps) tap" + ((person?.taps == 1) ? "" : "s")
            default:
            break
        }
    }
}
