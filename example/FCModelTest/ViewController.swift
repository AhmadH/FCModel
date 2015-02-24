//
//  ViewController.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

class ViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    private var people : [AnyObject]!
    
    @IBOutlet var collectionView : UICollectionView?
    @IBOutlet var queryField : UITextField?

    override init () {
        super.init(nibName: "ViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "PersonCell", bundle: nil)
        self.collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: "PersonCell")
        
        self.reloadPeople(nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadPeople:", name:FCModelChangeNotification, object:Person.self)
    }
    
    func reloadPeople(notification : NSNotification?) {
        self.people = Person.allInstances()
        NSLog("Reloading with %lu people", self.people.count)
        self.collectionView?.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:FCModelChangeNotification, object:Person.self)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        Person.executeUpdateQuery(self.queryField?.text, arguments:nil)
        return false
    }
    

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("PersonCell", forIndexPath: indexPath) as! PersonCell
        cell.configureWithPerson(self.people[indexPath.row] as! Person)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var p = self.people[indexPath.row] as! Person
        p.taps += 1
        p.save()
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
}
