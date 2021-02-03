//
//  ContactsViewController.swift
//  MapList
//
//  Created by Usama Ali on 28/01/2021.
//

import UIKit


import CoreData

class ContactsViewController: UIViewController {


        @IBOutlet weak var contactsTableView: UITableView!
        
        
        //Variables
         let searchController = UISearchController(searchResultsController: nil)
         var navBarTitle: String = "All Data"
        
        var filteredArray: [DataModel] = [] // Array for search filter
        var favArray: [DataModel] = [] //Array for favorite Elements
        var namesDictionary = [String: [DataModel]]() //creating Dictionary like ["A" : ["Allen"]]
        var hiddenSections : [Int] = []
        
        //Array for DataModel
        var data: [DataModel] = []
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
            data.append(DataModel(title: "Test", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            data.append(DataModel(title: "Test1", discipline: "Candle Shop", url: "https://www.google.com", fav: true, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            data.append(DataModel(title: "Test2", discipline: "Candle Shop", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            data.append(DataModel(title: "Check", discipline: "Pumpkin Patch Farm", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            data.append(DataModel(title: "John", discipline: "Wine & Spirits", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            data.append(DataModel(title: "Allen", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
            
            setUpNavBar()
           // createNameDictionary(table: <#UITableView#>) // Creating Dictionary for Alphabets which create shows in table view header like
                                    // A : "Allen" "Andrew"
        }
        
        private func setUpNavBar() {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.title = navBarTitle
            
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        
            searchController.searchResultsUpdater = self as UISearchResultsUpdating
            definesPresentationContext = true
        }
        
        func createNameDictionary(table:UITableView)
        {
            for x in data {
                let name = x.discipline
                
                if (namesDictionary.keys.contains { (keyName) -> Bool in
                    if (keyName == name) { return true }
                    return false })
                {
                    namesDictionary[name]?.append(DataModel.init(title: x.title, discipline: x.discipline, url: x.url, fav: x.isFav, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
                }
                else
                {
                    namesDictionary[name] = [x]
                }
            }
            checkFavoriteCount(table: table)
        }
        
    func checkFavoriteCount(table:UITableView)
        {
            favArray.removeAll()
            for x in (0...namesDictionary.keys.count - 1)
            {
                let k = namesDictionary[x].key
                for y in (0...namesDictionary[x].value.count - 1)
                {
                    if (namesDictionary[k]?[y].isFav ?? false)
                    {
                        favArray.append((namesDictionary[k]?[y])!)
                    }
                }
            }
            table.reloadData()
        }
        
    }

    extension ContactsViewController: UISearchResultsUpdating {
        
        func updateSearchResults(for searchController: UISearchController) {
            filterContacts(text: searchController.searchBar.text!)
        }
        
        private func filterContacts(text: String, scope: String = "All") {
            
            filteredArray = data.filter({ (d) -> Bool in
                return d.title.lowercased().contains(text.lowercased())
            })
            
            contactsTableView.reloadData()
        }
    }

    extension Dictionary
    {
        subscript (i: Int) -> (key: Key, value: Value)
        {
            get{
                return self[index(startIndex, offsetBy: i)]
            }
        }
        
    }

