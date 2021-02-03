import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol LocateOnTheMap
{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchViewController: UITableViewController
{
    var searchResults: [Places] = []
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row].Title 
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        let lat = searchResults[indexPath.row].Location.latitude
        let lon = searchResults[indexPath.row].Location.longitude
        
        self.delegate?.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row].Title)
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadDataWithArray(_ array:[Places])
    {
        self.searchResults = array
        self.tableView.reloadData()
    }
}
