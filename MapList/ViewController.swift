//
//  ViewController.swift
//  MapList
//
//  Created by Usama Ali on 28/01/2021.
//

import UIKit
import SwiftMessages
import MapKit

struct Places
{
    var Title : String
    var subTitle: String
    var Location: CLLocationCoordinate2D
}

class ViewController: UIViewController, UISearchBarDelegate
{
    var selectedLoc : CLLocationCoordinate2D?
    @IBOutlet weak var customeMapView: MKMapView!
    @IBOutlet weak var searchBtnUI: UIButton!
    let addCredit: ImageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
    var searchResultController: SearchViewController!
    let locationManager = CLLocationManager()
//    var mapView: GMSMapView?
    
    var placesArray : [DataModel] = []
    var resultsArray: [DataModel] = []
    
    var swiftyView = MessageView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customeMapView.delegate = self
        searchResultController = SearchViewController()
        searchResultController.delegate = self
                
        placesArray.append(DataModel(title: "Test", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728)))
        placesArray.append(DataModel(title: "Test1", discipline: "Candle Shop", url: "https://www.google.com", fav: true, locations: CLLocationCoordinate2D.init(latitude: 32.4697, longitude: 74.2728)))
        placesArray.append(DataModel(title: "Test2", discipline: "Candle Shop", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 33.4697, longitude: 74.2728)))
        placesArray.append(DataModel(title: "Check", discipline: "Pumpkin Patch Farm", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 34.4697, longitude: 74.2728)))
        placesArray.append(DataModel(title: "John", discipline: "Wine & Spirits", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 35.4697, longitude: 74.2728)))
        placesArray.append(DataModel(title: "Allen", discipline: "Tattoo Artistry", url: "https://www.google.com", fav: false, locations: CLLocationCoordinate2D.init(latitude: 37.4697, longitude: 74.2728)))
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation), name: NSNotification.Name(rawValue: "mapData"), object: nil)
        for index in 0...placesArray.count-1 {
            let annotation = MKPointAnnotation()  // <-- new instance here
            annotation.coordinate = placesArray[index].location
            annotation.title = placesArray[index].title
            customeMapView.addAnnotation(annotation)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        addBottomSheetView()
    }
    
    func addBottomSheetView() {
        // 1- Init bottomSheetVC
        let bottomSheetVC = ScrollableBottomSheetViewController()

        // 2- Add bottomSheetVC as a child view
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)

        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: height/2, width: width, height: height)
    }
    
    @IBAction func searchLocationBtn(_ sender: Any)
    {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    @objc func updateLocation(notification:NSNotification){
        
        if let data = notification.userInfo?["data"] as? DataModel {
          // do something with your image
            
            openAddCreditView(modal: data)
            
            locateWithLongitude(data.location.longitude, andLatitude: data.location.latitude, andTitle: data.title)
          }
        
    }
    
    func openAddCreditView(modal:DataModel){
        // self.backView.isHidden = false
        addCredit.data = modal
        self.addChild(addCredit)
        self.view.addSubview(addCredit.view)
        addCredit.didMove(toParent: self)
        addCredit.view.frame = CGRect(x: 12.5, y: view.frame.height/2-100, width: 350, height: 220)
    }
}

extension ViewController: LocateOnTheMap,MKMapViewDelegate
{
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String)
    {
        
        print("Title: \(title)")
        print("Latitude: \(lat)")
        print("Longitude: \(lon)")

        let marker = MKPointAnnotation()
        marker.title = title
        marker.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        customeMapView.centerToLocation(initialLocation)
        customeMapView.addAnnotation(marker)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let reuseIdentifier = "MyIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.tintColor = .green                // do whatever customization you want
            annotationView?.canShowCallout = false            // but turn off callout
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // do something
        print(view.annotation?.coordinate)
        selectedLoc = view.annotation?.coordinate
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.addTarget(self, action: #selector(accesTap(cord:)), for: .touchUpInside)
        view.rightCalloutAccessoryView = rightButton
        
    }
    
    @objc func accesTap(cord: CLLocationCoordinate2D){
        
        self.openAddCreditView(modal: DataModel(title: "", discipline: "", url: "", fav: false, locations: selectedLoc!))
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension ViewController{
    static func vCardURL(from coordinate: CLLocationCoordinate2D, with name: String?) -> URL {
        let vCardFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("vCard.loc.vcf")
        
        let vCardString = [
            "BEGIN:VCARD",
            "VERSION:4.0",
            "FN:\(name ?? "Shared Location")",
            "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
            ].joined(separator: "\n")
        
        do {
            try vCardString.write(toFile: vCardFileURL.path, atomically: true, encoding: .utf8)
        } catch let error {
            print("Error, \(error.localizedDescription), saving vCard: \(vCardString) to file path: \(vCardFileURL.path).")
        }
        
        return vCardFileURL
    }
}
