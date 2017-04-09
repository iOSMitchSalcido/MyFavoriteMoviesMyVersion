//
//  GenresTableViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class GenresTableViewController: UITableViewController {

    let api = TMDBApi()
    
    var genres = [["name": "My Favorites", "id": 0]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movie Genres"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
            
            if let error = error {
                switch error {
                case .networkingError(let value):
                    print("Networking Error: \(value)")
                }
            }
            else {
                if let genresArray = params?["genres"] as? [[String: AnyObject]] {
                    for genre in genresArray {
                        self.genres.append(genre)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            return nil
        }
        
        api.movieGenres(completion: completion)
    }
}

extension GenresTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCellID", for: indexPath)
        
        // Configure the cell...
        
        let genre = genres[indexPath.row]
        if let name = genre["name"] as? String {
            cell.textLabel?.text = name
        }
        
        return cell
    }
}

extension GenresTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let genre = genres[indexPath.row]
        if let id = genre["id"] as? Int {
            
            let completion = {(params: [String: AnyObject]?, error: TMDBApi.Errors?) -> [String: AnyObject]? in
                
                if let error = error {
                    switch error {
                    case .networkingError(let value):
                        print("Networking Error: \(value)")
                    }
                }
                else {
                    if let params = params, let results = params["results"] as? [[String:AnyObject]] {
                        
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MoviesTableViewController") as! MoviesTableViewController
                        controller.movies = results
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                }
                
                return nil
            }
            api.moviesByGenreID(id, completion: completion)
        }
    }
}
