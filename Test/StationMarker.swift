//
//  StationMarker.swift
//  Test
//
//  Created by doremin on 26/07/2018.
//  Copyright © 2018 doremin. All rights reserved.
//

import Foundation
import MapKit

class StationsMarker: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let station = newValue as? Station else {
                return
            }
            
            markerTintColor = UIColor(hexString: "#38acf7")
            glyphText = station.title
            canShowCallout = true
            titleVisibility = .hidden
            
            
            let view = UIView()
            view.frame.size = CGSize(width: 500, height: 500)
            view.backgroundColor = UIColor.black
            
            
            detailCalloutAccessoryView = view
        
            
        }
    }
}
