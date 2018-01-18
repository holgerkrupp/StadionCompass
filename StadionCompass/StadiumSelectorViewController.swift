//
//  StadiumSelectorViewController.swift
//  StadionCompass
//
//  Created by Holger Krupp on 25.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
//

import UIKit

class StadiumSelectorViewController: UITableViewController {

    var leagues = (getDataFromPlist(plist: "StadionData", key: nil) as? Dictionary<String, Any>)?.sorted(by: { $0.key < $1.key })
    var visitedStadiums = [Int?]()
    var allStadiums = [Int?]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let stadium = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            performSegue(withIdentifier: "showNavigator", sender: self)
        }else{
            UIView.setAnimationsEnabled(true)
        }
        for _ in 0...(leagues?.count)!{
            allStadiums.append(0)
            visitedStadiums.append(0)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadheders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        if leagues?.count != nil{

            return (leagues?.count)!
        }else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       let _ = "\(leagues![section].key)  (\(visitedStadiums[section] ?? 0) / \(allStadiums[section] ?? 0))"
        var visits : Int?
        if let leagueVisits = getObjectForKeyFromPersistentStorrage(leagues![section].key) as? Int{
            visits = leagueVisits
        }
        
        
        return "\(leagues![section].key)  (\(visits ?? 0) / \(allStadiums[section] ?? 0))"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stadiums = (leagues![section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key })
        allStadiums[section] = stadiums.count
        
        return stadiums.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        let stadium = (leagues![indexPath.section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key }).sorted(by: {$0.key < $1.key})[indexPath.row]
        let Stadion = Stadium.init(stadionID: stadium.key)
        var StadionText = stadium.key
        
        
        if let visitData = Stadion.getVisits() {
            for data in visitData{

                if data.key == "numberOfVisists", data.value is Int {
                    let oldNumberOfVisits = data.value as! Int
                    if oldNumberOfVisits > 0{
                        visitedStadiums[indexPath.section] = visitedStadiums[indexPath.section]! + 1
                        StadionText = "🏟️ " + stadium.key
                        
                    }
                }
            }
        }
        
        
        cell.textLabel?.text = StadionText

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stadium = (leagues![indexPath.section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key }).sorted(by: {$0.key < $1.key})[indexPath.row]
        UIView.setAnimationsEnabled(true)
        setObjectForKeyToPersistentStorrage("homestadium", object: stadium.key)
       // self.navigationController?.performSegue(withIdentifier: "showNavigator", sender: self)
        
    }
    
    func reloadheders(){
        for index in 0...numberOfSections(in: self.tableView){
            self.tableView.headerView(forSection: index)
        }
      //  self.tableView.reloadData()
    }

}
