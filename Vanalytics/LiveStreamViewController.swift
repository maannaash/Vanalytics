//
//  LiveStreamViewController.swift
//  Vanalytics
//
//  Created by Apple on 18/02/17.
//  Copyright © 2017 maannaash. All rights reserved.
//




import UIKit
import MapKit
import VinliNet


class LiveStreamViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var vinli:VLService!
    var device:VLDevice!
    var currentLocation: VLLocation!
    var myLocation: CLLocation!
    var region: MKCoordinateRegion!
    var annoArray = [MKPointAnnotation]()
    fileprivate var places = [Place]()
    
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arViewController: ARViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        //let coordinate = currentLocation.coordinate
        //region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)


        
        //create pin and drop on map
     //   let pin = MKPointAnnotation()
     //   pin.coordinate.latitude = self.currentLocation.latitude
     //   pin.coordinate.longitude = self.currentLocation.longitude
     //   pin.title = self.device.name
     //   self.mapView.addAnnotation(pin)
        
    }
    

    func displayNearbyPlaces(forplace placename: String, iconimage imagename: String) {
        
        if self.annoArray != nil {

            if self.annoArray.count > 0 {
                self.mapView.removeAnnotations(self.annoArray)
            }
        }
        
        if self.places != nil {
            self.places = [Place]()
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = placename
        request.region = self.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {
                return
            }
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                let placeLocation: CLLocation = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                let place = Place(location: placeLocation, reference: imagename, name: item.name!, address: "")
                self.places.append(place)
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annotation)
                    self.annoArray.append(annotation)
                }
            }
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(places)
        arViewController.uiOptions.debugEnabled = false
        arViewController.uiOptions.closeButtonEnabled = true
        self.present(arViewController, animated: true, completion: nil)
        
    }
    
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        arViewController.present(alert, animated: true, completion: nil)
    }
    

    
    
    @IBAction func findMeHospital(_ sender: Any) {
      //  displayNearbyPlaces(forplace: "Hospitals")
        displayNearbyPlaces(forplace: "Hospitals", iconimage: "hospital")
    }

    @IBAction func findMeGasStation(_ sender: Any) {
        //displayNearbyPlaces(forplace: "Gas Stations")
        displayNearbyPlaces(forplace: "Gas Stations", iconimage: "gasstation")
    }
    
    @IBAction func findMeRestaurant(_ sender: Any) {
        //displayNearbyPlaces(forplace: "Restaurants")
        displayNearbyPlaces(forplace: "Restaurants", iconimage: "restaurant")
    }
    
    @IBAction func FindMeAutoService(_ sender: Any) {
       // displayNearbyPlaces(forplace: "Auto Service")
        displayNearbyPlaces(forplace: "Auto Service", iconimage: "carservice")
        
    }
    
    @IBAction func findMeHotels(_ sender: Any) {
       // displayNearbyPlaces(forplace: "Hotels")
        displayNearbyPlaces(forplace: "Hotels", iconimage: "hotel")
    }
    
    @IBAction func findMeBanks(_ sender: Any) {
        //displayNearbyPlaces(forplace: "Bank")
        displayNearbyPlaces(forplace: "Bank", iconimage: "bank")
    }
    
    @IBAction func findMeAttractions(_ sender: Any) {
        //displayNearbyPlaces(forplace: "Attractions")
        displayNearbyPlaces(forplace: "Movies", iconimage: "movie1")
    }
    
    @IBAction func findCoffee(_ sender: Any) {
        // displayNearbyPlaces(forplace: "Coffee Shops")
        displayNearbyPlaces(forplace: "Coffee Shops", iconimage: "coffee")
    }
    
}


extension LiveStreamViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 180, height: 50)
        
        return annotationView
    }
}

extension LiveStreamViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            self.showInfoView(forPlace: annotation)
        }
        
    }
}

extension LiveStreamViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0  {
            let location = locations.last!
            manager.stopUpdatingLocation()
            let myPin = MKPointAnnotation()
            myPin.coordinate = location.coordinate
            myPin.title = "My Location"
            self.myLocation = location
            let coordinate = myLocation.coordinate
            region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    
}


