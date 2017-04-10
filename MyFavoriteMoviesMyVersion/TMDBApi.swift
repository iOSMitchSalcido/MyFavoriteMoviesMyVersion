//
//  TMDBApi.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/7/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About TMDBApi.swift:
 Interface for TMDB API. Provides functionality for interacting with TMDB, including: login, pulling movies,
 favoriting/unfavoriting movies, and includes constants used throughout app
*/

import Foundation
import UIKit

struct TMDBApi {
        
    // errors
    enum Errors: Swift.Error {
        case networkingError(String)
    }
    
    // appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
}

// login
extension TMDBApi {
    
    // login to TMDB
    func loginWithUserName(_ userName: String, password: String, completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        /*
         Login is perform by passing an array of closures to function tbdmTask, which iterates thru array of closures
         to perform login. dataTask will provide JSON data for closures, which will return params for next dataTask.
        1) get token: /authentication/token/new
        2) validate token: /authentication/token/validate_with_login
        3) generate sessionID: /authentication/session/new
        4) retrieve userID: /account
        5) retrieve TMDB config info
         
         !! (1) above is kicked off first, and not a closure operation
        */
        
        // create closures
        
        // 2) validate token: /authentication/token/validate_with_login
        let validateTokenCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            // test success, token
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let token = params?[TMDBParameterKeys.token] as? String else {
                    return nil
            }
            
            // save token in appDelegate
            self.appDelegate.token = token
            
            // new params for next task
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.username: userName,
                             TMDBParameterKeys.password: password,
                             TMDBParameterKeys.token: token,
                             TMDBParameterKeys.pathExtensions: "/authentication/token/validate_with_login"]
            
            return newParams as [String : AnyObject]
        }
        
        // 3) generate sessionID: /authentication/session/new
        let generateSessionIdCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            // test success, token
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let token = params?[TMDBParameterKeys.token] as? String else {
                    return nil
            }
            
            // new params for next task
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.token: token,
                             TMDBParameterKeys.pathExtensions: "/authentication/session/new"]
            
            return newParams as [String : AnyObject]
        }
        
        // 4) retrieve userID: /account
        let retrieveUserIdCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            // test success, sessionID
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let sessionID = params?[TMDBParameterKeys.sessionID] as? String else {
                    return nil
            }
            
            // save sessionID in appDelegate
            self.appDelegate.sessionID = sessionID
            
            // new params for next task
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.sessionID: sessionID,
                             TMDBParameterKeys.pathExtensions: "/account"]
            
            return newParams as [String : AnyObject]
        }
        
        // 5) retrieve TMDB config info
        let retrieveConfigCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            // test userID
            guard let userID = params?[TMDBParameterKeys.userID] as? Int else {
                    return nil
            }
            
            // save userID in appDelegate
            self.appDelegate.userID = userID
            
            // new params for next task
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.pathExtensions: "/configuration"]
            
            return newParams as [String : AnyObject]
        }
        
        // create closure array
        let completions = [completion,
                           retrieveConfigCompletion,
                           retrieveUserIdCompletion,
                           generateSessionIdCompletion,
                           validateTokenCompletion]
        
        // params for first operation
        let params = [TMDBParameterKeys.api: TMDBParameterValues.api,
                      TMDBParameterKeys.pathExtensions: "/authentication/token/new"]
        
        // run task
        tmdbTask(params: params as [String : AnyObject], completions: completions)
    }
}

// functions for accessing movie fun stuff
extension TMDBApi {
    
    // retrieve list of movie genres
    func movieGenres(completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        let params = [TMDBParameterKeys.api: TMDBParameterValues.api,
                      TMDBParameterKeys.pathExtensions: "/genre/movie/list"]
        tmdbTask(params: params as [String : AnyObject], completions: [completion])
    }
    
    // retrieve list of movies by genre
    func moviesByGenreID(_ id: Int, completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        let params = [TMDBParameterKeys.api: TMDBParameterValues.api,
                      "sort_by": "created_at.asc",
                      TMDBParameterKeys.pathExtensions: "/genre/\(id)/movies"]
        
        tmdbTask(params: params as [String : AnyObject], completions: [completion])
    }
    
    // retrieve favorite movies...movies that have been "favorited"
    func favoriteMovies(completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        // test for valid sessionID and userID
        if let sessionID = appDelegate.sessionID, let userID = appDelegate.userID {
         
            // good ID's...proceed
            let params = [TMDBParameterKeys.api: TMDBParameterValues.api,
                          TMDBParameterKeys.sessionID: sessionID,
                          TMDBParameterKeys.pathExtensions: "/account/\(userID)/favorite/movies"]
            
            tmdbTask(params: params as [String : AnyObject], completions: [completion])
        }
        else {
            // bad ID's fire completion with error message
            let _ = completion(nil, Errors.networkingError("Not currently log'd in to TMDB"))
        }
    }
    
