//
//  UserSearchViewController.swift
//  GitHubSearchDemo
//
//  Created by Vikram Grewal on 1/12/19.
//  Copyright © 2019 Vikram Grewal. All rights reserved.
//

import UIKit

class UserSearchViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var resultsTextField: UITextField!
    @IBOutlet weak var pageTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView()    {
        activityIndicatorView.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        searchButton.addTarget(self, action: #selector(validateInformation), for: .touchUpInside)
    }
    
    @objc private func validateInformation()  {
        
        activityIndicatorView.startAnimating()
        
        guard let username = userTextField.text, !username.isEmpty else {
            errorLabel.text = "Username cannot be empty."
            errorLabel.sizeToFit()
            activityIndicatorView.stopAnimating()
            return
        }
        
        guard let resultsPerPageText = resultsTextField.text, let resultsPerPage = Int(resultsPerPageText) else {
            errorLabel.text = "Results per page must be a number."
            errorLabel.sizeToFit()
            activityIndicatorView.stopAnimating()
            return
        }
        
        guard let pageNumberText = pageTextField.text, let pageNumber = Int(pageNumberText) else {
            errorLabel.text = "Page number must be a number."
            errorLabel.sizeToFit()
            activityIndicatorView.stopAnimating()
            return
        }
        
        GitHubService.getUser(username: username) { (error, user) -> (Void) in
            if let error = error {
                switch error {
                    case ServiceError.userDoesNotExist:
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "User does not exist."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        break
                    case ServiceError.invalidUsername:
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "Invalid username format."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        break
                    case ServiceError.dataNotReceived:
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "Could not receive \(username) information."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        break
                    case ServiceError.serializationError:
                        break
                    default:
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "Could not receive \(username) information."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        return
                }
            }   else if var user : GitHubUser = user {
                guard let url = GitHubService.reposUrlBuilder(user: user, resultsPerPage: resultsPerPage, pageNumber: pageNumber) else { return }
                
                GitHubService.getRepos(repoApiUrl: url, completionHandler: { (error, repos) -> (Void) in
                    if let error = error {
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "Could not receive \(username) repos."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        NSLog(String(describing: error))
                        return
                    }
                    
                    guard let repos = repos, repos.count > 0 else {
                        DispatchQueue.main.async { [unowned self] in
                            self.errorLabel.text = "No repos exist on page \(pageNumber) for \(username)."
                            self.errorLabel.sizeToFit()
                            self.activityIndicatorView.stopAnimating()
                        }
                        return
                    }
                    
                    user.repos = repos
                    let fetchedDisabled = repos.count < resultsPerPage ? true : false
                    let gitHubRepoFetcher = GitHubRepoFetcher.init(resultsPerPage: resultsPerPage, currentPage: pageNumber, disabled: fetchedDisabled)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                        self.errorLabel.text = ""
                        self.errorLabel.sizeToFit()
                        self.activityIndicatorView.stopAnimating()
                        self.startRepoCollectionViewController(user: user, fetcher: gitHubRepoFetcher)
                    }
                    
                })
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func startRepoCollectionViewController(user : GitHubUser?, fetcher : GitHubRepoFetcher)  {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let repoCollectionViewController = storyboard.instantiateViewController(withIdentifier: "repoCollectionViewController") as! RepoCollectionViewController
            repoCollectionViewController.user = user
            repoCollectionViewController.gitHubFetcher = fetcher
            self?.navigationController?.pushViewController(repoCollectionViewController, animated: true)
        }
    }
}
