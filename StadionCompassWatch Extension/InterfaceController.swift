//
//  InterfaceController.swift
//  StadionCompassWatch Extension
//
//  Created by Holger Krupp on 27.09.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreLocation
import SpriteKit


class InterfaceController: WKInterfaceController {
    
    var session = WCSession.default
    var stadion: Stadium?
    let locationManager = CLLocationManager.init()
    
    var drift:CGFloat = 0.0
    var heading = 0.0
    var scene = SKScene()
    
    
    
    @IBOutlet weak var arrowSKimage: WKInterfaceSKScene!
    @IBOutlet weak var distanceTextLabel: WKInterfaceLabel!
    @IBOutlet weak var NameLabel: WKInterfaceLabel!
    @IBOutlet weak var NameButton: WKInterfaceButton!
    
    @IBAction func NameButtonPressed() {
        self.presentController(withName: "table", context: self)

    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        startSession()
        processApplicationContext()
        
        if let stad = context as? Stadium{
            stadion = stad
            startUpdatingUI()
        }else if let stad = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            stadion = Stadium(stadionID: stad)
            startUpdatingUI()
        }else{
            NSLog("Stadion not set")
            // presentController(withName: "compass", context: <#T##Any?#>)
        }
        
        // Configure interface objects here.
        
        let server = CLKComplicationServer.sharedInstance()

        // if you want to add new entries to the end of timeline
        server.activeComplications?.forEach(server.extendTimeline)
       
    }
    

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func startUpdatingUI(){
        locationManager.requestLocation()
        
        //    locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        setupUI()
        updateUI()
    }
    
    
    func setupUI(){
        scene.removeAllChildren()
        scene.backgroundColor =  UIColor.black
        NameButton.setBackgroundColor(stadion?.bgColor)
        

        if let Stad = stadion{
         //   NameLabel.setText(Stad.name)
         //   NameButton.setTitle(Stad.name)
            NameButton.setTitleWithColor(title: Stad.name ?? "", color: Stad.textColor)
            
            /*
            if Stad.textColor != UIColor.init(hex6: 000000){
                NSLog("Set to arrowColor")
                NameLabel.setTextColor(Stad.textColor)
            
            }else{
                NameLabel.setTextColor(Stad.bgColor)
            }
            */
            if Stad.textColor != UIColor.init(hex6: 000000){
                distanceTextLabel.setTextColor(Stad.textColor)
            }else{
                distanceTextLabel.setTextColor(Stad.bgColor)
            }
            
            let colorArrow = UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate)

            let texture = SKTexture(image: colorArrow!)
            var note = SKSpriteNode(texture: texture)
            
            if Stad.arrowColor != UIColor.init(hex6: 000000){
                note.color = Stad.arrowColor
            }else{
                note.color = Stad.bgColor
            }
            note.colorBlendFactor = 1.0
            
            let size = CGSize(width: 1, height: 1)
            note.scale(to: size)
            let position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            note.position = position
            scene.addChild(note)
            self.arrowSKimage.presentScene(scene)
        }

    }

    
    func updateUI(){
        
        // Distance Text first

        
        
        if let userlocation  = locationManager.location?.coordinate {
            let targetlocation = stadion?.location?.coordinate
            
            
            
            if let distance = stadion?.calculateDistance(user: userlocation){
                let distanceText = MKDistanceFormatter().string(fromDistance: distance)
                distanceTextLabel.setText(distanceText)
                }
                
                
                if let realheading = locationManager.heading?.trueHeading{
                    heading = realheading
                    
                }
                var correction = 0.0
                /* THIS IS USED in iPhone to adjust the UI orientation to the arrow - maybe not needed on the watch?
                 
                 switch WKinterface {
                 case .portrait:
                 correction = 0.0
                 case .portraitUpsideDown:
                 correction = 180.0
                 case .landscapeLeft:
                 correction = +90.0
                 case .landscapeRight:
                 correction = -90.0
                 case .unknown:
                 //default
                 break
                 @unknown default:
                 //
                 break
                 }
                 */

              //  arrowImage.setImage(colorArrow)
                if let degrees = stadion?.calculateAngle(user: userlocation){
                    var stadiumheading =  degrees - heading + correction
                    stadiumheading = round(stadiumheading)
                    
                    var rot =  CGFloat((stadiumheading * .pi) / 180)
                        rot = rot * -1
                    // DRIFT is only for simulator
                    /*
                    #if targetEnvironment(simulator)
                        drift = drift + rot
                        rot = rot + drift
                    #endif
 */
                        
                       
                        
                        // self.arrowImage.transform = CGAffineTransform(rotationAngle: rot)
                        
                    let rotate = SKAction.rotate(toAngle: rot, duration: 0.3)
                        
                    let position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
                    if let note = scene.nodes(at: position).first{
                    if note.zRotation != rot{
                        note.run(rotate)
                    }
                    }
                        
                        
                    
                }
                
                
            
            
        }else{
            distanceTextLabel.setText("Location access not granted")
        }
        
        
    }
    
    
    func loadStadium(stadionID: String){
        NSLog("loadStadium")
        stadion = Stadium.init(stadionID: stadionID)
        if let team = stadion?.hometeam{
            setObjectForKeyToPersistentStorrage("homestadium", object: team)
            stadion = Stadium(stadionID: team)
            startUpdatingUI()
        }
        dump(stadion)
    }
    
}


extension InterfaceController: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    
    
    func startSession(){
        
        session.delegate = self
        session.activate()
        
    }
    
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as? [String : String] {
            
            if let homestadium = iPhoneContext["homestadium"]{
                NSLog("homestadium: \(homestadium)")
                loadStadium(stadionID: homestadium)
                
            }else{
                NSLog("homestadium not set")
                dump(iPhoneContext)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        NSLog("didReceiveApplicationContext")
        dump(applicationContext)
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 1: We launch a sound and a vibration
        
        // 2: Get message and append to list
        NSLog("didReceiveMessage")
        if let message = message as? [String : String] {
            
            if let homestadium = message["homestadium"]{
                loadStadium(stadionID: homestadium)
                // WKInterfaceDevice.current().play(.notification)
            }else{
                NSLog("homestadium not set")
                dump(message)
            }
        }
        
        
    }
    
}
extension InterfaceController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NSLog("didChangeAuthorization")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("location failed with \(error)")
        
    }
}

extension InterfaceController: ModalItemChooserDelegate{
    func didselect(selected: Stadium){
        NSLog("didselect \(selected.name)")
        stadion = selected
        startUpdatingUI()
        setObjectForKeyToPersistentStorrage("homestadium", object: selected.hometeam as Any)
        session.sendMessage(["homestadium" : selected.hometeam], replyHandler: nil, errorHandler: { (error) in
            print("Error sending message: \(error)")})
    }

}
    


extension WKInterfaceButton {
func setTitleWithColor(title: String, color: UIColor) {
    let attString = NSMutableAttributedString(string: title)
    attString.setAttributes([NSAttributedString.Key.foregroundColor: color], range: NSMakeRange(0, attString.length))
    self.setAttributedTitle(attString)
}
}
