//
//  DeviceViewController.swift
//  Vanalytics
//
//  Created by Apple on 19/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit
import VinliNet

class DeviceViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var vinli:VLService!
    var deviceList = [VLDevice]()
    var deviceNames = [String]()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if VLSessionManager.loggedIn() {
            vinli = VLService.init(session: VLSessionManager.currentSession())
            getDevices()
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier{
            if (id == "showDeviceDetailSegue") {
                
                let barViewController = segue.destination as! UITabBarController
                
                let newVc = barViewController.viewControllers![0] as! DeviceDetailViewController
                let newVc1 = barViewController.viewControllers![1] as! TripDetailViewController
                
                //let newVc = nav.viewControllers[0] as! DeviceDetailViewController˚
                //let newVc = segue.destination as! DeviceDetailViewController
                
                var indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                
                if let device:VLDevice? = self.deviceList[(indexPath?.row)!] {
                    newVc.device = device
                    newVc.index = indexPath?.row
                    newVc1.device = device
                    newVc1.index = indexPath?.row
                    barViewController.title = device?.name
                    let myFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
                    let myColor = UIColor.blue
                    
                    
                    
                  /*  barViewController.tabBarItem.setBadgeTextAttributes([NSForegroundColorAttributeName: myColor,NSFontAttributeName : myFont], for: .normal) */
                    
                }
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: carCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! carCell

        if self.deviceNames.count > 0 {
            cell.carLabel.text = self.deviceNames[indexPath.row]
        }

        return cell
    }

    
    func getDevices() {

        vinli.getDevicesOnSuccess({(devicePager: VLDevicePager?, response: HTTPURLResponse?) in
            //            print("got dem devices")
            //            print(devicePager?.devices)
            


            for device in (devicePager?.devices)!{
                if let d = device as? VLDevice{
                    self.deviceList.append(d)
                    self.deviceNames.append(d.name)
                    print(self.deviceList)
                    print(self.deviceNames)
                    print(self.deviceNames[0])
                    self.tableView.reloadData()
                }
            }
            
        }, onFailure: { (error: Error?, response: HTTPURLResponse?, bodyString: String?) in
            print("error fetching devices")
        })
        print("#####")
        print(self.deviceNames)
        
    }
    
}
