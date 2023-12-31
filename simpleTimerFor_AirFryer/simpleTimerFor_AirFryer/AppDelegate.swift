//
//  AppDelegate.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//

import UIKit
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, fVmodel {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        let defSortArr: [[SortObj]] = [ [.init(title: .server, selected: false), .init(title: .local, selected: true) ],
                           [.init(title: .name, selected: true), .init(title: .latest, selected: false)] ]
        
        /// 기존 저장값
        if let data = usrDef.object(forKey: "sortType") as? Data, let sorts = try? JSONDecoder().decode([[SortObj]].self, from: data) {
            foodShared.sortType = sorts
            
        } else { // 첫실행
            if let data = try? JSONEncoder().encode(defSortArr) {
                usrDef.setValue(data, forKey: "sortType")
                
                if let savedData = usrDef.object(forKey: "sortType") as? Data,
                    let sorts = try? JSONDecoder().decode([[SortObj]].self, from: savedData) {
                    foodShared.sortType = sorts
                }
            }
            
        }
        

        foodShared.loadFoods(save: foodShared.saveSpot, sort: foodShared.selectedType)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // deep link처리 시 아래 url값 가지고 처리
        let url = response.notification.request.content.userInfo

        completionHandler()
    }
}
