//
//  Station.swift
//  Test
//
//  Created by doremin on 26/07/2018.
//  Copyright © 2018 doremin. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    
    init (text: String, coordinate: CLLocationCoordinate2D) {
        self.title = text
        self.coordinate = coordinate
        
        
        super.init()
    }
}
