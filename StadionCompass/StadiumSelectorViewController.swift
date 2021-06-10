//
//  StadiumSelectorViewController.swift
//  StadionCompass
//
//  Created by Holger Krupp on 25.12.17.
//  Copyright © 2017 Holger Krupp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StadiumSelectorViewController: UITableViewController, UIGestureRecognizerDelegate {

    var leagues = (getDataFromPlist(plist: "StadionData", key: nil) as? Dictionary<String, Any>)?.sorted(by: { $0.key < $1.key })
    
    var allTeams = [Stadium]()
    var filteredTeams = [Stadium]()
    
    var visitedStadiums = [Int?]()
    var allStadiums = [Int?]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
       allTeams = loadTeams()
        if let homeStadium = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            UIView.setAnimationsEnabled(false)
            performSegue(withIdentifier: "showNavigator", sender: self)
            
        }else{
            
            UIView.setAnimationsEnabled(true)
        }
        
        for _ in 0...(leagues?.count)!{
            allStadiums.append(0)
            visitedStadiums.append(0)
        }
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = NSLocalizedString("stadiumtable.search",value: "Search", comment: "shown in searchbar")
        self.title = NSLocalizedString("stadiumtable.title",value: "Select your team", comment: "shown in TableView")
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
    
      
         /*
         //Would be so nice, but it's not working as geofencing is limited to about 20 Geofences
        
         DispatchQueue.global().async {
            for team in self.allTeams{
                team.setlocationNotification()
            }
        }*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadheaders()
        self.tableView.reloadData()


        
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.setAnimationsEnabled(true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true


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
        
        let leagueName = leagues![section].key.split(separator: "|").last  ?? ""
        
        
        let _ = "\(leagueName)  (\(visitedStadiums[section] ?? 0) / \(allStadiums[section] ?? 0))"
        var visits : Int?
        if let leagueVisits = getObjectForKeyFromPersistentStorrage(leagues![section].key) as? Int{
            visits = leagueVisits
        }
        
        
        
        return "\(leagueName)  (\(visits ?? 0) / \(allStadiums[section] ?? 0))"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stadiums = (leagues![section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key })
        allStadiums[section] = stadiums.count
        
        if isFiltering() {
            return filteredTeams.filter({$0.league == leagues![section].key}).count
        }
        
        return stadiums.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! StadiumSelectorCell
        let Stadion: Stadium
        if isFiltering() {
            Stadion = filteredTeams.filter({$0.league == leagues![indexPath.section].key})[indexPath.row]
        }else{
            let stadium = (leagues![indexPath.section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key }).sorted(by: {$0.key < $1.key})[indexPath.row]
            Stadion = Stadium.init(stadionID: stadium.key)
        }
        
        
        
        cell.IconLabel.text = ""
        
        
        if let visitData = Stadion.getVisits() {
            for data in visitData{

                if data.key == "numberOfVisists", data.value is Int {
                    let oldNumberOfVisits = data.value as! Int
                    if oldNumberOfVisits > 0{
                        visitedStadiums[indexPath.section] = visitedStadiums[indexPath.section]! + 1
                        cell.IconLabel.text = "🏟️"
                    }
                }
            }
        }
        
        cell.TeamNameLabel.text = Stadion.hometeam
        cell.StadiumNameLabel.text = Stadion.name
        
        cell.homeStadionLabel.isHidden = true
        if let homeID = getObjectForKeyFromPersistentStorrage("homestadium") as? String{
            if homeID == Stadion.hometeam{
                cell.homeStadionLabel.isHidden = false
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let Stadion: Stadium
        if isFiltering() {
            Stadion = filteredTeams.filter({$0.league == leagues![indexPath.section].key})[indexPath.row]

        }else{
            let stadium = (leagues![indexPath.section].value as! Dictionary<String, Any>).sorted(by: { $0.key < $1.key }).sorted(by: {$0.key < $1.key})[indexPath.row]
            Stadion = Stadium.init(stadionID: stadium.key)
            
        }

        if let hometeam = Stadion.hometeam{
            UIView.setAnimationsEnabled(true)
            setObjectForKeyToPersistentStorrage("homestadium", object: hometeam)
        }
       
       // self.navigationController?.performSegue(withIdentifier: "showNavigator", sender: self)
 
    }
    

    

    
    func reloadheaders(){
        for index in 0...numberOfSections(in: self.tableView){
            self.tableView.headerView(forSection: index)
        }
      //  self.tableView.reloadData()
    }
    
    func loadTeams() -> [Stadium]{
        NSLog("loading teams")
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
                        }
                    }
                }
            }
        }
        NSLog("all Teams: \(allTeams.count)")
        return allTeams
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTeams = allTeams.filter({( stadium : Stadium) -> Bool in
            return (stadium.hometeam?.lowercased().contains(searchText.lowercased()))! || (stadium.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}

extension StadiumSelectorViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


