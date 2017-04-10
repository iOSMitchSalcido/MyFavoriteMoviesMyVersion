//
//  MoviesTableViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MoviesTableViewController.swift:
 TVC to present a list of movies.
*/

import UIKit

class MoviesTableViewController: UITableViewController {

    // app delegaete
    var appDelegate: AppDelegate!
    
    // store for movies
    var movies = [[String:AnyObject]]()
    
    // buffer to store movie poster image thumbnails
    var thumbnailImageBuffer = [String: UIImage]()
    
    // set in calling VC..nil is favorites
    var genreID: Int?
    
    // ref to api
    let api = TMDBApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get appDelegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // completion for retrieving movies by genre
        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
            
            // test error
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            else {
                // get params, test for results..movies in genre
                if let params = params, let results = params["results"] as? [[String:AnyObject]] {
                    
                    // set movies
                    self.movies = results
                    
                    // reload data
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            return nil
        }
        
        if let id = genreID {
            print("getting movies by genre")
            api.moviesByGenreID(id, completion: completion)
        }
        else {
            print("getting favorite movies")
            api.favoriteMovies(completion: completion)
        }
    }
    
    // helper function. Return a URL for a movie poster path for use in cell imageView
    func thumbnailURLForPosterPath(string: String) -> URL? {
        
        if let config = appDelegate.config, let images = config["images"] as? [String: AnyObject], let secureBaseURL = images["secure_base_url"] as? String, let sizes = images["poster_sizes"] as? [String] {

            // return size based on number of available sizes
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

// tv data source functions
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
            // populate cell text with movie title
            cell.textLabel?.text = title
        }
        else {
            cell.textLabel?.text = "?Unknown?"
        }
        
        // retrieve poster_path from movie
        if let posterPath = movie["poster_path"] as? String {
            
            // posterPath is used as key for cell image buffer...test for image
            if let image = thumbnailImageBuffer[posterPath] {
                // image is in buffer...set cell imageView
                cell.imageView?.image = image
            }
            else {
                
                // image doesn't exist in buffer...retrieve image
                if let url = thumbnailURLForPosterPath(string: posterPath) {
                    
                    let request = URLRequest(url: url)
                    let task = URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        
                        // get image...set in buffer
                        if let imageData = data, let image = UIImage(data: imageData) {
                            self.thumbnailImageBuffer[posterPath] = image
                            
                            // reload row
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

// tv delegate functions
extension MoviesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movie = movies[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MovieViewController") as! MovieViewController
        controller.movie = movie
        navigationController?.pushViewController(controller, animated: true)
    }
}
