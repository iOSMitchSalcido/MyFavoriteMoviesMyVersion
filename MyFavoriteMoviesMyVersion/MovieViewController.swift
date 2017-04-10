//
//  MovieViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {

    // outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // movie object
    var movie: [String:AnyObject]!
    
    // ref to delegate
    var appDelegate: AppDelegate!
    
    // bbi's
    var unfavBbi: UIBarButtonItem!
    var favBbi: UIBarButtonItem!
    
    // ref to api
    let api = TMDBApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        title = "Info"
        
        // appDelegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        unfavBbi = UIBarButtonItem(barButtonSystemItem: .stop,
                                   target: self,
                                   action: #selector(toggleFavorite(_:)))
        
        favBbi = UIBarButtonItem(barButtonSystemItem: .add,
                                   target: self,
                                   action: #selector(toggleFavorite(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = movie["title"] as? String {
            titleLabel.text = name
        }
        
        if let overview = movie["overview"] as? String {
            textView.text = overview
        }
        else {
            textView.text = "No info available"
        }
        
        if let posterPath = movie["poster_path"] as? String, let url = posterURLForPosterPath(string: posterPath) {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {
                (data, _, _) in
                
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
            task.resume()
        }
        
        updateFavoriteMovies()
    }
    
    // helper function. Return a URL for a movie poster path for use in cell imageView
    func posterURLForPosterPath(string: String) -> URL? {
        
        if let config = appDelegate.config, let images = config["images"] as? [String: AnyObject], let secureBaseURL = images["secure_base_url"] as? String, let sizes = images["poster_sizes"] as? [String] {
            
            // return size based on number of available sizes
            let index = sizes.count - 2
            if index > 0 {
                return URL(string: secureBaseURL + sizes[index] + string)
            }
        }
        return nil
    }
    
    // helper function..get favorites
    func updateFavoriteMovies() {
        
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
                // get params, test for results..movies
                if let params = params, let results = params["results"] as? [[String:AnyObject]] {
                    
                    var isFav = false
                    for result in results {
                        if let resultID = result["id"] as? Int, let movieID = self.movie["id"] as? Int, resultID == movieID {
                            isFav = true
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if isFav {
                            self.navigationItem.rightBarButtonItem = self.unfavBbi
                        }
                        else {
                            self.navigationItem.rightBarButtonItem = self.favBbi
                        }
                    }
                }
            }
            
            return nil
        }
        api.favoriteMovies(completion: completion)
    }
    
    func toggleFavorite(_ sender: UIBarButtonItem) {
        
        var alertTitle: String!
        var fav = false
        if sender == unfavBbi {
            alertTitle = "Remove movie from favorites ?"
        }
        else {
            alertTitle = "Add movie to favorites ?"
            fav = true
        }
        
        let alert = UIAlertController(title: alertTitle,
                                      message: nil,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        
        // build completion
        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
            
            // error test
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            
            if let _ = params {
                self.updateFavoriteMovies()
            }
            
            return nil
        }
        
        let proceedAction = UIAlertAction(title: "Proceed",
                                          style: .destructive) {
                                            (action) in
                                            
                                            let id = self.movie["id"] as! Int
                                            self.api.markMovieAsFavorite(movieID: id, favorite: fav, completion: completion)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(proceedAction)
        present(alert, animated: true, completion: nil)
    }
}