    // mark a movies favorite state
    func markMovieAsFavorite(movieID: Int, favorite: Bool, completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        // test for valid sessionID and userID
        if let sessionID = appDelegate.sessionID, let userID = appDelegate.userID {
            
            // request body
            let requestBody: [ String: AnyObject] = ["media_type": "movie" as AnyObject,
                                                     "media_id": movieID as AnyObject,
                                                     "favorite": favorite as AnyObject]
            
            // good ID's...proceed
            let params: [String: AnyObject] = [TMDBParameterKeys.api: TMDBParameterValues.api as AnyObject,
                                               TMDBParameterKeys.sessionID: sessionID as AnyObject,
                                               TMDBParameterKeys.requestBody: requestBody as AnyObject,
                                               TMDBParameterKeys.pathExtensions: "/account/\(userID)/favorite" as AnyObject]
            
            tmdbTask(params: params as [String : AnyObject], completions: [completion])
        }
        else {
            // bad ID's fire completion with error message
            let _ = completion(nil, Errors.networkingError("Not currently log'd in to TMDB"))
        }
    }
}

extension TMDBApi {

    // run a session data task
    fileprivate func tmdbTask(params: [String: AnyObject], completions: [([String: AnyObject]?, Errors?) -> [String: AnyObject]?]) {

        /*
         This function creates and runs a data task. Func takes params and sifts out key/values to create a
         valid URL. Within params, keys "pathExtensions" and requestBody can be included. pathExtensions are needed
         to append path in url creation. requestBody is required for creating post methods to API
         
         completions are an array of completion blocks of the form:
         ([String: AnyObject]?, Errors?) -> [String: AnyObject]?
         
         Block at index 0 is intended as a block to exectue upon successful finish of all blocks above. Use
         block at 0 for UI update, etc.
         
         Each block in array is intended to be passed the recovered JSON data, and return a dictionary
         for use as a params in a new tmdbTask call. The last completion in array is removed and then executed.
         
         During error checking, is problem found then completion at index 0 is executed with a non-nil Errors passed
         in.
        */
        
        // create params, pull out pathExtensions and request body
        var newParams = params
        let pathExtensions = newParams.removeValue(forKey: TMDBParameterKeys.pathExtensions) as? String
        let requestBody = newParams.removeValue(forKey: TMDBParameterKeys.requestBody)
        
        // create URLRequest. Test if body present
        var request = URLRequest(url: urlFromParams(newParams, pathExtentions: pathExtensions))

        if let requestBody = requestBody {
            request.httpMethod = "POST"
            let headers = ["content-type": "application/json;charset=utf-8"]
            request.allHTTPHeaderFields = headers
            
            do {
                let postData = try JSONSerialization.data(withJSONObject: requestBody)
                request.httpBody = postData
            }
            catch {
                let _ = completions.first!(nil, Errors.networkingError("URL request problem"))
                return
            }
        }
        else {
            request.httpMethod = "GET"
        }
        
        // create task
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // error check
            guard error == nil else {
                let _ = completions.first!(nil, Errors.networkingError("Error returned."))
                return
            }
            
            // status code check
            guard let status = (response as? HTTPURLResponse)?.statusCode,
                status >= 200 && status <= 299 else {
                let _ = completions.first!(nil, Errors.networkingError("Bad network status code returned."))
                return
            }
            
            // data returned check
            guard let data = data else {
                let _ = completions.first!(nil, Errors.networkingError("No data returned."))
                return
            }
            
            // convert data to json
            let jsonData: [String: AnyObject]!
            do {
                jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            }
            catch {
                let _ = completions.first!(nil, Errors.networkingError("Unable to convert returned data to usable format."))
                return
            }

            // create newCompletions, pull last completion for execution
            var newCompletions = completions
            let lastCompletion = newCompletions.removeLast()
            if let newParams = lastCompletion(jsonData, nil) {
                self.tmdbTask(params: newParams, completions: newCompletions)
            }
            else if !newCompletions.isEmpty {
                // still more completions, but nil params....error
                let _ = completions.first!(nil, Errors.networkingError("Unknown error."))
            }
        }
        
        // start task
        task.resume()
    }
    
    // create a url from params. Append extentions to path if non-nl
    fileprivate func urlFromParams(_ params: [String: AnyObject], pathExtentions: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = TMDB.scheme
        components.host = TMDB.host
        components.path = TMDB.path + (pathExtentions ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
}

// API constants
extension TMDBApi {
    
    // constants for TMDB api
    struct TMDB {
        fileprivate static let scheme = "https"
        fileprivate static let host = "api.themoviedb.org"
        fileprivate static let path = "/3"
    }
    
    // constants for TMDB api parameters keys
    struct TMDBParameterKeys {
        fileprivate static let requestBody = "requestBody"
        fileprivate static let api = "api_key"
        fileprivate static let username = "username"
        fileprivate static let password = "password"
        fileprivate static let token = "request_token"
        fileprivate static let success = "success"
        fileprivate static let sessionID = "session_id"
        fileprivate static let pathExtensions = "pathExtensions"
        static let userID = "id"
    }
    
    // constants for TMDB api paramater values
    struct TMDBParameterValues {
        fileprivate static let api = "aadfd5df8a93f2adb470ffac7193bad9"
    }
}
