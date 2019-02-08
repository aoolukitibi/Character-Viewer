//
//  ViewController.swift
//  Character Viewer
//
//  Created by ANTHONY O. on 1/29/19.
//  Copyright © 2019 ANTHONY O. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISplitViewControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var viewerTableView: UITableView! {
        didSet {
            viewerTableView.dataSource = self
            viewerTableView.delegate = self
        }
    }
    
    @IBOutlet weak var viewerCollectionView: UICollectionView! {
        didSet {
            viewerCollectionView.dataSource = self
            viewerCollectionView.delegate = self
        }
    }
    
    @IBAction func toggleViewLayoutStyle(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            viewerTableView.isHidden = false
            viewerCollectionView.isHidden = true
        }
        else if sender.selectedSegmentIndex == 1 {
            viewerTableView.isHidden = true
            viewerCollectionView.isHidden = false
        }
    }
    
    var notificationObserver: NSObjectProtocol?
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Find a character!"
        search.searchResultsUpdater = self
        navigationItem.searchController = search
        self.definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false

        getDataFromURL()
        #if TheWire
        self.title = "The Wire Character Viewer"
        #else
        self.title = "Simpsons Character Viewer"
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dataResponseReceived"), object: nil, queue: OperationQueue.main) { (Notification) in
            self.viewerTableView.reloadData()
            self.viewerCollectionView.reloadData()
            print("Table and collection has Reloaded")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //MARK: SplitView
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredcharacterListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterViewerTableViewCell", for: indexPath)
        
        if !filteredcharacterListArray.isEmpty {
            if let dict = filteredcharacterListArray[indexPath.row] as? Character {
                if let titleAndDescription = dict.Text, let endIndex = titleAndDescription.range(of: "-")?.lowerBound {
                    cell.textLabel?.text = String(titleAndDescription[..<endIndex])
                    cell.detailTextLabel?.text = String(titleAndDescription[endIndex...])
                    cell.detailTextLabel?.numberOfLines = 0
                    cell.detailTextLabel?.lineBreakMode = .byWordWrapping
                }
                if let imageDict = dict.Icon, let url = URL(string: (imageDict.URL)!), let imageData = try? Data(contentsOf: url){
                    cell.imageView?.image = UIImage(data: imageData)
                    let itemSize = CGSize.init(width: 40, height: 40)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image?.draw(in: imageRect)
                    cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                } else {
                    #if TheWire
                    cell.imageView?.image = UIImage(named: "TheWire")
                    #else
                    cell.imageView?.image = UIImage(named: "TheSimpsons")
                    #endif
                    let itemSize = CGSize.init(width: 40, height: 40)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image?.draw(in: imageRect)
                    cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        characterIndex = indexPath.row
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredcharacterListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterViewerCollectionViewCell", for: indexPath)
        
        if let characterCell = cell as? CharacterCollectionViewCell {
            if !filteredcharacterListArray.isEmpty {
                if let dict: Character = filteredcharacterListArray[indexPath.row] as? Character {
                    if let imageDict = dict.Icon, let url = URL(string: (imageDict.URL)!), let imageData = try? Data(contentsOf: url) {
                        characterCell.characterImageView?.image = UIImage(data: imageData)
                    } else {
                        #if TheWire
                        characterCell.characterImageView?.image = UIImage(named: "TheWire")
                        #else
                        characterCell.characterImageView?.image = UIImage(named: "TheSimpsons")
                        #endif
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        characterIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = (collectionView.bounds.size.height - 50) / 5
        let cellWidth = (collectionView.bounds.size.width - 30) / 3
        return CGSize(width: CGFloat(cellWidth), height: CGFloat(cellHeight))
    }
 
    //MARK: SearchController
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.count > 0 {
            filteredcharacterListArray = characterListArray.filter {
                (($0 as? Character)?.Text?.contains(text))!
            }
        } else {
            filteredcharacterListArray = characterListArray
        }
        viewerTableView.reloadData()
        viewerCollectionView.reloadData()
    }
    
}

