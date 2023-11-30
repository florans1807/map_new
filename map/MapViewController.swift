//
//  MapViewController.swift
//  map
//
//  Created by Флоранс on 24.11.2023.
//

import UIKit
import MapKit
import CoreLocation
import Bottomsheet

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    
    private var chosenPin = ""
    
    private var queue = Queue<String>()
    
    private var pins = [MKAnnotation]()
    
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
        
        addPins()
        createQueueOfPins()
        
       customizeDetailView()
    }
    
    func customizeDetailView() {
        detailView.addShadow(color: .black, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        userImageView.layer.borderWidth = 2.0
        userImageView.layer.borderColor = UIColor.blue.cgColor
    }
    
    //getting current user location
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
    
    //adding custom annotations
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
        detailView.isHidden = true
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
            detailView.isHidden = true
            let coordinateOfAnnotation = anno.coordinate
            if anno.title != chosenPin && anno.title == queue.head {
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
    
    func saveImage() -> UIImage {
        let bottomImage = UIImage(named: "pin")!
        let topImage = UIImage(named: "face1")!

        let newSize = CGSizeMake(20, 20) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)

        bottomImage.draw(in: CGRect(origin: CGPointZero, size: newSize))
        topImage.draw(in: CGRect(origin: CGPointZero, size: newSize))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
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
            let imageViewOfPin: UIImageView = {
                var image = UIImageView()
                image.frame = CGRect(x: 23, y: 18, width: 65, height: 65)
                image.layer.masksToBounds = true
                image.layer.cornerRadius = 28.0
                image.backgroundColor = .white
                return image
            }()
            annotationView?.image = UIImage(named: "pin")
            annotationView?.addSubview(imageViewOfPin)
            imageViewOfPin.image = UIImage(named: "face2")
        case "Saul":
            let imageViewOfPin: UIImageView = {
                var image = UIImageView()
                image.frame = CGRect(x: 23, y: 18, width: 65, height: 65)
                image.layer.masksToBounds = true
                image.layer.cornerRadius = 28.0
                image.backgroundColor = .white
                return image
            }()
            annotationView?.image = UIImage(named: "pin")
            annotationView?.addSubview(imageViewOfPin)
            imageViewOfPin.image = UIImage(named: "face3")
        case "Walt":
            let imageViewOfPin: UIImageView = {
                var image = UIImageView()
                image.frame = CGRect(x: 23, y: 18, width: 65, height: 65)
                image.layer.masksToBounds = true
                image.layer.cornerRadius = 28.0
                image.backgroundColor = .white
                return image
            }()
            annotationView?.image = UIImage(named: "pin")
            annotationView?.addSubview(imageViewOfPin)
            imageViewOfPin.image = UIImage(named: "face1")
        default:
            break
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title {
            chosenPin = title ?? ""
        }
        
        switch chosenPin {
        case "Walt":
            userImageView.image = UIImage(named: "face1")
        case "Mike":
            userImageView.image = UIImage(named: "face2")
        case "Saul":
            userImageView.image = UIImage(named: "face3")
        default:
            break
        }
        
        nameLabel.text = chosenPin
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        dateBtn.setTitle(format.string(from: Date()), for: .normal)
        timeBtn.setTitle(self.dateFormatting(), for: .normal)
        
        detailView.isHidden = false
    }
        
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        chosenPin = ""
        detailView.isHidden = true
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
