//
//  MovieViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MovieViewController.swift:
 VC to present movie info: movie title, poster image, and summary. Provides functionality to add/remove movie
 from favorites.
*/

import UIKit

class MovieViewController: UIViewController {

    // outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // movie object
    var movie: [String:AnyObject]!
    
    // ref to delegate
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // bbi's for favoriting/unfavoriting a movie
    var unfavBbi: UIBarButtonItem!
    var favBbi: UIBarButtonItem!
    
    // ref to api
    let api = TMDBApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        title = "Info"
        
        // unfav bbi
        unfavBbi = UIBarButtonItem(barButtonSystemItem: .stop,
                                   target: self,
                                   action: #selector(toggleFavorite(_:)))
        
        // fav bbi
        favBbi = UIBarButtonItem(barButtonSystemItem: .add,
                                   target: self,
                                   action: #selector(toggleFavorite(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // movie title
        if let name = movie["title"] as? String {
            titleLabel.text = name
        }
        
        // overView text
        if let overview = movie["overview"] as? String {
            textView.text = overview
        }
        else {
            textView.text = "No info available"
        }
        
        // movie poster
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
        
        // update movies favorite...set bbi's depending on favorite state
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
    
    // helper function..get favorites and update bbi's according to fav state
    func updateFavoriteMovies() {
        
        // completion for retrieving movies by genre. Handles setting movies array and setting fav/unfav bbi's
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
                    
                    // iterate, check of movie is in favorites list...clumsy
                    var isFav = false
                    for result in results {
                        if let resultID = result["id"] as? Int, let movieID = self.movie["id"] as? Int, resultID == movieID {
                            isFav = true
                        }
                    }
                    
                    // set bbi's based on current movie fav state
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
    
    // handle toggling movie favorite state
    func toggleFavorite(_ sender: UIBarButtonItem) {
        
        // test bbi pressed, set alertTitle
        var alertTitle: String!
        var fav = false
        if sender == unfavBbi {
            alertTitle = "Remove movie from favorites ?"
        }
        else {
            alertTitle = "Add movie to favorites ?"
            fav = true
        }
        
        // create alert
        let alert = UIAlertController(title: alertTitle,
                                      message: nil,
                                      preferredStyle: .alert)
        
        // cancel
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) {
                                            (action) in
        }
        
        
        // completion for proceedAction. Handle updating fav/unfav bbi state
        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
            
            // error test
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            else if let _ = params {
                // good params returned.. update fav state
                self.updateFavoriteMovies()
            }
            
            return nil
        }
        
        // proceed action
        let proceedAction = UIAlertAction(title: "Proceed",
                                          style: .destructive) {
                                            (action) in
                                            
                                            // update movie favorite state
                                            let id = self.movie["id"] as! Int
                                            self.api.markMovieAsFavorite(movieID: id, favorite: fav, completion: completion)
        }
        
        // add actions, present alert
        alert.addAction(cancelAction)
        alert.addAction(proceedAction)
        present(alert, animated: true, completion: nil)
    }
}
