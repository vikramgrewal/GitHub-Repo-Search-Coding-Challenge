# GitHub-Repo-Search-Coding-Challenge

Code Task:

Coding exercise. Please send in a sample project written using Swift. Don’t use any third-party frameworks. Respond back by EOD with link to their GitHub repo.

Using GitHub API and show list of repos for a given organization or user in List/Grid format. Use UICollectionView to display list/grid, using segment control add ability to toggle between list/grid.

API endpoint - https://api.github.com/users/apple/repos?page=1&per_page=10  where apple, page, per_page are input variables. Use a text field to accept user – apple, Facebook or any. When I scroll to the bottom of page, you should request for next set of repos i.e., if applicable page=2&per_page=10 and append to existing result.

UICollectionViewCell to display these labels:

"name": "example-package-dealer",
"description": "Example package for use with the Swift Package Manager"
"created_at": "2015-11-10T19:52:44Z"
"license": null

App should work in both landscape and portrait mode.
