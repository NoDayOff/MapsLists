//
//  ViewController.swift
//  MapList
//
//  Created by Usama Ali on 28/01/2021.
//

import UIKit
import MapKit



class ViewController: UIViewController, UISearchBarDelegate
{
    var selectedLoc : CLLocationCoordinate2D?
    @IBOutlet weak var customeMapView: MKMapView!
    @IBOutlet weak var searchBtnUI: UIButton!
    let addCredit: ImageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
    let locationManager = CLLocationManager()
//    var mapView: GMSMapView?
    
    var placesArray : [Places] = []
    var resultsArray: [Places] = []
    
    
    let loc1 : Places = Places.init(Title: "Johar Town", subTitle: "Lahore", Location: CLLocationCoordinate2D.init(latitude: 31.4697, longitude: 74.2728), image: UIImage(named: "foodd")!)
    let loc2 : Places = Places.init(Title: "Wapda Town", subTitle: "Lahore", Location: CLLocationCoordinate2D.init(latitude: 32.4697, longitude: 74.2728), image: UIImage(named: "foodd")!)
    let loc3 : Places = Places.init(Title: "DHA Phase 6", subTitle: "Lahore", Location: CLLocationCoordinate2D.init(latitude: 33.4697, longitude: 74.2728), image: UIImage(named: "foodd")!)
    let loc4 : Places = Places.init(Title: "Paragon City", subTitle: "Lahore", Location: CLLocationCoordinate2D.init(latitude: 34.4697, longitude: 74.2728), image: UIImage(named: "foodd")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customeMapView.delegate = self
        
        
        placesArray.append(loc1)
        placesArray.append(loc2)
        placesArray.append(loc3)
        placesArray.append(loc4)
        
        for index in 0...placesArray.count-1 {
            let annotation = MKPointAnnotation()  // <-- new instance here
            annotation.coordinate = placesArray[index].Location
            annotation.title = placesArray[index].Title
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
    
//    @IBAction func searchLocationBtn(_ sender: Any)
//    {
//        let searchController = UISearchController(searchResultsController: searchResultController)
//        searchController.searchBar.delegate = self
//        self.present(searchController, animated: true, completion: nil)
//    }
    
    
    @objc func updateLocation(notification:NSNotification){
        
        if let data = notification.userInfo?["data"] as? DataModel {
          // do something with your image
            
            //openAddCreditView(modal: data)
            
            locateWithLongitude(loc1.Location.longitude, andLatitude: loc1.Location.latitude, andTitle: loc1.Title)
          }
        
    }
    
    func openAddCreditView(modal:Places){
        // self.backView.isHidden = false
        addCredit.data = modal
        self.addChild(addCredit)
        self.view.addSubview(addCredit.view)
        addCredit.didMove(toParent: self)
        addCredit.view.frame = CGRect(x: 12.5, y: view.frame.height/2-100, width: 350, height: 220)
    }
}

extension ViewController:MKMapViewDelegate
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
        
        self.openAddCreditView(modal: placesArray[0])
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
