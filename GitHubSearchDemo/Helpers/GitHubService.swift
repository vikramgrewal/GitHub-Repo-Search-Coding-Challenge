//
//  GitHubService.swift
//  GitHubSearchDemo
//
//  Created by Vikram Grewal on 1/12/19.
//  Copyright © 2019 Vikram Grewal. All rights reserved.
//

import Foundation

class GitHubService {
    static func getUser(username : String, completionHandler : @escaping (Error?, GitHubUser?) -> (Void)) {
        guard username.count > 0 && username.count < 255 else {
            completionHandler(ServiceError.invalidUsername, nil)
            return
        }
        
        
        let urlEndpoint = Constants.apiBaseUrl + "/users/" + username
        guard let url = URL(string: urlEndpoint) else {
            completionHandler(ServiceError.invalidUrl(urlName: urlEndpoint), nil)
            return
        }
        
        var urlRequest : URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let userTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                        
            if let error = error {
                completionHandler(error, nil)
                return
            }
            
            guard let data = data else {
                completionHandler(ServiceError.dataNotReceived, nil)
                return
            }
            
            do {
                guard let userJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]   else {
                    completionHandler(ServiceError.serializationError, nil)
                    return
                }
                
                if let errorMessage = userJson["message"] as? String, errorMessage == "Not Found" {
                    completionHandler(ServiceError.userDoesNotExist, nil)
                    return
                }
                
                let username = userJson["login"] as? String
                let avatarUrl = userJson["avatar_url"] as? String
                let htmlUrl = userJson["html_url"] as? String
                let reposCount = userJson["public_repos"] as? Int
                
                let user : GitHubUser = GitHubUser(username: username, avatarUrl: avatarUrl, htmlUrl: htmlUrl, reposCount: reposCount, repos: nil)
                completionHandler(nil, user)
                
            } catch {
                completionHandler(error, nil)
            }
        }
        
        userTask.resume()
        
    }
    
    static func reposUrlBuilder(user : GitHubUser, resultsPerPage : Int, pageNumber : Int) -> URL? {
        guard let username = user.username else { return nil }
        let urlEndpoint = "\(Constants.apiBaseUrl)/users/\(username)/repos?per_page=\(resultsPerPage)&page=\(pageNumber)"
        
        guard let url = URL(string: urlEndpoint) else { return nil }
        return url
    }
    
    static func getRepos(repoApiUrl : URL, completionHandler : @escaping (Error?, [Repo]?) -> (Void)) {
        var urlRequest : URLRequest = URLRequest(url: repoApiUrl)
        urlRequest.httpMethod = "GET"
        
        let reposTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                completionHandler(error, nil)
                return
            }
            
            guard let data = data else {
                completionHandler(ServiceError.dataNotReceived, nil)
                return
            }
            
            do {
                var repos : [Repo] = [Repo]()
                
                guard let reposJson = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] else {
                    completionHandler(ServiceError.serializationError, nil)
                    return
                }
                
                for repoJson in reposJson {

                    let name = repoJson["name"] as? String
                    let description = repoJson["description"] as? String
                    let createdAt = repoJson["created_at"] as? String
                    let licenseJson = repoJson["license"] as? [String:Any]
                    let licenseName = licenseJson?["name"] as? String
                    
                    
                    let repo = Repo.init(name: name, description: description, createdAt: createdAt, license: licenseName)
                    repos.append(repo)
                }
                
                completionHandler(nil, repos)
                
            } catch {
                completionHandler(error, nil)
            }
        }
        
        reposTask.resume()
    }
    
}

enum ServiceError : Error {
    case invalidUsername
    case userDoesNotExist
    case invalidUrl(urlName : String)
    case dataNotReceived
    case serializationError
}

