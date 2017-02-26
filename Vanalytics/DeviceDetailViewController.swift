//
//  DeviceDetailViewController.swift
//  Vanalytics
//
//  Created by Apple on 24/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit
import MapKit
import VinliNet

class DeviceDetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var batteryStatusLabel: UILabel!
    @IBOutlet weak var gasStatusLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carDetailLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var findMyCarButtonPressed: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    
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
    var address: String!

    
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arViewController: ARViewController!
    fileprivate var places = [Place]()
    var tripDetailArray = [TripDetail]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if VLSessionManager.loggedIn() {
            carNameLabel.text = ""
            vinli = VLService.init(session: VLSessionManager.currentSession())
            carNameLabel.text = device.name
            getLocationForDevice()
            getLatestVehicleDetails()
            getFuelLevel(device: device)
            getTripsinfo(device: device)
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
            mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
            
        }
        
        let rbarViewControllers = self.tabBarController?.viewControllers

        if let ruleVC = rbarViewControllers?[3] as? RuleViewController {
           ruleVC.mydevice  = self.device
        }
        
        
    }
    
    @IBAction func FindButtonPressed(_ sender: Any) {
        
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
    
    
    

    //get device location and drop pin on map
    func getLocationForDevice() {
        vinli.getLocationsForDevice(withId: device.deviceId, limit: 1, until: nil, since: nil, sortDirection: nil, onSuccess: {(locationPager: VLLocationPager?, response: HTTPURLResponse?) in
            if let location = locationPager?.locations[0]{
                self.latestLocation = location as! VLLocation
                //create a coordinate to set region/zoom
                
                let nbarViewControllers = self.tabBarController?.viewControllers
                print("@@@@@@@@@@barViewControllers?.count -- \(nbarViewControllers?.count)")
                if let lstreamVC = nbarViewControllers?[2] as? LiveStreamViewController {
                    print("^^^^^^^^^^^^^^^^^^^####")
                    lstreamVC.device = self.device
                    lstreamVC.currentLocation = self.latestLocation
                }
            
                
                let coordinate = CLLocationCoordinate2DMake(self.latestLocation.latitude, self.latestLocation.longitude)
                let region = MKCoordinateRegionMakeWithDistance(coordinate, 200, 200)
                self.mapView.setRegion(region, animated: false)
                
                let myloc : CLLocation = CLLocation(latitude: self.latestLocation.latitude, longitude: self.latestLocation.longitude)
                
                CLGeocoder().reverseGeocodeLocation(myloc, completionHandler: { (endplacemarks: [CLPlacemark]?, error: Error?) in
                    if let endplacemarks = endplacemarks {
                        let endplacemark = endplacemarks[0]
                        var address = "\(endplacemark.name!), \(endplacemark.locality!), \(endplacemark.subAdministrativeArea!)"
                        var add1 = ",\(endplacemark.administrativeArea!), \(endplacemark.postalCode!)"

                        let newadd = address + add1

                        self.addressLabel.text = newadd
                    }
                    
                })
                
                //create pin and drop on map
                let pin = MKPointAnnotation()
                pin.coordinate.latitude = self.latestLocation.latitude
                pin.coordinate.longitude = self.latestLocation.longitude
                pin.title = self.device.name
                self.mapView.addAnnotation(pin)
            }
            
        }) { (error: Error?, response:HTTPURLResponse?, bodyString: String?) in
            print("error getting locations: \(bodyString)")
        }
    }
    
    
    func getLatestVehicleDetails(){
        vinli.getLatestVehicleForDevice(withId: device.deviceId, onSuccess: { (vehicle:VLVehicle?, response:HTTPURLResponse?) in
            if let car = vehicle {
                self.latestVehicle = car
                self.setVehicleLabel(vehicle: self.latestVehicle)
                self.getBatteryStatus(vehicle : self.latestVehicle)
                self.getOdometer(vehicle: car)
                self.getDTC()
                
            }
        }) { (error:Error?, response:HTTPURLResponse?, bodyString:String?) in
            print("error getting latest Vehicle details: \(bodyString)")
        }
    }
    
    
    func getDTC() {
    
        vinli.getDtcsForVehicle(withId: self.latestVehicle.vehicleId, timeSeries: VLTimeSeries.init(fromPreviousNumberOfWeeks: 5), onSuccess: { (dtcPager: VLDtcPager?, response: HTTPURLResponse?) in
            
            if let dtcpager = dtcPager {
                if dtcpager.codes.count > 0  {
                    if let code = dtcpager.codes[0] as? VLDtc {
                        
                        print("code.codeId --- \(code.codeId)")
                        print("code.codeDescription --- \(code.codeDescription)")
                        print("code.PID --- \(code.pid)")
                        self.errorLabel.text = code.codeDescription!
                        self.errorLabel.textColor = UIColor.red
                      
                    }
                }
            }
            
        }) { (error:Error?, response:HTTPURLResponse?, bodyString:String?) in
            print("error getting latest Vehicle details: \(bodyString)")
        }
    
    }
    
    func setVehicleLabel(vehicle:VLVehicle) {
        
        var vString = "unknown"
        if let year = vehicle.year {
            vString = year
        }
        if let make = vehicle.make {
            vString += " \(make)"
        }
        if let model = vehicle.model {
            vString += " \(model)"
        }
        self.carDetailLabel.text = vString
    }
    
    
    func getBatteryStatus(vehicle:VLVehicle){
        
        vinli.getCurrentBatteryStatus(withVehicleId: vehicle.vehicleId, onSuccess: { (status:VLBatteryStatus?, response:HTTPURLResponse?) in
            self.batteryStatusLabel.text = ""
            if let status = status {
                if status.status == .green {
                    self.batteryStatus = "green"
                    self.batteryStatusLabel.text = "Green"
                    self.batteryStatusLabel.textColor = UIColor.green
                }
                if status.status == .yellow {
                    self.batteryStatus = "Orange"
                    self.batteryStatusLabel.text = "Orange"
                    self.batteryStatusLabel.textColor = UIColor.orange
                }
                if status.status == .red {
                    self.batteryStatus = "red"
                    self.batteryStatusLabel.text = "Red"
                    self.batteryStatusLabel.textColor = UIColor.red
                }
            }
        }) { (error: Error?, response: HTTPURLResponse?, bodyString: String?) in
            print("error getting battery status \(bodyString)")
        }
    }
    
    //fuel level
    func getFuelLevel(device:VLDevice){
        
        print("@@@@@@getting fuel")
        
        vinli.getSnapshotsForDevice(withId: device.deviceId, fields: "fuelLevelInput", onSuccess: { (pager: VLSnapshotPager?, response:HTTPURLResponse?) in
            
            print("@@@@@@getting fuel1111")
            if (pager?.snapshots.count)! > 0 {
                 print("pager?.snapshots.count -- \(pager?.snapshots.count)")
                print("pager?.snapshots - \(pager?.snapshots)")
                if let snap = pager?.snapshots[0]{
                    let fuelSnap = snap as! VLSnapshot
                    print("fuelSnap.data  -- \(fuelSnap.data)")
                    self.fuelLevel = fuelSnap.data["fuelLevelInput"] as? Int
                    let fuelString = self.fuelLevel.description
                    let fuelInt = Int(fuelString)
                    self.gasStatusLabel.text = "\(fuelString) %"
                    if fuelInt! > 40 {
                       // self.gasStatusLabel.backgroundColor = UIColor.green
                        self.gasStatusLabel.textColor = UIColor.green
                    }
                    if fuelInt! < 40 && fuelInt! > 25 {
                        //self.gasStatusLabel.backgroundColor = UIColor.orange
                          self.gasStatusLabel.textColor = UIColor.orange
                    }
                    if fuelInt! < 25 {
                       // self.gasStatusLabel.backgroundColor = UIColor.red
                        self.gasStatusLabel.textColor = UIColor.red
                    }
                }
                
            }

            
            
        }) { (error: Error?, response: HTTPURLResponse?, bodyString: String?) in
            print("fuel error - \(error)")
            print("error getting fuel level for the device \(bodyString)")
        }
        
        
        
        
        
     /*   vinli.getSnapshotsForDevice(withId: device.deviceId, fields: "fuelLevelInput", limit: 1, until: nil, since: nil, sortDirection: nil, onSuccess: { (pager: VLSnapshotPager?, response: HTTPURLResponse?) in
            
            print("@@@@@@getting fuel1111")
            if (pager?.snapshots.count)! > 0 {
                if let snap = pager?.snapshots[0]{
                    let fuelSnap = snap as! VLSnapshot
                    self.fuelLevel = fuelSnap.data["fuelLevelInput"] as? Int
                    let fuelString = self.fuelLevel.description
                    let fuelInt = Int(fuelString)
                    self.gasStatusLabel.text = "\(fuelString) %"
                    if fuelInt! > 60 {
                        self.gasStatusLabel.backgroundColor = UIColor.green
                    }
                    if fuelInt! < 60 && fuelInt! > 25 {
                        self.gasStatusLabel.backgroundColor = UIColor.orange
                    }
                    if fuelInt! < 25 {
                        self.gasStatusLabel.backgroundColor = UIColor.red
                    }
                }
                
            }
            
        }) { (error: Error?, response: HTTPURLResponse?, bodyString: String?) in
            print("fuel error - \(error)")
            print("error getting fuel level for the device \(bodyString)")
        } */
        
        print("@@@Fuel done")
    }
    
    //odometer
    func getOdometer(vehicle:VLVehicle) {
        vinli.getDistancesForVehicle(withId: vehicle.vehicleId, onSuccess: { (pager: VLDistancePager?, response: HTTPURLResponse?) in
            
            if let lastDistance = pager?.distances[0] {
                let distance = lastDistance as! VLDistance
                let distanceInMiles = Int(round(Double(distance.value.intValue) * 0.00062137))
                self.odometerLabel.text = "\(distanceInMiles) Miles"
            }
            
        }) { (error: Error?, responst: HTTPURLResponse?, bodyString: String?) in
            print("error getting current odometer for vehicle: \(bodyString)")
        }
    }
    
    //Trips
    func getTripsinfo(device:VLDevice){
        vinli.getTripsForDevice(withId: device.deviceId, onSuccess: { (tripPager: VLTripPager?, response: HTTPURLResponse?) in
            
            self.tripsCount = tripPager?.trips?.count
            print("tripsCount ---\(self.tripsCount)")
            
            for i in 0..<self.tripsCount {
                print("i-------\(i)")
                
                if let trip = tripPager?.trips?[i] {
                    self.deviceTrip = trip as! VLTrip
                    
                    let mytripdtl = TripDetail()
                    
                    if let startCLlocation = self.deviceTrip.startPoint, let endCLlocation = self.deviceTrip.stopPoint {

                        mytripdtl.startloc = CLLocation(latitude: self.deviceTrip.startPoint.latitude, longitude: self.deviceTrip.startPoint.longitude)

                        mytripdtl.stoploc = CLLocation(latitude: self.deviceTrip.stopPoint.latitude, longitude: self.deviceTrip.stopPoint.longitude)
                        
                    } else {
                        print("No location info available")
                    }
                    if let descr = self.deviceTrip?.description {
                         mytripdtl.description = descr
                    }
                    if let strtdte = self.deviceTrip?.startDate {
                        
                        let mydatestring = "\(strtdte)"
                        let mydatedate = strtdte as? Date
                        
                        
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ss"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
                        
                        
                        var datetext = (dateFormatterPrint.string(from: mydatedate!))
                       // print("######datetext --- \(datetext)")
                        
                        let dateFormatterPrinttime = DateFormatter()
                        dateFormatterPrinttime.dateFormat = "hh:mm a"

                        var timetext = (dateFormatterPrinttime.string(from: mydatedate!))
                       // print("######timetext --- \(timetext)")
                        
                        mytripdtl.startDate = "On \(datetext) at \(timetext)"
                        
                        
                        
                        
                    }
                    if let prev = self.deviceTrip?.preview {
                        mytripdtl.preview = prev
                    }
                    if let statsDict = self.deviceTrip.stats as? Dictionary<String, AnyObject> {
                        if let stopCounts = statsDict["stopCount"] as? Double{
                            mytripdtl.stopCounts = "\(stopCounts)"
                        }
                        if let averageSpeed = statsDict["averageSpeed"] as? Double{
                            let averageSpeed1 = String(format: "%.2f", averageSpeed)
                            mytripdtl.avgSpeed = "\(averageSpeed1) mph"
                        }
                        if let distance = statsDict["distance"] as? Double{
                            let distanceInMiles = String(format: "%.2f", distance * 0.000621371)
                            mytripdtl.distance = "\(distanceInMiles) Miles"
                        }
                        if let duration = statsDict["duration"] as? Double{
                            let durationInMin = String(format: "%.2f", duration / 60000)
                            mytripdtl.duration = "\(durationInMin) Mins"
                        }
                        if let fuelConsumed1 = statsDict["fuelConsumed"] as? Double{
                            let fuelConsumed = String(format: "%.2f", fuelConsumed1)
                            mytripdtl.fuelConsumed = "\(fuelConsumed) L"
                        }else {
                            mytripdtl.fuelConsumed = "--"
                        }
                        
                        
                        
                        if let fuelEconomy1 = statsDict["fuelEconomy"] as? Double{
                            let fuelEconomy = String(format: "%.2f", fuelEconomy1)
                            mytripdtl.fuelEconomy = "\(fuelEconomy) mpg"
                        }else {
                            mytripdtl.fuelEconomy = "--"
                        }
                        
                        
                        
                        if let maxSpeed = statsDict["maxSpeed"] as? Double{
                            let maxspeed1 = String(format: "%.f", maxSpeed * 0.621371)
                            mytripdtl.maxSpeed = "\(maxspeed1) mph"
                        }
                        if let hardBrakeCount = statsDict["hardBrakeCount"] as? Double{
                            let hardBrakeCountstring = "\(Int(hardBrakeCount))"
                            mytripdtl.hardbrakes = "\(hardBrakeCountstring)"
                        }else {
                            mytripdtl.hardbrakes = "0"
                        }
                        
                        if let averageLoad = statsDict["averageLoad"] as? Double{
                            let averageLoadstring = "\(Int(averageLoad))"
                            mytripdtl.engineload = "\(averageLoadstring)%"
                        }else {
                            mytripdtl.hardbrakes = "--"
                        }
                    }
                    
                    let tripIdDetail = self.deviceTrip?.tripId
                    
                    self.vinli.getReportCardForTrip(withId: tripIdDetail!, onSuccess: { (reportCard:VLReportCard?, response: HTTPURLResponse?) in
                        
                        if let reportcard = reportCard  {
                            let card = (reportcard.grade)!
                            print("reportcard.grade --- \(card)")
                             mytripdtl.reportCard = "\(card)"
                        }
                   
                       
                        
                    }) { (error: Error?, response:HTTPURLResponse?, bodyString: String?) in
                        print("error getting report card: \(bodyString)")
                    }
                    
                    
                   print("mytripdtl.duration - \(mytripdtl.duration)")
                    print("mytripdtl.avgSpeed - \(mytripdtl.avgSpeed)")
                    
                    
                   self.tripDetailArray.append(mytripdtl)

                }
                
            }
            
            
            let barViewControllers = self.tabBarController?.viewControllers
            print("@@@@@@@@@@barViewControllers?.count -- \(barViewControllers?.count)")
            //   print("Bar Index - \(barViewControllers?.index(of: TripDetailViewController))")
            if let trpdtl = barViewControllers?[1] as? TripDetailViewController {
                print("^^^^^^^^^^^^^^^^^^^")
                print("trpdtl.tripDetailArray1.count - \(trpdtl.tripDetailArray1.count)")
                print("self.tripDetailArray.count - \(self.tripDetailArray.count)")
                trpdtl.tripDetailArray1 = self.tripDetailArray
                trpdtl.testOne = "Hello Just a test"
                print("*****trpdtl.tripDetailArray1.count - \(trpdtl.tripDetailArray1.count)")
            }

            
            
        }) { (error: Error?, response:HTTPURLResponse?, bodyString: String?) in
            print("error getting Trips: \(bodyString)")
        }
    }
    
    
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        arViewController.present(alert, animated: true, completion: nil)
    }
    
    
}


extension DeviceDetailViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension DeviceDetailViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            self.showInfoView(forPlace: annotation)
        }
        
    }
}

extension DeviceDetailViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if locations.count > 0 && self.latestLocation != nil  {
            let location = locations.last!
            if location.horizontalAccuracy <= 10 {
                manager.stopUpdatingLocation()
                let myPin = MKPointAnnotation()
                myPin.coordinate = location.coordinate
                myPin.title = "My Location"
                let carCLLoation : CLLocation = CLLocation(latitude: self.latestLocation.latitude, longitude: self.latestLocation.longitude)
                let place = Place(location: carCLLoation, reference: "", name: self.device.name, address: "")
                self.places.append(place)
            }
        }
    }

    
}



