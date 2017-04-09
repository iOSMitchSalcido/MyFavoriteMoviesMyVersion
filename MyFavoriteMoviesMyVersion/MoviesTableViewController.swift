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

extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movie = movies[indexPath.row]
        print(movie)
    }
}
