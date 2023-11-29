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
    
    private var chosenPin = ""
    
    private var queue = Queue<String>()
    
    private var pins = [MKAnnotation]()
    
    let customView: UIView = {
        var view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.isHidden = true
        return view
    }()
        
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
        //mapView.bringSubviewToFront(customView)
        //setBottomView()
        addPins()
        createQueueOfPins()
    }
    
    func setBottomView() {
        customView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
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
        point2.coordinate = CLLocationCoordinate2D(latitude: 56.149291, longitude: 47.163708)
        self.mapView.addAnnotation(point2)
        
        let point3 = MKPointAnnotation()
        point3.title = "Walt"
        point3.subtitle = "GPS," + self.dateFormatting()
        point3.coordinate = CLLocationCoordinate2D(latitude: 56.100937, longitude: 47.272647)
        self.mapView.addAnnotation(point3)
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
    
    @IBAction func moveToAnotherPin() {
        for anno in pins {
            let coordinateOfAnnotation = anno.coordinate
            let abc = queue.head
            if anno.title != chosenPin && anno.title == abc {
                queue.removeAndAppendFirst()
                
                if let title = anno.title {
                    chosenPin = title ?? ""
                }
                
                let region = self.mapView.regionThatFits(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinateOfAnnotation.latitude, longitude: coordinateOfAnnotation.longitude), latitudinalMeters: 200, longitudinalMeters: 200))
               self.mapView.setRegion(region, animated: true)
                
                break
            }
        }
        
    }
    
    func createQueueOfPins() {
        for anno in mapView.annotations {
            if let title = anno.title, !pins.contains(where: { $0.title == title }) {
                pins.append(anno)
                queue.enqueue(title!)
            }
        }
    }
    
    func dateFormatting() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let mydt = dateFormatter.string(from: date).capitalized

        return "\(mydt)"
    }
    
//    func showPopup() {
//        guard let popupViewController = CustomPopupVIew.instantiate() else { return }
//        popupViewController.delegate = self
//        
//        let popupVC = Pop
//    }
}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.canShowCallout = true
        
        switch annotation.title {
        case "User Location":
            annotationView?.image = UIImage(named: "user_location")
            annotationView?.canShowCallout = false
        case "Mike":
            annotationView?.image = UIImage(named: "pin")
            annotationView?.tintColor = .blue
        case "Saul":
            annotationView?.image = UIImage(named: "pin")
            annotationView?.tintColor = .green
        default:
            annotationView?.image = UIImage(named: "pin")
            annotationView?.tintColor = .red
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title {
            chosenPin = title ?? ""
        }
    }
        
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        chosenPin = ""
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //addPins()
    }
}

struct Queue<T> {
  private var elements: [T] = []

  mutating func enqueue(_ value: T) {
    elements.append(value)
  }

  mutating func dequeue() -> T? {
    guard !elements.isEmpty else {
      return nil
    }
    return elements.removeFirst()
  }

  mutating func removeAndAppendFirst() {
      if let element = elements.first {
          elements.removeFirst()
          elements.append(element)
      }
  }

  var head: T? {
    return elements.first
  }

  var tail: T? {
    return elements.last
  }
}

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}
