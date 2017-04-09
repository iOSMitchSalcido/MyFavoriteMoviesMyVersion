//
//  MovieViewController.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/8/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var movie: [String:AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Info"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(movie)
    }
}
