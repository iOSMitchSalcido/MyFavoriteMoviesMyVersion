//
//  GenresTableViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About GenresTableViewController.swift:
 TVC to present movie genres available from the TMDB data base. TVC pulls data and populates genres dictionary, which
 is used as source for tv
*/

import UIKit

class GenresTableViewController: UITableViewController {

    // ref to api
    let api = TMDBApi()
    
    // store for genres
    var genres = [["name": "My Favorites", "id": 0]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title
        title = "Genres"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // completion for api call
        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
            
            // test error
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            else {
                // retrieve genres, append each element to genres dictionary
                if let genresArray = params?["genres"] as? [[String: AnyObject]] {
                    for genre in genresArray {
                        self.genres.append(genre)
                    }
                    
                    // update tv
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            return nil
        }
        
        // invoke api call
        api.movieGenres(completion: completion)
    }
}

// tv data source functions
extension GenresTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCellID", for: indexPath)
        
        // Configure the cell...
        let genre = genres[indexPath.row]
        if let name = genre["name"] as? String {
            
            // genre text
            cell.textLabel?.text = name
        }
        
        return cell
    }
}

// tv delegate functions
extension GenresTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // cell selected
        
        // get genre, id
        let genre = genres[indexPath.row]
        if let id = genre["id"] as? Int {
            
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
                        
                        // good results..invoke MoviesTVC, populate with results
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MoviesTableViewController") as! MoviesTableViewController
                        controller.movies = results
                        if let genreName = genre["name"] as? String {
                            // VC title is genre name
                            controller.title = genreName
                        }
                        
                        // push
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                }
                
                return nil
            }
            
            // invoke api call
            api.moviesByGenreID(id, completion: completion)
        }
    }
}
