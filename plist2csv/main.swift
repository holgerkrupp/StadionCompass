//
//  main.swift
//  plist2csv
//
//  Created by Holger Krupp on 04.02.18.
//  Copyright © 2018 Holger Krupp. All rights reserved.
//

import Foundation


func getDataFromPlist(plist:String, key:String?) -> Any{
    if let path = Bundle.main.path(forResource: plist, ofType: "plist") {
        let myDict = NSDictionary(contentsOfFile: path)
        if let dictKey = key{
            return myDict!.object(forKey: dictKey)! as AnyObject
        }else{
            return myDict as Any
        }
    }else{
        
        return "plist error" as AnyObject
    }
}



if let allcompetitions = getDataFromPlist(plist: "StadionData", key: nil) as? Dictionary<String, Any>{
    NSLog("Test")
    for competition in allcompetitions{
        if let stad = competition.value as? Dictionary<String, Any>{
            for compstadium in stad{
                if let _ = compstadium.value as? NSDictionary{
                     NSLog("key: \(compstadium.key)")
                    
                }
            }
        }
    }
}
