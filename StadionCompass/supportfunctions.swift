//
//  supportfunctions.swift
//  StadionCompass
//
//  Created by Holger Krupp on 19.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
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


func setObjectForKeyToPersistentStorrage(_ key:String, object:Any){
    NSLog("Set \(object) for \(key)")
     UserDefaults.standard.set(object, forKey: key)
}

func getObjectForKeyFromPersistentStorrage(_ key:String) -> Any?{
    if let object = UserDefaults.standard.object(forKey: key){
        return object as AnyObject?
    }else{
        return nil
    }
}

func removeObjectForKeyFromPersistentStorrage(_ key:String){
    UserDefaults.standard.removeObject(forKey: key)
}

func removePersistentStorrage(){
    let appdomain = Bundle.main.bundleIdentifier
    UserDefaults.standard.removePersistentDomain(forName: appdomain!)
}
