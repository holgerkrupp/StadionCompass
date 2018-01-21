//
//  ViewController.swift
//  StadionCompass
//
//  Created by Holger Krupp on 19.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        allowLocation.isHidden = true
        if let stadionID = getObjectForKeyFromPersistentStorrage("homestadium") as? String
        {
       // stadion = loadStadium(stadionID: stadionID!)
            stadion = Stadium.init(stadionID: stadionID)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: animated);
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.isHidden = true
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLocation()
    }
    
    func updateLocation(){
        degreesLabel.text = "checking location"
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
            NSLog("Auth ok")
            
            updateUI()
            
            
        }else if CLLocationManager.authorizationStatus() == .notDetermined{
            degreesLabel.text = "please allow location"
            
            
            
            
            askforLocation()
            updateUI()
        }else if CLLocationManager.authorizationStatus() == .denied{
            locationDenied()
        }
    }
    
    func askforLocation(){
        locationManager.requestWhenInUseAuthorization()
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
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func updateUI(){
        locationManager.requestLocation()
        
        //    locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
        
        let userlocation  = locationManager.location?.coordinate
        let targetlocation = stadion?.location?.coordinate
        var heading = 0.0
        if let realheading = locationManager.heading?.trueHeading.magnitude{
            heading = realheading
        }
        
        if userlocation != nil && targetlocation != nil{
            
            
            
            
            if let distance = calculateDistance(user: userlocation!, target: targetlocation!){
                if distance > 1000{
                    let format = ".1"
                    cityLabel.text = "\(Double(distance/1000).format(f: format))km"
                }else{
                    let format = ".0"
                    cityLabel.text = "\(floor(distance).format(f: format))m"
                }
                
                
                if distance < 200{
                    stadion?.updateVisits()
                    let colorheart = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
                    arrowImage.tintColor = stadion?.arrowColor
                    arrowImage.image = colorheart
                    arrowImage.transform = CGAffineTransform(rotationAngle: 0)
                    cityLabel.isHidden = true
                }else{
                    let colorArrow = UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate)
                    arrowImage.tintColor = stadion?.arrowColor
                    arrowImage.image = colorArrow
                    cityLabel.isHidden = false
                    let degrees = calculateAngle(user: userlocation!, target: targetlocation!)
                    var stadiumheading =  degrees - heading
                    stadiumheading = round(stadiumheading)
                    degreesLabel.text = "\(stadiumheading)°"
                    degreesLabel.isHidden = true
                    UIView.animate(withDuration: 0.2, animations: {
                        let rot =  CGFloat((stadiumheading * .pi) / 180)
                        self.arrowImage.transform = CGAffineTransform(rotationAngle: rot)
                    })
                }
                arrowImage.isHidden = false
                
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
                    distanceTextLabel.isHidden = false
                    
                }else{
                    NSLog("error")
                }
                
            }
        }
        if let visits = stadion?.getVisits(){
            var lastVisit: String?
            var numberOfVisits: Int = 0
            for data in visits{
                if data.key == "lastVisit", data.value is Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = DateFormatter.Style.short
                    lastVisit = formatter.string(from: data.value as! Date)
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
    
    func calculateAngle(user: CLLocationCoordinate2D, target: CLLocationCoordinate2D) -> Double{
        
        let userlat = Double(user.latitude)
        let userlon = Double(user.longitude)
        let targlat = Double(target.latitude)
        let targlon = Double(target.longitude)
        var degrees = Double()
        
        let dlat =   targlat - userlat
        let dlon =   targlon - userlon
        
        if dlat == 0{
            if dlon > 0 {
                degrees = 90
            }else{
                degrees = 270
            }
        }else{
            degrees = (atan(dlon/dlat))*180 / Double.pi
        }
        
        if dlat < 0{
            degrees = degrees + 180
        }
        
        if degrees < 0{
            degrees = degrees + 360
        }
        
        return degrees
    }
    
    func calculateDistance(user: CLLocationCoordinate2D, target: CLLocationCoordinate2D) -> Double?{
        
        let r = 6371000.0
        let φ1 = user.latitude.degreesToRadians
        let φ2 = target.latitude.degreesToRadians
        
        let Δφ = (target.latitude - user.latitude).degreesToRadians
        let Δλ = (target.longitude - user.longitude).degreesToRadians
        
        let a = sin(Δφ/2) * sin(Δφ/2) + cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let d = r * c
        return d
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        if let userlocation = locations.last?.coordinate,
        //            let targetlocation = stadion?.location?.coordinate,
        //                targetlocation != nil{
        //            let degrees = calculateAngle(user: userlocation, target: targetlocation)
        //
        //        }
        //
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
