//
//  ScrollableBottomSheetViewController.swift
//  BottomSheet
//
//  Created by Ahmed Elassuty on 10/15/16.
//  Copyright © 2016 Ahmed Elassuty. All rights reserved.
//

import UIKit
import MapKit

import CoreData

class ScrollableBottomSheetViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let fullView: CGFloat = 100
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 250
    }

    let searchController = UISearchController(searchResultsController: nil)
    var navBarTitle: String = "All Data"
   
   var filteredArray: [DataModel] = [] // Array for search filter
   var favArray: [DataModel] = [] //Array for favorite Elements
   var namesDictionary = [String: [DataModel]]() //creating Dictionary like ["A" : ["Allen"]]
   var hiddenSections : [Int] = []
   
   //Array for DataModel
   var data: [DataModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "ContactsCell")
        
        searchBar.delegate = self
        searchBar.isUserInteractionEnabled = true
        definesPresentationContext = true
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(ScrollableBottomSheetViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        data.append(DataModel(title: "Test", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false))
        data.append(DataModel(title: "Test1", discipline: "Candle Shop", url: "https://www.google.com", fav: true))
        data.append(DataModel(title: "Test2", discipline: "Candle Shop", url: "https://www.google.com", fav: false))
        data.append(DataModel(title: "Check", discipline: "Pumpkin Patch Farm", url: "https://www.google.com", fav: false))
        data.append(DataModel(title: "John", discipline: "Wine & Spirits", url: "https://www.google.com", fav: false))
        data.append(DataModel(title: "Allen", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false))
        
        self.createNameDictionary(table: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height - 100)
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createNameDictionary(table:UITableView)
    {
        for x in data {
            let name = x.discipline
            
            if (namesDictionary.keys.contains { (keyName) -> Bool in
                if (keyName == name) { return true }
                return false })
            {
                namesDictionary[name]?.append(DataModel.init(title: x.title, discipline: x.discipline, url: x.url, fav: x.isFav ))
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
        tableView.reloadData()
    }
    
    @objc func infoPressed(_ sender: UIButton){
        
        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
        let imageDataDict:[String: DataModel] = ["data": data[sender.tag]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapData"), object: nil, userInfo: imageDataDict)
        
    }
    
}

extension ScrollableBottomSheetViewController: UITableViewDelegate, UITableViewDataSource
{
    public func numberOfSections(in tableView: UITableView) -> Int {
        var count = Int()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            count = 1
        }
        
        else if (favArray.count != 0 )
        {
            count = namesDictionary.keys.count + 1
        }
        
        else {
            count = namesDictionary.keys.count
        }
        
        return count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        
        if self.hiddenSections.contains(section) {
            return 0
        }
        else
        {
            if searchBar.text != "" {
                count = filteredArray.count
            }
            
            else if (favArray.count != 0){
                
                if (section == 0)
                {
                    count = favArray.count
                }
                else
                {
                    count = Array(namesDictionary)[section - 1].value.count
                }
            }
            
            else {
                count = Array(namesDictionary)[section].value.count
            }
            
            return count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
        
        var names : String
        var dicData : DataModel?
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoPressed(_:)), for: .touchUpInside)
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.contactName.text = filteredArray[indexPath.row].title
        }
        
        
        else if (favArray.count != 0)
        {
            if (indexPath.section == 0)
            {
                if indexPath.row < favArray.count
                {
                    cell.contactName.text = favArray[indexPath.row].title
                    cell.favBtn.setImage(UIImage(named: "starIcon"), for: .normal)
                    cell.favBtn.isEnabled = false
                }
                
            }
            else
            {
                if indexPath.row < favArray.count
                {
                cell.favBtn.isEnabled = true
                names = namesDictionary[indexPath.section - 1].key
                
                dicData = namesDictionary[names]?[(indexPath.row)]
                cell.contactName.text = dicData?.title
                
                if (dicData?.isFav ?? false)
                {
                    cell.favBtn.setImage(UIImage(named: "starIcon"), for: .normal)
                }
                else
                {
                    cell.favBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
                }
                
                cell.favBtn.value = dicData
                cell.favBtn.index = indexPath
                cell.favBtn.addTarget(self, action: #selector(favBtn(_:)), for: .touchUpInside)
            }
          }
        }
        
        else
        {
            cell.favBtn.isEnabled = true
            names = namesDictionary[indexPath.section].key
            dicData = namesDictionary[names]?[indexPath.row]
            cell.contactName.text = dicData?.title
            
            if (dicData?.isFav ?? false)
            {
                cell.favBtn.setImage(UIImage(named: "starIcon"), for: .normal)
            }
            else
            {
                cell.favBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
            }
            
            cell.favBtn.value = dicData
            cell.favBtn.index = indexPath
            cell.favBtn.addTarget(self, action: #selector(favBtn(_:)), for: .touchUpInside)
            
        }
        
        return cell
    }
    
    @objc func favBtn(_ sender: CustomButton)
    {
        let index = sender.index
        let cell = tableView.cellForRow(at: index!) as! ContactsCell
        let dicData = sender.value
        
        if (dicData?.isFav ?? false)
        {
            cell.favBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
            dicData?.isFav = false
            self.checkFavoriteCount(table: self.tableView)
        }
        else
        {
            cell.favBtn.setImage(UIImage(named: "starIcon"), for: .normal)
            dicData?.isFav = true
            self.checkFavoriteCount(table: self.tableView)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: data[indexPath.row].url){
            UIApplication.shared.open(url)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchBar.text != "" {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionButton = UIButton()
            
        if  searchBar.text != "" {
            sectionButton.setTitle(String("Top Name Matches"),for: .normal)
        }
        else if (favArray.count != 0){
            if (section == 0)
            {
                sectionButton.setTitle(String("Favorites"),for: .normal)
            }
            else {
                sectionButton.setTitle(String(Array(namesDictionary)[section - 1].key),for: .normal)
            }
        }
        else {
            sectionButton.setTitle(String(Array(namesDictionary)[section].key),for: .normal)
        }
            
        sectionButton.backgroundColor = .systemGray4
        sectionButton.tag = section
        sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)),for: .touchUpInside)
        return sectionButton
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        if hiddenSections.contains(section)
        {
            hiddenSections.removeAll { (i) -> Bool in
                if (i == section) {return true}
                else {return false}
            }
        }
        else
        {
            hiddenSections.append(section)
        }
        tableView.reloadData()
    }
}

extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {

    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        let y = view.frame.minY
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        return false
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)

        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
                
                }, completion: { [weak self] _ in
                    if ( velocity.y < 0 ) {
                        self?.tableView.isScrollEnabled = true
                    }
            })
        }
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
    

}

extension ScrollableBottomSheetViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContacts(text: searchController.searchBar.text!)
    }
    
    private func filterContacts(text: String, scope: String = "All") {
        
        filteredArray = data.filter({ (d) -> Bool in
            return d.title.lowercased().contains(text.lowercased())
        })
        
        tableView.reloadData()
    }
}


extension ScrollableBottomSheetViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        print(textSearched)
        filterContacts(text: textSearched)
    }
}
