//
//  MoviesTableViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {

    var movies:[[String:AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellID", for: indexPath)
     
     // Configure the cell...
     let movie = movies[indexPath.row]
        if let title = movie["title"] as? String {
            cell.textLabel?.text = title
        }
        
     return cell
     }
}
