//
//  ViewController.swift
//  StadionCompass
//
//  Created by Holger Krupp on 19.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    
    @IBOutlet weak var CounterLabel: UILabel!
    @IBOutlet weak var distanceTextLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    
    @IBOutlet weak var allowLocation: UIButton!
    @IBAction func infoPressed(_ sender: Any) {
        changeStadium()
    }
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func allowLocation(_ sender: Any) {
        goToSettings()
    }
    
    
    var stadion : Stadium?
    let locationManager = CLLocationManager.init()
    //let motionManager = CMDeviceMotion.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        allowLocation.isHidden = true
        var stadionID = ""
        if let tempID = getObjectForKeyFromPersistentStorrage("tempStadium") as? String {
            stadionID = tempID
            removeObjectForKeyFromPersistentStorrage("tempStadium")
        }else if let homeID = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            stadionID = homeID
        }
        stadion = Stadium.init(stadionID: stadionID)
        if stadion?.name != nil, stadion?.name != ""
        {
         
           // stadion = Stadium.init(stadionID: stadionID)
            NotificationCenter.default.addObserver(self, selector: #selector(appbecameActive), name: .UIApplicationDidBecomeActive, object: nil)
            nameLabel.text = stadion?.name
            cityLabel.text = stadion?.city
            homeLabel.text = stadion?.hometeam
            
            self.view.backgroundColor = stadion?.bgColor
            
            
            
            homeLabel.textColor = stadion?.textColor
            cityLabel.textColor = stadion?.textColor
            nameLabel.textColor = stadion?.textColor
            infoButton.tintColor = stadion?.textColor
            CounterLabel.textColor = stadion?.textColor
            degreesLabel.textColor = stadion?.textColor
            distanceTextLabel.textColor = stadion?.textColor
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            updateLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func appbecameActive(){
        updateLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.setAnimationsEnabled(true)
        self.navigationItem.setHidesBackButton(true, animated: animated);
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLocation()
    }
    

    func updateLocation(){
        degreesLabel.text = "checking location"
        NSLog("update Location")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
            NSLog("Auth ok")
            allowLocation.isHidden = true
            self.view.setNeedsDisplay()
            startUpdatingUI()
            if CLLocationManager.authorizationStatus() == .authorizedAlways{
                
                let centre = UNUserNotificationCenter.current()
                centre.requestAuthorization(options: [.alert]) { (granted, error) in
                    
                    self.stadion?.startMonitoring()
                    
                }
            }
            
        }else if CLLocationManager.authorizationStatus() == .notDetermined{
            degreesLabel.text = "please allow location"

            stadion?.askforLocation()
            startUpdatingUI()
        }else if CLLocationManager.authorizationStatus() == .denied{
            locationDenied()
        }
    }
    

    
    func locationDenied(){
        degreesLabel.isHidden = false
        arrowImage.isHidden = true
        cityLabel.isHidden = true
        CounterLabel.isHidden = true
        degreesLabel.text = String.localizedStringWithFormat(NSLocalizedString("location.denied", value:"Please open Settings to allow location access",comment: "shown when location data is not shared"))
        allowLocation.setTitle(String.localizedStringWithFormat(NSLocalizedString("location.deniedbutton", value:"Please open allow location access",comment: "title when location data is not requested")), for: .normal)
        allowLocation.isHidden = false
        NSLog("User denied location")
    }
    
    func goToSettings(){
        guard let SettingsURL = URL(string:
            UIApplicationOpenSettingsURLString) else {
                return
        }
        
        if UIApplication.shared.canOpenURL(SettingsURL) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(SettingsURL, completionHandler: { (success) in
                    
                    print(" Settings opened: \(success)")
                    
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func changeStadium(){
        self.navigationController?.popViewController(animated: true)
    }

    func startUpdatingUI(){
        locationManager.requestLocation()
        
        //    locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        updateUI()
    }
    
    func updateUI(){

        
        
        
        let userlocation  = locationManager.location?.coordinate
        let targetlocation = stadion?.location?.coordinate
        var heading = 0.0
        if let realheading = locationManager.heading?.trueHeading{
            heading = realheading
        }
        /*
        if #available(iOS 11.0, *) {
            if let magneticHeading = motionManager.heading.{
                heading = magneticHeading
            }
        } else {
            // Fallback on earlier versions
        }
        */
        
        // correction to be applied when userinterface is not in alignment with device orientation
        var correction = 0.0
        switch UIApplication.shared.statusBarOrientation {
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
        }
        
        
        
        if userlocation != nil && targetlocation != nil{
            
            if let distance = stadion?.calculateDistance(user: userlocation!){
                
                cityLabel.text = MKDistanceFormatter().string(fromDistance: distance)

                
                if let textDict = getDataFromPlist(plist: "distanceTexts", key: nil) as? NSDictionary
                {
                    var tempmeters = 40000000
                    var distanceText:String? = "wow you are far away"
                    for item in textDict{
                        
                        if let meters = Int(item.key as! String){
                            if meters < tempmeters, meters > Int(distance) {
                                tempmeters = meters
                                // distanceText = item.value as? String
                                distanceText = Bundle.main.localizedString(forKey: item.value as! String, value: nil, table: nil)
                            }
                        }
                    }
                    distanceTextLabel.text = distanceText
                    
                    
                    
                    if distance < 200{
                        stadion?.updateVisits()
                        let colorheart = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
                        arrowImage.tintColor = stadion?.arrowColor
                        arrowImage.image = colorheart
                        arrowImage.transform = CGAffineTransform(rotationAngle: 0)
                        cityLabel.isHidden = true
                        
                        if let slogan = stadion?.homeslogan, stadion?.homeslogan != ""{
                            distanceTextLabel.text = slogan
                        }
                        
                        
                    }else{
                        let colorArrow = UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate)
                        arrowImage.tintColor = stadion?.arrowColor
                        arrowImage.image = colorArrow
                        cityLabel.isHidden = false
                        if let degrees = stadion?.calculateAngle(user: userlocation!){
                            var stadiumheading =  degrees - heading + correction
                            stadiumheading = round(stadiumheading)
                            degreesLabel.text = "\(stadiumheading)°"
                            degreesLabel.isHidden = true
                            UIView.animate(withDuration: 0.3, animations: {
                                let rot =  CGFloat((stadiumheading * .pi) / 180)
                                self.arrowImage.transform = CGAffineTransform(rotationAngle: rot)
                        })
                        }
                    }
                    arrowImage.isHidden = false
                    distanceTextLabel.isHidden = false
                    
                    
                }else{
                    NSLog("error")
                }
                
            }
        }
        if let visits = stadion?.getVisits(){
            //  var lastVisit: String?
            var numberOfVisits: Int = 0
            for data in visits{
                if data.key == "lastVisit", data.value is Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = DateFormatter.Style.short
                    //  lastVisit = formatter.string(from: data.value as! Date)
                }
                if data.key == "numberOfVisists", data.value is Int {
                    numberOfVisits = data.value as! Int
                }
            }
            
            let lastVisitString = String.localizedStringWithFormat(NSLocalizedString("compassView.visitCounter", value:"You've visited %d times.",comment: "Text to display the message how often a stadium has been visited"), numberOfVisits)
            if numberOfVisits > 0 {
                CounterLabel.text = lastVisitString
                CounterLabel.isHidden = false
            }
        }
    }
 
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    

    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered!")
        let stadion = Stadium.init(stadionID: region.identifier)
        if stadion.hometeam != nil {
            triggerNotificationfor(stadium: stadion)
        }
    }
    
    func triggerNotificationfor(stadium: Stadium){
        let centre = UNUserNotificationCenter.current()
        centre.getNotificationSettings { (settings) in
            if settings.authorizationStatus != UNAuthorizationStatus.authorized {
                print("Not Authorised")
            } else {
                print("Authorised")
                
                
                

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    let content = UNMutableNotificationContent()
                    if let name = stadium.name{
                        content.title = name
                    }
                    
                    if let slogan = stadium.homeslogan, stadium.homeslogan != ""{
                        content.body = slogan
                    }else{
                        
                        content.body = String.localizedStringWithFormat(NSLocalizedString("notification.closeby", value:"You are close by a stadium",comment: "shown when the user is close to a stadium"))
                    }
                    content.sound = UNNotificationSound.default()
                    var identifier = "defaultStadiumNotification"
                    if let hometeam = stadium.hometeam{
                        identifier = hometeam
                    }
                    centre.removeDeliveredNotifications(withIdentifiers: [identifier])
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    centre.add(request, withCompletionHandler: nil)
                    
                }
                
            
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("location failed with \(error)")
        locationDenied()
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        NSLog("Did finish Updates with Error \(String(describing: error))")
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
        if let oldestRegion = manager.monitoredRegions.first{
            manager.stopMonitoring(for: oldestRegion)
            if let newregion = region{
                manager.startMonitoring(for: newregion)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        NSLog("Location Monitoring started ----- for \(region.identifier)")
        dump(manager.monitoredRegions)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    
}



extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


