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
        
        // get appDelegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // reload
        tableView.reloadData()
    }
    
    // helper function. Return a URL for a movie poster path for use in cell imageView
    func thumbnailURLForPosterPath(string: String) -> URL? {
        
        if let config = appDelegate.config, let images = config["images"] as? [String: AnyObject], let secureBaseURL = images["secure_base_url"] as? String, let sizes = images["poster_sizes"] as? [String] {

            switch sizes.count {
            case 0:
                return nil
            case 1...2:
                return URL(string: secureBaseURL + sizes[0] + string)
            default:
                return URL(string: secureBaseURL + sizes[1] + string)
            }
        }
        return nil
    }
}

extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
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
            
            if let image = thumbnailImageBuffer[posterPath] {
                cell.imageView?.image = image
            }
            else {
                
                if let url = thumbnailURLForPosterPath(string: posterPath) {
                    
                    let request = URLRequest(url: url)
                    let task = URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        
                        if let imageData = data, let image = UIImage(data: imageData) {
                            self.thumbnailImageBuffer[posterPath] = image
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
