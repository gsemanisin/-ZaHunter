//
//  ViewController.swift
//  'ZaHunter
//
//  Created by Gwyneth Semanisin on 5/22/19.
//  Copyright © 2019 Gwyneth Semanisin. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var pizza: [MKMapItem] = []
    var address: String! = ""
    var coordinate : (Double, Double) = (0,0)
    //var coordinatesOfLoc: CLLocationCoordinate2D
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        
        let location = locations.first
        if location!.verticalAccuracy < 1000.0 && location!.horizontalAccuracy < 1000.0 {
            //print("Location Found! Reverse Geocoding…")
            reverseGeocode(location: location!)
            locationManager.stopUpdatingLocation()
        }

        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    

    @IBAction func onSearchPressed(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pizza"
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: span)
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { (responce, error) in
            guard let responce = responce else {return}
            for mapItem in responce.mapItems{
                self.pizza.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                print(annotation.coordinate)
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "pizza")
        pin.canShowCallout = true
        pin.isEnabled = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        if annotation.isEqual(mapView.userLocation){
            return nil
        } else{
            return pin
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //alert
        let alertController = UIAlertController(title: "Address", message: "\(address!)", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Thank you", style: .default, handler: nil)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
        
        
        print("this is a print statement")
    }
    
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            let placemark = placemarks?.first
            if let subthoroughfare = placemark?.subThoroughfare {
                self.address = "\(subthoroughfare) \(placemark!.thoroughfare!) \n \(placemark!.locality!), \(placemark!.administrativeArea!)"
                print(self.address!)
                
            } else {
                print("no subthoroughfare")
            }
        }
        
    }
    
    func dropPinFor(placemark: MKPlacemark) {
        //selectedItemPlacemark = placemark
        
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                // mapView.removeAnnotation(annotation) // removing the pins from the map
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        self.coordinate = (placemark.coordinate.latitude, placemark.coordinate.longitude)
        
        print("This is the pins destinations coord \(coordinate)")
    }
    
}

