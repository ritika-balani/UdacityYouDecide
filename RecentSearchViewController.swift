//
//  RecentSearchViewController.swift
//  UpgradedSleepingInTheLibrary
//
//  Created by Raj Balani on 29/07/19.
//  Copyright © 2019 balani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecentSearchViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var tableView: UITableView!
    let recentSearches : [History] = []
    
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<History>!
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<History> = History.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "searchResult", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "recents")
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    // MARK: Table View Data Source Methods
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath) as! RecentSearchCell
        
        // Configure cell
        cell.nameLabel.text = result.searchResult
        
        return cell
    }
}
