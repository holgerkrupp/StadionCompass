//
//  StadionRow.swift
//  StadionCompassWatch Extension
//
//  Created by Holger Krupp on 28.09.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//

import WatchKit

class StadionRowController: NSObject {

    @IBOutlet weak var TeamLabel: WKInterfaceLabel!
    @IBOutlet weak var StadionLabel: WKInterfaceLabel!
    
    
    var stadion: Stadium? {
      // 2
      didSet {
        // 3
        guard let stadion = stadion else { return }
        // 4
        TeamLabel.setText(stadion.hometeam)
        StadionLabel.setText(stadion.name)

      }
    }
    
}
