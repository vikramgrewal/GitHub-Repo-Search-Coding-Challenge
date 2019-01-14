//
//  GitHubUser.swift
//  GitHubSearchDemo
//
//  Created by Vikram Grewal on 1/12/19.
//  Copyright © 2019 Vikram Grewal. All rights reserved.
//

import Foundation

struct GitHubUser {
    
    var username : String?
    var avatarUrl : String?
    var htmlUrl : String?
    var reposCount : Int?
    var repos : [Repo]?
    
}
