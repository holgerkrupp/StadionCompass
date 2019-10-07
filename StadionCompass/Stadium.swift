//
//  Stadion.swift
//  StadionCompass
//
//  Created by Holger Krupp on 19.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class Stadium: NSObject {
    var location: CLLocation?
    var name : String?
    var city : String?
    var hometeam: String?
    var homeslogan: String?
    var league: String?
    var arrowColor = UIColor.white
    var bgColor = UIColor.black
    var textColor = UIColor.white
    
    let locationManager = CLLocationManager.init()
    
    override init() {
        
    }
    
    init(stadionID: String){
        var flatten:NSDictionary?
        if let allcompetitions = getDataFromPlist(plist: "StadionData", key: nil) as? Dictionary<String, Any>{
            for competition in allcompetitions{
                if let stad = competition.value as? Dictionary<String, Any>{
                    for compstadium in stad{
                        if compstadium.key == stadionID{
                            if let stadionDaten = compstadium.value as? NSDictionary{
                                flatten = stadionDaten
                                self.league = competition.key
                            }
                            
                        }
                    }
                }
                
                
            }
            
            if let stadionDaten = flatten{
                if let location = stadionDaten.object(forKey: "location") as? NSDictionary{
                    let lat : CLLocationDegrees = location.object(forKey: "lat") as! Double
                    let lon : CLLocationDegrees = location.object(forKey: "lon") as! Double
                    self.location = CLLocation(latitude: lat, longitude: lon)
                }
                if let stadionname = stadionDaten.object(forKey: "name") as? String{
                    self.name = stadionname
                }
                if let stadioncity = stadionDaten.object(forKey: "city") as? String{
                    self.city = stadioncity
                }
                if let homeslogan = stadionDaten.object(forKey: "homeslogan") as? String{
                    self.homeslogan = homeslogan
                }
                
                self.hometeam = stadionID
                
                
                if let arrowColor = stadionDaten.object(forKey: "arrowColor") as? String{
                    self.arrowColor = UIColor(arrowColor)
                }
                if let bgColor = stadionDaten.object(forKey: "backgroundColor") as? String{
                    self.bgColor = UIColor(bgColor)
                }
                if let textColor = stadionDaten.object(forKey: "textColor") as? String{
                    self.textColor = UIColor(textColor)
                }
                

                
            }
            
        }
    }
    
    init(location: CLLocation?, name: String?, city : String?, hometeam: String?){
        self.location = location
        self.name = name
        self.city = city
        self.hometeam = hometeam
    }
    
    func updateVisits(){
        var visitData = Dictionary<String, Any>()
        var lastVisit = Date()
        var numberOfVisists:Int = 1
        var oneDayafterLastVisit:Date?
        
        if let id = self.hometeam{
            if let visits = getVisits(){
                
                var oldNumberOfVisits:Int = 0
                for data in visits{
                    if data.key == "lastVisit", data.value is Date {
                        lastVisit = data.value as! Date
                        oneDayafterLastVisit = Calendar.current.date(byAdding: .day, value: 1, to: data.value as! Date)
                    }
                    if data.key == "numberOfVisists", data.value is Int {
                        oldNumberOfVisits = data.value as! Int
                    }
                }

                let today = Date()
                if let oneDayafter = oneDayafterLastVisit{
                    if oneDayafter < today {
                        numberOfVisists = oldNumberOfVisits + 1
                        lastVisit = today
                        
                    }else{
                        numberOfVisists = oldNumberOfVisits
                        
                    }
                }else{
                    //ERROR Something wrong with last visit data - the date of last visit is missing
                    numberOfVisists = oldNumberOfVisits
                    lastVisit = today
                }
                
                
            
                
            }
            if numberOfVisists == 1, oneDayafterLastVisit == nil{
                if let league = self.league{
                    if let leagueVisits = getObjectForKeyFromPersistentStorrage(league) as? Int{
                        let newVisits = leagueVisits + 1
                        setObjectForKeyToPersistentStorrage(league, object: newVisits)
                    }else{
                        setObjectForKeyToPersistentStorrage(league, object: 1)
                    }
                }
            }
   
            visitData.updateValue(lastVisit, forKey: "lastVisit")
            visitData.updateValue(numberOfVisists, forKey: "numberOfVisists")

            setObjectForKeyToPersistentStorrage(id, object: visitData as Any)
        }
    }
    
    func getVisits() -> Dictionary<String, Any>?{
        var visitData:Dictionary<String, Any>?
        if let id = self.hometeam{
            if let visits = getObjectForKeyFromPersistentStorrage(id) as? Dictionary<String, Any>{
                visitData = visits
            }
        }
        return visitData
    }
    
    
    func region(withLocation target:CLLocationCoordinate2D) -> CLCircularRegion {
        var regionID = "hometeam"
        
        if let stadiumID = self.hometeam{
            regionID = stadiumID
        }
        let region = CLCircularRegion(center: target, radius: 200, identifier: regionID)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    func startMonitoring() {
        #if os(iOS)
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if let stadiumLocation = self.location?.coordinate{
                let region = self.region(withLocation: stadiumLocation)
                if !locationManager.monitoredRegions.contains(region){
                    locationManager.startMonitoring(for: region)
                }
            }
        
            //significant location change:
        
            locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        
        
        }else if CLLocationManager.authorizationStatus() == .notDetermined{
            askforLocation()
        }
        #endif
    }
    
    
    func askforLocation(){
        locationManager.requestAlwaysAuthorization()
    }
    
    
    
    
    func calculateDistance(user: CLLocationCoordinate2D) -> CLLocationDistance?{
        
            if let target = self.location?.coordinate{
            
            let r = 6371000.0
            let φ1 = user.latitude.degreesToRadians
            let φ2 = target.latitude.degreesToRadians
            
            let Δφ = (target.latitude - user.latitude).degreesToRadians
            let Δλ = (target.longitude - user.longitude).degreesToRadians
            
            let a = sin(Δφ/2) * sin(Δφ/2) + cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2)
            let c = 2 * atan2(sqrt(a), sqrt(1-a))
            
            let d = r * c
            return d
        }else{
            return nil
        }
    }
    
    func calculateAngle(user: CLLocationCoordinate2D) -> Double?{
        if let target = self.location?.coordinate{
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
        }else{
            return nil
        }
    
    }
}

extension Stadium: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        
        
        let lastLocation = locations.last!
        
        NSLog("location did change")
        
        let center = UNUserNotificationCenter.current
        
        
        let identifier = "defaultStadium"
        
        let content = UNMutableNotificationContent()
        if let name = self.name{
            content.title = name
        }
        
        if let slogan = self.homeslogan, self.homeslogan != ""{
            content.body = slogan
        }else{
            content.body = String.localizedStringWithFormat(NSLocalizedString("notification.closeby", value:"You are close by a stadium",comment: "shown when the user is close to a stadium"))
        }
        content.sound = UNNotificationSound.default
        
        
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        center().add(request, withCompletionHandler: nil)
        
        
    }
}
