//
//  MapViewController.swift
//  map
//
//  Created by Флоранс on 24.11.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        //addPins()
                
//        locationManager = CLLocationManager()
//        locationManager.requestAlwaysAuthorization()
//        
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.delegate = self
//        locationManager.startUpdatingLocation()
//
//        mapView.showsUserLocation = true
//        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //checkLocationEnabled()
    }
    
    func updateLocationOnMap(to location: CLLocation, with title: String?)
    {
        var isUserLocationAnnotationExist = false
        
        for anno in mapView.annotations {
            if anno.title == "User Location" {
                isUserLocationAnnotationExist = true
                break
            }
        }
        
        if !isUserLocationAnnotationExist {
            let point = MKPointAnnotation()
            point.title = title
            point.coordinate = location.coordinate
            self.mapView.addAnnotation(point)
        }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        self.mapView.setRegion(region, animated: true)
    }
    
    func addPins() {
        let point1 = MKPointAnnotation()
        point1.title = "Mike"
        point1.subtitle = "GPS," + self.dateFormatting()
        point1.coordinate = CLLocationCoordinate2D(latitude: 56.152231211472646, longitude: 47.17689228042594)
        self.mapView.addAnnotation(point1)
        
        let point2 = MKPointAnnotation()
        point2.title = "Saul"
        point2.subtitle = "GPS," + self.dateFormatting()
        point2.coordinate = CLLocationCoordinate2D(latitude: 59.152231211472646, longitude: 49.17689228042594)
        self.mapView.addAnnotation(point2)
    }
    
    @IBAction func onLocationButtonTapped() {
        updateLocationOnMap(to: locationManager.location ?? CLLocation(), with: "User Location")
    }
    
    @IBAction func plusZoomTapped() {
    
        var region = self.mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        self.mapView.setRegion(region, animated: true)
    }
    
    @IBAction func minusZoomTapped() {
        var region = self.mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    func dateFormatting() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let mydt = dateFormatter.string(from: date).capitalized

        return "\(mydt)"
    }
    
//    func checkLocationEnabled() {
//        if CLLocationManager.locationServicesEnabled() {
//            setupManager()
//            checkAuthorization()
//        } else {
//            showAlertLocation(title: "Geolocation is off", message: "Switch on?", url: URL(string: "App-Prefs:root=LOCATION_SERVICES"))
//        }
//    }
//    
//    func setupManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    func checkAuthorization() {
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedAlways:
//            break
//        case .authorizedWhenInUse:
//            mapView.showsUserLocation = true
//            locationManager.startUpdatingLocation()
//            break
//        case .denied:
//            showAlertLocation(title: "Using geo is banned", message: "Change it?", url: URL(string: UIApplication.openSettingsURLString))
//            break
//        case .restricted:
//            break
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//            
//        }
//    }
//    
//    func showAlertLocation(title: String, message: String?, url: URL?) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        let settings = UIAlertAction(title: "Настройки", style: .default) { (alert) in
//            if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
//        
//        alert.addAction(settings)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
    
}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            
//        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            annotationView?.annotation = annotation
        }
        
        switch annotation.title {
        case "User Location":
            annotationView?.image = UIImage(named: "user_location")
        case "Rob":
            let imageView = UIImageView(image: UIImage(named: "pin"))
            annotationView?.rightCalloutAccessoryView = imageView
        case "Bob":
            annotationView?.image = UIImage(named: "pin")
        default:
            annotationView?.image = UIImage(named: "pin")
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        addPins()
//        let point1 = MKPointAnnotation()
//        point1.title = "Rob"
//        point1.coordinate = CLLocationCoordinate2D(latitude: 51.519066, longitude: -0.135200)
//        self.mapView.addAnnotation(point1)
//        
//        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.519066, longitude: -0.135200), latitudinalMeters: 200, longitudinalMeters: 200))
//        self.mapView.setRegion(region, animated: true)
        
//        if let coordinate = locationManager.location?.coordinate {
//            let point = MKPointAnnotation()
//            point.title = "Bob"
//            point.subtitle = "I'm here!!!"
//            point.coordinate = CLLocationCoordinate2D(latitude: 56.152231211472646, longitude: 47.17689228042594)
//            self.mapView.addAnnotation(point)
//            
//            //            let region = self.mapView.regionThatFits(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.519066, longitude: -0.135200), latitudinalMeters: 200, longitudinalMeters: 200))
//            //            self.mapView.setRegion(region, animated: true)
//        }
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last?.coordinate {
//            let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000, longitudinalMeters: 5000)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkAuthorization()
//    }
}
