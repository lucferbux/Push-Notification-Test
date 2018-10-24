//
//  AppDelegate.swift
//  Push Notification Test
//
//  Created by lucas fernández on 24/10/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import UIKit
import UserNotifications

fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            print("Recibo una notificacion normal")
            print(aps)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let aps = userInfo["aps"] as! [String: AnyObject]
        if aps["content-available"] as? Int == 1 {
            keepAlive()
        }
    }

    func keepAlive() {
        var urlCoponents = URLComponents()
        urlCoponents.scheme = "http"
        urlCoponents.host = ""
        urlCoponents.port = 5000
        urlCoponents.path = "/alive"
        let mailItem = URLQueryItem(name: "mail", value: "fake@mail.com")
        urlCoponents.queryItems = [mailItem]
        
        guard let url = urlCoponents.url else { fatalError("Could not create URL")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.background(withIdentifier: "myRequest")
        let session = URLSession(configuration: config)
        
        let task = session.downloadTask(with: request)
        
        task.resume()
    }


}

extension AppDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission grante: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // Takes the device token and convert it into a string, token provided by APNS that uniquely identifies this app
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}
