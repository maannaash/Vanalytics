//
//  RuleViewController.swift
//  Vanalytics
//
//  Created by Apple on 19/02/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit
import MapKit
import VinliNet




class RuleViewController: UIViewController {
    
    
    var vinli: VLService!
    var mydevice: VLDevice!
    var speedData: Int!
    var fuelData: Int!
    var speedInKm: Int!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var fuelValuelabel: UILabel!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var fuelSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speedSlider.minimumTrackTintColor = UIColor.blue
        speedSlider.setThumbImage(UIImage.init(named: "car2"), for: .normal)
        fuelSlider.minimumTrackTintColor = UIColor.blue
        fuelSlider.setThumbImage(UIImage.init(named: "fuel2"), for: .normal)
        
        self.speedData = 5
        self.speedInKm = self.speedData
        self.fuelData = 10
        if VLSessionManager.loggedIn() {
            vinli = VLService.init(session: VLSessionManager.currentSession())
            //createnewRule()
            
            
            
            
        }
    }
    
    
    @IBAction func updateSlider(_ sender: UISlider) {
        self.speedData = Int(sender.value)
        self.speedInKm = Int(sender.value * 1.60934)
        valueLabel.text = String(self.speedData)
        
        
        

    }
    
    
    
    
    @IBAction func updateSpeedRule(_ sender: Any) {
        createnewRule()
    }
    
    
    @IBAction func updateFuelRule(_ sender: Any) {
        createnewfuelRule()
    }
    
    @IBAction func updatefuelslider(_ sender: UISlider) {
        self.fuelData = Int(sender.value)
        fuelValuelabel.text = "\(self.fuelData!)%"
        
    }

    
    func createnewRule() {
        
        vinli.getRulesForDevice(withId: mydevice.deviceId, onSuccess: { (rulepager: VLRulePager?, response: HTTPURLResponse?) in
            
            if let rulespager = rulepager {
                if rulespager.rules.count > 0 {
                    for i in 0..<rulespager.rules.count{
                        if let rule = rulepager?.rules[i] as? VLRule {
                            if rule.name == "my speed Rule" {
                                self.vinli.deleteRule(withId: rule.ruleId, onSuccess: { (response: HTTPURLResponse?) in
                                    print("Delete rule was success")
                                }) { (error, response, string) in
                                    print("Error")
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
            
            
        }) { (error, response, string) in
            print("Error")
            
        }
        
        
        let boundary = VLParametricBoundary.init(parameter: "vehicleSpeed", min: UInt(self.speedInKm), max: 150)
        let myurl = URL(string: "https://polar-brushlands-14119.herokuapp.com/catch")
        
        let myrule: VLRule? = VLRule.init(name: "my speed Rule", boundaries: [boundary])
        
        vinli.createRule(myrule!, forDevice: self.mydevice.deviceId, onSuccess: { (rule, response) in
            
            self.vinli.createSubscription(VLSubscription.init(eventType: "rule-enter", url: myurl, appData: ["name" : self.mydevice.name, "speed": self.speedData], objectRef: VLObjectRef.init(type: "rule", objectId: rule?.ruleId)), forDevice: self.mydevice.deviceId, onSuccess: { (subscription: VLSubscription?, response:HTTPURLResponse?) in
                //on success
                
                print("my speed rule is SUCCESSSSSSSSSSSSSSSSSSS")
                
            }, onFailure: { (error: Error?, repsponse: HTTPURLResponse?, string:String?) in
                //onfailure
            })
            
            
        }) { (error, response, string) in
            print("Error")
            
        }
        
    }
    
    
    func createnewfuelRule() {
        
        vinli.getRulesForDevice(withId: mydevice.deviceId, onSuccess: { (rulepager: VLRulePager?, response: HTTPURLResponse?) in
            
            if let rulespager = rulepager {
                if rulespager.rules.count > 0 {
                    for i in 0..<rulespager.rules.count{
                        print("i  is \(i)  with data \(rulepager?.rules[i]))")
                        if let rule = rulepager?.rules[i] as? VLRule {
                            if rule.name == "my fuel Rule" {
                                self.vinli.deleteRule(withId: rule.ruleId, onSuccess: { (response: HTTPURLResponse?) in
                                    print("Delete fuel rule was success")
                                }) { (error, response, string) in
                                    print("Error")
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
            
            
        }) { (error, response, string) in
            print("Error")
            
        }
        
        
        let boundary = VLParametricBoundary.init(parameter: "fuelLevelInput", min: UInt(self.fuelData), max: 100)
        let myurl = URL(string: "https://polar-brushlands-14119.herokuapp.com/catch")
        
        let myrule: VLRule? = VLRule.init(name: "my fuel Rule", boundaries: [boundary])
        
        vinli.createRule(myrule!, forDevice: self.mydevice.deviceId, onSuccess: { (rule, response) in
            
            self.vinli.createSubscription(VLSubscription.init(eventType: "rule-leave", url: myurl, appData: ["name" : self.mydevice.name], objectRef: VLObjectRef.init(type: "rule", objectId: rule?.ruleId)), forDevice: self.mydevice.deviceId, onSuccess: { (subscription: VLSubscription?, response:HTTPURLResponse?) in
                //on success
                
                print("my speed rule is SUCCESSSSSSSSSSSSSSSSSSS")
                
            }, onFailure: { (error: Error?, repsponse: HTTPURLResponse?, string:String?) in
                //onfailure
            })
            
            
        }) { (error, response, string) in
            print("Error")
            
        }
        
    }

    
}
