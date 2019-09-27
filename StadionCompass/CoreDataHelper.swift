//
//  CoreDataHelper.swift
//  StadionCompass
//
//  Created by Holger Krupp on 08.03.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//
import UIKit
import CoreData
import Foundation
import CloudKit

class CoreDataHelper: NSObject {

    var context: NSManagedObjectContext?
    
    let useCloudKit = false
    
    override init() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        context = appdelegate.persistentContainer.viewContext
    }
    
    func deleteDatabase(){

        do {
        let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let file = documentDirectory.appendingPathComponent("StadiumData.sqlite")

            if FileManager.default.fileExists(atPath: file.path){
                print("exists")
                do{
                    try FileManager.default.removeItem(at: file)
                    
                    print("database deleted")
                }catch{
                    print(error)
                }
            }else{
                print("file \(file) not found")
            }
        }catch{
            print(error)
        }
    }
    
    func saveCompetition(competition: String){
        
        if useCloudKit == true{
            
            let LeagueID = CKRecord.ID(recordName: competition)
            let LeagueRecord = CKRecord(recordType: "Leagues", recordID: LeagueID)
            
            LeagueRecord["name"] = competition as String
            
            let myContainer = CKContainer.default()
            let publicDatabase = myContainer.publicCloudDatabase
            
            publicDatabase.save(LeagueRecord) {
                (record, error) in
                if let error = error {
                    print("saving error to cloudKit")
                    print(error.localizedDescription)
                    return
                }
                print("saved to CloudKit: \(competition)")
            }
        }else{
            let Entityname = "Leagues"
            if let context = self.context{
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                guard let newEntity = NSEntityDescription.entity(forEntityName: Entityname, in: context) else{
                    return
                }
                let newLeague = NSManagedObject(entity: newEntity, insertInto: context)
                newLeague.setValue(competition, forKey: "name")
                do {
                    try context.save()
                    print("saved: \(competition)")
                }catch{
                    print("saving error")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func readCompetitions(){
        if useCloudKit == true{
            
            let myContainer = CKContainer.default()
            let publicDatabase = myContainer.publicCloudDatabase
            
            let predicate = NSPredicate(value: true)

            
            let query = CKQuery(recordType: "Leagues", predicate: predicate)
            
            publicDatabase.perform(query, inZoneWith: nil,
                                        completionHandler: ({results, error in
                                            
                                            if (error != nil) {
                                                    print("Cloud Error")
                                                
                                            } else {
                                                if results!.count > 0 {

                                                        for entry in results! {

                                                            let LeagueName = entry["name"] as? String
                                                            print("name from CloudKit \(String(describing: LeagueName))")
                                                            
                                                        }
                                                }else {
                                                            print("UPC Not Found")
                                                    
                                                    }
                                                }
                                            }))
            
            
            
        
    }else{
            let Entityname = "Leagues"
            if let context = self.context{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname)
                do {
                    let results = try context.fetch(request)
                    for r in results {
                        if let result = r as? NSManagedObject{
                            guard let name = result.value(forKey: "name") as? String else{
                                return
                            }
                            print("read name: \(name)")
                        }
                    }
                    
                }catch{
                    print(error)
                }
            }
        }
    }
    
}
