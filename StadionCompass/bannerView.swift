//
//  bannerView.swift
//  StadionCompass
//
//  Created by Holger Krupp on 10.06.21.
//  Copyright © 2021 Holger Krupp. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import GoogleMobileAds

class bannerView: UIViewController{
    
    @IBOutlet weak var banenrView: GADBannerView!
    
    
    override func viewDidLoad() {
        
        if !proPurchased(){
            if (getObjectForKeyFromPersistentStorrage("Tracking") == nil){
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        self.loadBanner()
                        setObjectForKeyToPersistentStorrage("Tracking", object: true)
                    })
                } else {
                    // Fallback on earlier versions
                    loadBanner()
                }
            }else{
                loadBanner()
            }

            
            
        }else{
            banenrView.removeFromSuperview()
        }
        
    }
    
    func loadBanner(){
        DispatchQueue.main.async {
            let GoogleAdUnitIDBanner = "ca-app-pub-5806009591474824/6172112796"
            
            self.banenrView.adUnitID = GoogleAdUnitIDBanner
            self.banenrView.rootViewController = self
            self.banenrView.load(GADRequest())
        }

        
    }

}


