//
//  StadionSelecterInerfaceController.swift
//  StadionCompassWatch Extension
//
//  Created by Holger Krupp on 28.09.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//

import WatchKit
import Foundation


class StadionSelecterInerfaceController: WKInterfaceController {
    
     var allTeams = [Stadium]()
    var delegate : ModalItemChooserDelegate?
    

    @IBOutlet weak var StadionList: WKInterfaceTable!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.delegate = context as? InterfaceController
        
        allTeams = loadTeams()
        StadionList.setNumberOfRows(allTeams.count, withRowType: "StadionRow")
        // Configure interface objects here.
        
        for index in 0..<StadionList.numberOfRows {
          guard let controller = StadionList.rowController(at: index) as? StadionRowController else { continue }

          controller.stadion = allTeams[index]
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
      let Team = allTeams[rowIndex]
    //  presentController(withName: "compass", context: Team)
     //   pushController(withName: "compass", context: Team)
        delegate?.didselect(selected: Team)
        self.dismiss()
       
    }

    
    func loadTeams() -> [Stadium]{
        
        var allTeams = [Stadium]()
        if let allcompetitions = getDataFromPlist(plist: "StadionData", key: nil) as? Dictionary<String, Any>{
            for competition in allcompetitions{
                NSLog("Competition found locally: \(competition.key)")
                

                
                if let stad = competition.value as? Dictionary<String, Any>{
                    for compstadium in stad{
                        if let _ = compstadium.value as? NSDictionary{
                            let newTeam = Stadium(stadionID: compstadium.key)
                           //We NSLog("key: \(compstadium.key)")
                            allTeams.append(newTeam)
                           // allTeams.insert(newTeam, at: 0)
                        }
                    }
                }
            }
        }
        allTeams = allTeams.sorted(by: { $0.hometeam! < $1.hometeam! })
        NSLog("all Teams: \(allTeams.count)")
        return allTeams
    }
}

protocol ModalItemChooserDelegate {
    func didselect(selected: Stadium)
}
