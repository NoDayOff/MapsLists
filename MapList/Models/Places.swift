//
//  Places.swift
//  MapList
//
//  Created by Usama Ali on 30/01/2021.
//

import Foundation
import MapKit

class DataModel
{
    var title : String
    var discipline : String
    var url: String
    var isFav : Bool
    var location : CLLocationCoordinate2D
    
    init(title: String, discipline: String, url: String, fav: Bool,locations : CLLocationCoordinate2D) {
        self.title = title
        self.discipline = discipline
        self.url = url
        self.isFav = fav
        self.location = locations
    }
}
