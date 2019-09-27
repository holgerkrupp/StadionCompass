//
//  CloudKitHelper.swift
//  StadionCompass
//
//  Created by Holger Krupp on 09.03.19.
//  Copyright © 2019 Holger Krupp. All rights reserved.
//

import UIKit
import CoreData
import CloudKit


class CloudKitHelper: NSObject {
    
    
    func setObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoragedidchange), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)
        
  NotificationCenter.default.addObserver(self, selector: #selector(persistentStoragewillchange), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: nil)
        
    }
    
    
    let container = CKContainer.default()
    

    func subscribeChanges() {
        let subscription = CKDatabaseSubscription(subscriptionID: "StadiumSubscription")
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { savedSubscriptions, deletedSubscriptionIDs, operationError in
            if operationError != nil {
                print(operationError as Any)
                return
            } else {
                print("Subscribed")
            }
        }
        
        container.privateCloudDatabase.add(operation)
        container.publicCloudDatabase.add(operation)
    }

    
    @objc func persistentStoragedidchange(){
        print("Notification that persistentStoragedidchange")
    }
    
    @objc func persistentStoragewillchange(){
        print("Notification that persistentStoragewillchange")
    }
}
