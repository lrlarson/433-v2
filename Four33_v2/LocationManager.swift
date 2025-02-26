//
//  LocationManager.swift
//  Four33_v2
//
//  Created by PKSTONE on 2/24/25.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    var lastAuthorized = false
    
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            return
        case .restricted, .denied:
            lastAuthorized = false
            return
        case .authorizedAlways, .authorizedWhenInUse:
            lastAuthorized = true
            lastKnownLocation = manager.location?.coordinate
            return
        @unknown default:
            lastAuthorized = false
            return
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {//Trigged every time authorization status changes
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
     }
}
