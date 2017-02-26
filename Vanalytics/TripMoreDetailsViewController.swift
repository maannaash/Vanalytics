//
//  TripMoreDetailsViewController.swift
//  Vanalytics
//
//  Created by Apple on 30/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit
import MapKit
import VinliNet

class TripMoreDetailsViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var tripMapView: MKMapView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    @IBOutlet weak var fuelConsumedLabel: UILabel!
 
    @IBOutlet weak var mpgLabel: UILabel!

    @IBOutlet weak var fuelEconomyLabel: UILabel!
    
    @IBOutlet weak var startAddressLabel: UILabel!
    
    @IBOutlet weak var endAddressLabel: UILabel!
    
    @IBOutlet weak var driverscorelabel: UILabel!
    
    @IBOutlet weak var engineloadlabel: UILabel!
    
    @IBOutlet weak var hardbrakeslabel: UILabel!
    
    
    
    
    var vinli:VLService!
    var device:VLDevice!
    var latestLocation:VLLocation!
    var latestVehicle:VLVehicle!
    var batteryStatus:String!
    var fuelLevel:Int!
    var index:Int!
    var latestEvent:VLEvent!
    var deviceTrip:VLTrip!
    var rule:VLRule!
    var tMsg: VLTelemetryMessage!
    var tripsCount: Int!
    var startCoordinate: CLLocation!
    var endCoordinate: CLLocation!
    var preview:String!
    var rptcrd: VLReportCard!
    var moreTripDetail : TripDetail!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tripMapView.delegate = self
        
        self.startCoordinate = self.moreTripDetail.startloc
        self.endCoordinate = self.moreTripDetail.stoploc
        self.preview = self.moreTripDetail.preview
        if let startlocation = self.startCoordinate, let endLocation = self.endCoordinate {
            self.getTripLocations(startloc: startlocation  , endloc: endLocation, previewstr: self.preview)
        }
        self.avgSpeedLabel.text = self.moreTripDetail.avgSpeed
        self.distanceLabel.text = self.moreTripDetail.distance
        self.durationLabel.text = self.moreTripDetail.duration
        self.fuelConsumedLabel.text = self.moreTripDetail.stopCounts
        self.fuelEconomyLabel.text = self.moreTripDetail.fuelEconomy
        self.mpgLabel.text = self.moreTripDetail.maxSpeed
        self.startAddressLabel.text = self.moreTripDetail.startlocDesc
        self.endAddressLabel.text = self.moreTripDetail.stoplocDesc
        self.engineloadlabel.text = self.moreTripDetail.engineload
        self.hardbrakeslabel.text = self.moreTripDetail.hardbrakes
          self.driverscorelabel.text = self.moreTripDetail.reportCard
        if self.moreTripDetail.reportCard == "A" {
            self.driverscorelabel.textColor = UIColor.green
        }else {
            self.driverscorelabel.textColor = UIColor.orange
        }
      
        
    }




    func getTripLocations(startloc:CLLocation , endloc:CLLocation, previewstr: String) {

        
        let startCoord = startloc.coordinate
        let endCoord = endloc.coordinate
        
        
      //  let coordinate = CLLocationCoordinate2DMake(startloc.latitude, startloc.longitude)
        let endpin = MKPointAnnotation()
        endpin.coordinate = endCoord
      //  endpin.coordinate.longitude = endloc.longitude
        endpin.title = "Destination"
        
        
        
        let startpin = MKPointAnnotation()
        startpin.coordinate = startCoord
      //  startpin.coordinate.longitude = startloc.longitude
        startpin.title = "Start"
        
        var annotations = [MKAnnotation]()
        annotations.append(startpin)
        annotations.append(endpin)
        
        let polyline = Polyline(encodedPolyline: previewstr)
        let decodedCoordinates: [CLLocationCoordinate2D]? = polyline.coordinates
        let coordinatesCount = decodedCoordinates?.count
        
        
        let myPolyline = MKPolyline(coordinates: decodedCoordinates!, count: coordinatesCount!)
        let rect = myPolyline.boundingMapRect
        //self.tripMapView.add(myPolyline)
        self.tripMapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: false)
        self.tripMapView.addAnnotations(annotations)
        self.tripMapView.add(myPolyline, level: MKOverlayLevel.aboveRoads)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       // if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 1
            return polylineRenderer
     //   }

    }
    
    
}
