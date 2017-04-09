//
//  MoviesTableViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {

    // app delegaete
    var appDelegate: AppDelegate!
    
    // set in calling VC
    var movies:[[String:AnyObject]]!
    
    // buffer to store movie poster image thumbnails
    var thumbnailImageBuffer = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
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
        if let posterPath = movie["poster_path"] as? String {
            if let thumbnailPathString = appDelegate.thumbnailPosterPathString() {
                
                let urlString = thumbnailPathString + posterPath
                
                if let image = thumbnailImageBuffer[urlString] {
                    cell.imageView?.image = image
                }
                else {
                    
                    let url = URL(string: urlString)
                    let request = URLRequest(url: url!)
                    let task = URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        
                        if let data = data {
                            
                            let image = UIImage(data: data)
                            self.thumbnailImageBuffer[urlString] = image
                            DispatchQueue.main.async {
                                //cell.imageView?.image = image
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                return
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
        
     return cell
     }
}

extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
    }
}
