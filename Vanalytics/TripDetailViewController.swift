//
//  TripDetailViewController.swift
//  Vanalytics
//
//  Created by Apple on 28/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//



import UIKit
import MapKit
import VinliNet
import CoreLocation



class TripDetailViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!


    
    
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
    var tripDateArray = [String]()
    var startAdd = [String]()
    var endAdd = [String]()
    var startCoordinate: CLLocation!
    var endCoordinate: CLLocation!
    var preview: String!
    let locationManager = CLLocationManager()
    var stream : VLStream!
    var tripDetailArray1 = [TripDetail]()
    var testOne: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%")
        tableView.delegate = self
        tableView.dataSource = self
        print("################device.name --- \(device.name)")
        print("#############self.testOne - \(self.testOne)")
        
        print("###########tripDetailArray1.count - \(tripDetailArray1.count)")
        print("###########tripDetailArray1.date - \(tripDetailArray1[0].startDate)")
        print("###########tripDetailArray1.date - \(tripDetailArray1[1].startDate)")
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripDetailArray1.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: tripCell = tableView.dequeueReusableCell(withIdentifier: "tripcell", for: indexPath) as! tripCell
        
        cell.tMapView.delegate = self
        
        
        
        if self.tripDetailArray1.count > 0{
            print("row - \(indexPath.row)")
            print("date text - \(self.tripDetailArray1[indexPath.row].startDate)")
            
            CLGeocoder().reverseGeocodeLocation(self.tripDetailArray1[indexPath.row].startloc, completionHandler: { (startplacemarks: [CLPlacemark]?, error: Error?) in
                if let startplacemarks = startplacemarks {
                    let startplacemark = startplacemarks[0]
                    // print("startplacemark - \(startplacemark)")
                    let startaddname1 = "\(startplacemark.name!), \(startplacemark.locality!)"
                   // , \(startplacemark.subAdministrativeArea!)"
                    //let startaddname2 = ",\(startplacemark.administrativeArea!), \(startplacemark.postalCode!)"
                   // let startad = startaddname1 + startaddname2
                    
                    cell.tStartAdd.text = startaddname1
                    self.tripDetailArray1[indexPath.row].startlocDesc = startaddname1
                  
                    
                    
                   
                }
                
            })
            
            CLGeocoder().reverseGeocodeLocation(self.tripDetailArray1[indexPath.row].stoploc , completionHandler: { (endplacemarks: [CLPlacemark]?, error: Error?) in
                if let endplacemarks = endplacemarks {
                    let endplacemark = endplacemarks[0]
                    //    print("endplacemark - \(endplacemark)")
                    let endaddname1 = "\(endplacemark.name!), \(endplacemark.locality!)"
                    //, \(endplacemark.subAdministrativeArea!)"
                   // let endaddname2 = ",\(endplacemark.administrativeArea!), \(endplacemark.postalCode!)"
                   // let endad = endaddname1 + endaddname2
                     cell.tEndAdd.text = endaddname1
                      self.tripDetailArray1[indexPath.row].stoplocDesc = endaddname1
                }
                
            })

            
            //let datetext = self.tripDetailArray1[indexPath.row].startDate as VLDataType
            
            cell.tDate.text = self.tripDetailArray1[indexPath.row].startDate
            
            self.startCoordinate = self.tripDetailArray1[indexPath.row].startloc
            self.endCoordinate = self.tripDetailArray1[indexPath.row].stoploc
            self.preview = self.tripDetailArray1[indexPath.row].preview
           // print("##self.preview ---- \(self.preview)")
            if let startlocation = self.startCoordinate, let endLocation = self.endCoordinate {
                let startCoord = self.startCoordinate
                let endCoord = self.endCoordinate
                
                
                //  let coordinate = CLLocationCoordinate2DMake(startloc.latitude, startloc.longitude)
                let endpin = MKPointAnnotation()
                endpin.coordinate = (endCoord?.coordinate)!
                //  endpin.coordinate.longitude = endloc.longitude
                endpin.title = "Destination"
                
                let startpin = MKPointAnnotation()
                startpin.coordinate = (startCoord?.coordinate)!
                //  startpin.coordinate.longitude = startloc.longitude
                startpin.title = "Start"
                
                var annotations = [MKAnnotation]()
                annotations.append(startpin)
                annotations.append(endpin)
                
                let polyline = Polyline(encodedPolyline: self.preview)
                let decodedCoordinates: [CLLocationCoordinate2D]? = polyline.coordinates
                let coordinatesCount = decodedCoordinates?.count
                
                let myPolyline = MKPolyline(coordinates: decodedCoordinates!, count: coordinatesCount!)
                let rect = myPolyline.boundingMapRect
                //self.tripMapView.add(myPolyline)
                cell.tMapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: false)
                cell.tMapView.addAnnotations(annotations)
                cell.tMapView.add(myPolyline, level: MKOverlayLevel.aboveRoads)
            }

        }
        return cell
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // if overlay is MKPolyline {
        var polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 1
        return polylineRenderer
        //   }
        
    }
    
    
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier{
            if (id == "tripMoreDetailSegue") {
                let newTripVc = segue.destination as! TripMoreDetailsViewController
                var indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                newTripVc.device = device
                let index = indexPath?.row
                newTripVc.moreTripDetail = self.tripDetailArray1[index!]
            }
        }
    }
    
}






