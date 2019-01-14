//
//  RepoCollectionViewController.swift
//  GitHubSearchDemo
//
//  Created by Vikram Grewal on 1/13/19.
//  Copyright © 2019 Vikram Grewal. All rights reserved.
//

import UIKit

private let reuseIdentifier = "RepoCollectionViewCell"

class RepoCollectionViewController: UICollectionViewController {
    
    var flowLayout : UICollectionViewFlowLayout!
    var layoutSegmentControl: UISegmentedControl!
    
    var gitHubFetcher : GitHubRepoFetcher!
    var user : GitHubUser?
    
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(RepoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        setupView()
    }
    
    
    deinit {
        print("\(self.debugDescription) deallocated.")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupView()    {
        setupSegmentedControl()
        setupCollectionView()
    }
    
    
    private func setupSegmentedControl() {
        let segmentedControlItems = ["List", "Grid"]
        layoutSegmentControl = UISegmentedControl(items: segmentedControlItems)
        layoutSegmentControl.selectedSegmentIndex = 0
        layoutSegmentControl.sizeToFit()
        layoutSegmentControl.addTarget(self, action: #selector(segmentedControlIndexChanged), for: .valueChanged)
        navigationItem.titleView = layoutSegmentControl
        
    }
    
    @objc func segmentedControlIndexChanged()   {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupCollectionView()  {
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        guard let repos = user?.repos else {
            return 0
        }
        
        return repos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RepoCollectionViewCell
        
        
        guard let repo = user?.repos?[indexPath.row], let repoName = repo.name else {
            return cell
        }
        
        cell.nameLabel.text = repoName
        cell.descriptionLabel.text = repo.description != nil ? repo.description! : "No description"
        cell.dateLabel.text = repo.createdAt != nil ? repo.createdAt! : ""
        cell.licenseLabel.text = repo.license != nil ? repo.license! : "No license"
        
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let repos = user?.repos else { return }
        
        guard gitHubFetcher.disabled == false else { return }
        
        if indexPath.row == (repos.count-1) {
            loadAdditionalData()
        }
    }
    
    func loadAdditionalData()   {
        
        guard user != nil else { return }
        
        gitHubFetcher.currentPage += 1
        let pageNumber = gitHubFetcher.currentPage
        
        guard let url = GitHubService.reposUrlBuilder(user: user!, resultsPerPage: gitHubFetcher.resultsPerPage, pageNumber: pageNumber) else { return }
        
        GitHubService.getRepos(repoApiUrl: url, completionHandler: { (error, repos) -> (Void) in
            if let error = error {
                print(error)
                return
            }
            
            guard let repos = repos, repos.count > 0 else { return }
            
            self.user!.repos?.append(contentsOf: repos)
            self.gitHubFetcher.disabled = repos.count < self.gitHubFetcher.resultsPerPage ? true : false
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
        })
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
//    // Uncomment this method to specify if the specified item should be selected
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//
//    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
//        return true
//    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension RepoCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var itemsPerRow : CGFloat!
        var heightPerItem : CGFloat!
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            
            if layoutSegmentControl.selectedSegmentIndex == 0 {
                itemsPerRow = 1.0
                heightPerItem = 70.0
            } else if layoutSegmentControl.selectedSegmentIndex == 1 {
                if UIDevice.current.orientation == UIDeviceOrientation.portrait ||
                    UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
                    itemsPerRow = 4.0
                }   else {
                    itemsPerRow = 5.0
                }
            }
            
        }   else if UIDevice.current.userInterfaceIdiom == .phone    {
            
            if layoutSegmentControl.selectedSegmentIndex == 0 {
                itemsPerRow = 1.0
                heightPerItem = 70.0
            } else if layoutSegmentControl.selectedSegmentIndex == 1 {
                if UIDevice.current.orientation == UIDeviceOrientation.portrait ||
                    UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
                    itemsPerRow = 2.0
                }   else {
                    itemsPerRow = 3.0
                }
            }
            
        }
        
        let paddingSpace = (sectionInsets.left * itemsPerRow) + sectionInsets.right
        let availableWidth = view.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        heightPerItem = heightPerItem == nil ? widthPerItem : heightPerItem
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if layoutSegmentControl.selectedSegmentIndex == 0 {
            return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        }   else {
            return sectionInsets
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if layoutSegmentControl.selectedSegmentIndex == 0 {
            return CGFloat(1.0)
        }   else {
            return sectionInsets.left
        }
    }
}
