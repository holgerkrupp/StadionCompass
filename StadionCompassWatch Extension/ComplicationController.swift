//
//  ComplicationController.swift
//  StadionCompassWatch Extension
//
//  Created by Holger Krupp on 27.09.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//

import ClockKit
import CoreLocation
import MapKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    var stadion : Stadium?
    let locationManager = CLLocationManager.init()
    var userlocation:CLLocationCoordinate2D?
    
    var StadionName = "Please open App"
    var distance = 0.0
    var direction = 0.0
    
    
    
    func loaddata(){
        userlocation  = locationManager.location?.coordinate
        if let stad = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            stadion = Stadium(stadionID: stad)
            if stadion != nil{
                StadionName = stadion?.name ?? ""
            }
        }
    }
    
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        loaddata()
        
        var distanceText = "distance unknown"
        
        if let location = userlocation{
            if let distance = stadion?.calculateDistance(user: location){
                distanceText = MKDistanceFormatter().string(fromDistance: distance)
                }
        }
        
        
        
        NSLog("getCurrentTimelineEntry called")
        // Call the handler with the current timeline entry
        
        switch complication.family {
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: distanceText)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: distanceText)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "line 1")
            template.line2TextProvider = CLKSimpleTextProvider(text: distanceText)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: StadionName)
            template.bodyTextProvider=CLKSimpleTextProvider(text: distanceText)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: StadionName)
            template.outerTextProvider = CLKSimpleTextProvider(text: distanceText)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
        
        
    }

    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        loaddata()
        
        switch complication.family {
            
        case .modularSmall:
            NSLog("modularSmall ok")
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "200 km")
            handler(template)
            
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "200 km")
            handler(template)
            
        case .circularSmall:
            NSLog("circularSmall ok")
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "line 1")
            template.line2TextProvider = CLKSimpleTextProvider(text: "200 km")
            handler(template)
            
        case .modularLarge:
            NSLog("modularLarge ok")
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Stadion name")
            template.bodyTextProvider=CLKSimpleTextProvider(text: "200 km")
            handler(template)
            
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "Stadion name")
            template.outerTextProvider = CLKSimpleTextProvider(text: "200 km")
            handler(template)
            
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
        
        
    }

    
}
