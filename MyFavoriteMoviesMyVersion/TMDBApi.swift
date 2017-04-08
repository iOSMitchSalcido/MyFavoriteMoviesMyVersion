//
//  TMDBApi.swift
//  MyFavoriteMoviesMyVersion
//
//  Created by Online Training on 4/7/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation
import UIKit

struct TMDBApi {
        
    // errors
    enum Errors: Swift.Error {
        case networkingError(String)
    }
}

extension TMDBApi {
    
    func loginWithUserName(_ userName: String, password: String, completion: @escaping ([String: AnyObject]?, Errors?) -> [String: AnyObject]?) {
        
        // 1. get token: /authentication/token/new
        // 2. validate token: /authentication/token/validate_with_login
        // 3. generate sessionID: /authentication/session/new
        // 4. retrieve userID: /account
        
        let validateTokenCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let token = params?[TMDBParameterKeys.token] as? String else {
                    return nil
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.token = token
            
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.username: userName,
                             TMDBParameterKeys.password: password,
                             TMDBParameterKeys.token: token,
                             "pathExtensions": "/authentication/token/validate_with_login"]
            
            return newParams as [String : AnyObject]
        }
        
        let generateSessionIdCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let token = params?[TMDBParameterKeys.token] as? String else {
                    return nil
            }
            
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.token: token,
                             "pathExtensions": "/authentication/session/new"]
            
            return newParams as [String : AnyObject]
        }
        
        let retrieveUserIdCompletion = {(params: [String: AnyObject]?, error: Errors?) -> [String: AnyObject]? in
            
            guard let success = params?[TMDBParameterKeys.success] as? Bool, success == true,
                let sessionID = params?[TMDBParameterKeys.sessionID] as? String else {
                    return nil
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sessionID = sessionID
            
            let newParams = [TMDBParameterKeys.api: TMDBParameterValues.api,
                             TMDBParameterKeys.sessionID: sessionID,
                             "pathExtensions": "/account"]
            
            return newParams as [String : AnyObject]
        }
        
        let completions = [completion,
                           retrieveUserIdCompletion,
                           generateSessionIdCompletion,
                           validateTokenCompletion]
        
        let params = [TMDBParameterKeys.api: TMDBParameterValues.api,
                      "pathExtensions": "/authentication/token/new"]
        
        tmdbTask(params: params as [String : AnyObject], completions: completions)
    }
}

extension TMDBApi {

    fileprivate func tmdbTask(params: [String: AnyObject], completions: [([String: AnyObject]?, Errors?) -> [String: AnyObject]?]) {

        var newParams = params
        let pathExtensions = newParams.removeValue(forKey: "pathExtensions") as? String
        var request = URLRequest(url: urlFromParams(params, pathExtentions: pathExtensions))
        if let requestBody = newParams.removeValue(forKey: TMDBParameterKeys.requestBody) {
            request.httpMethod = "POST"
            print(requestBody)
        }
        else {
            request.httpMethod = "GET"
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard error == nil else {
                let _ = completions.first!(nil, Errors.networkingError("Error returned"))
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode,
                status >= 200 && status <= 299 else {
                let _ = completions.first!(nil, Errors.networkingError("Non-2xx status code returned"))
                return
            }
            
            guard let data = data else {
                let _ = completions.first!(nil, Errors.networkingError("No data returned"))
                return
            }
            
            let jsonData: [String: AnyObject]!
            do {
                jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            }
            catch {
                let _ = completions.first!(nil, Errors.networkingError("Unable to convert returned data to usable format."))
                return
            }
            
            var newCompletions = completions
            let completion = newCompletions.removeLast()
            if newCompletions.isEmpty {
                let _ = completion(jsonData, nil)
            }
            else {
             
                if let newParams = completion(jsonData, nil) {
                    self.tmdbTask(params: newParams, completions: newCompletions)
                }
                else {
                    let _ = completions.first!(nil, Errors.networkingError("Unable to complete request"))
                }
            }
        }
        
        task.resume()
    }
    
    fileprivate func urlFromParams(_ params: [String: AnyObject], pathExtentions: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = TMDB.scheme
        components.host = TMDB.host
        components.path = TMDB.path + (pathExtentions ?? "")
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        components.queryItems = queryItems

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
        static let userID = "id"
    }
    
    // constants for TMDB api paramater values
    struct TMDBParameterValues {
        fileprivate static let api = "aadfd5df8a93f2adb470ffac7193bad9"
    }
}
