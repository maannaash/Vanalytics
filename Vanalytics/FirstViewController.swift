//
//  ViewController.swift
//  Vanalytics
//
//  Created by Apple on 18/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit
import VinliNet

class FirstViewController: UIViewController {

    
    var VinliService:VLService!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = true
        if VLSessionManager.loggedIn() {
            VinliService = VLService.init(session: VLSessionManager.currentSession())
            performSegue(withIdentifier: "LoginSegue", sender: nil)
        } else {
            
        }
   
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        print(VLSessionManager.loggedIn())
        if VLSessionManager.loggedIn() == false {
            VLSessionManager.login(withClientId: "ec8b83a6-5a6e-42ac-af15-b177ab4e019d", redirectUri: "https://vin.TestApp.li", completion: {VLSession, error in
                if error != nil {
                    print("There was an error logging into Vinli")
                } else {
                    print("Successfully logged in!")
                    self.VinliService = VLService.init(session: VLSessionManager.currentSession())
                    //self.getDevices()
                }
            }, onCancel: {
                print("login cancelled")
            })
            
        } else {
            //logOut()
        }
        self.performSegue(withIdentifier: "LoginSegue", sender: nil)
    }
    
    func logOut() {
        VLSessionManager.logOut()
    }
    

}

