//
//  ExtensionDelegate.swift
//  EVWatch WatchKit Extension
//
//  Created by EVSalomon on 06.11.19.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate,URLSessionDownloadDelegate {
    
    var backgroundUrlSession:URLSession?
    var pendingBackgroundURLTask:WKURLSessionRefreshBackgroundTask?
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)  as? [String: Any] {
                if json.keys.contains("soc_display") {
                    let soc_json = json["soc_display"] as? NSNumber
                    let soc = soc_json?.doubleValue
                    //let soc2 = Double.random(in: 0 ..< 100.1)
                    UserDefaults.standard.set(soc, forKey: "soc")
                    
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.timeZone = .current //Set timezone that you want
                    dateFormatter2.locale = NSLocale.current
                    dateFormatter2.dateFormat = "HH:mm:ss"
                    let dateComp = Date()
                    UserDefaults.standard.set(dateFormatter2.string(from: dateComp), forKey: "timestampComp")
                    
                    self.reloadComplications()
                } else if json.keys.contains("last_extended") {
                    let timestamp2 = json["last_extended"] as! NSNumber
                    let timestamp = timestamp2.doubleValue
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.timeZone = .current //Set timezone that you want
                    dateFormatter2.locale = NSLocale.current
                    dateFormatter2.dateFormat = "HH:mm:ss" //Specify your format that you want
                    
                    UserDefaults.standard.set(dateFormatter2.string(from: date), forKey: "timestamp")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = .current //Set timezone that you want
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                    
                    UserDefaults.standard.set(dateFormatter.string(from: date), forKey: "timestampLong")
                    
                    let dateComp = Date()
                    UserDefaults.standard.set(dateFormatter2.string(from: dateComp), forKey: "timestampComp")
                    
                    let timeInterval = NSDate().timeIntervalSince1970
                    let diffInterval = (timeInterval - timestamp) / 60
                    
                    if ( diffInterval >= 1 && diffInterval < 10 ) {
                        UserDefaults.standard.set("1", forKey: "timestampColor")
                    } else if ( diffInterval > 10 ) {
                        UserDefaults.standard.set("2", forKey: "timestampColor")
                    } else {
                        UserDefaults.standard.set("0", forKey: "timestampColor")
                    }
                    
                    
                    let formatter_temp = NumberFormatter()
                    formatter_temp.numberStyle = .decimal
                    formatter_temp.maximumFractionDigits = 0
                     
                    let minTempNumberJson = json["battery_min_temperature"] as? NSNumber
                    if ( minTempNumberJson != nil ) {
                        let minTempNumber = json["battery_min_temperature"] as! NSNumber
                        let ret = Int(Darwin.round(minTempNumber.doubleValue))
                        UserDefaults.standard.set("\(ret)°", forKey: "minTemp")
                    } else {
                        UserDefaults.standard.set("0°", forKey: "minTemp")
                    }
                    
                    let maxTempNumberJson = json["battery_max_temperature"] as? NSNumber
                    if ( maxTempNumberJson != nil ) {
                        let maxTempNumber = json["battery_max_temperature"] as! NSNumber
                        let ret = Int(Darwin.round(maxTempNumber.doubleValue))
                        UserDefaults.standard.set("\(ret)°", forKey: "maxTemp")
                    } else {
                        UserDefaults.standard.set("0°", forKey: "maxTemp")
                    }

                    let inletTempNumberJson = json["battery_inlet_temperature"] as? NSNumber
                    if ( inletTempNumberJson != nil ) {
                        let inletTempNumber = json["battery_inlet_temperature"] as! NSNumber
                        let ret = Int(Darwin.round(inletTempNumber.doubleValue))
                        UserDefaults.standard.set("\(ret)°", forKey: "inletTemp")
                    } else {
                        UserDefaults.standard.set("0°", forKey: "inletTemp")
                    }
                    
                    self.reloadComplications()
                }
                
                self.pendingBackgroundURLTask?.setTaskCompletedWithSnapshot(false)
                self.backgroundUrlSession = nil
                //self.applicationRefreshBackgroundTask?.setTaskCompletedWithSnapshot(false)
                scheduleSnapshot()
            } else {
                self.pendingBackgroundURLTask?.setTaskCompletedWithSnapshot(false)
                self.backgroundUrlSession = nil
                //self.applicationRefreshBackgroundTask?.setTaskCompletedWithSnapshot(false)
                scheduleSnapshot()
            }
        } catch {
            print("\(error.localizedDescription)")
            
            self.pendingBackgroundURLTask?.setTaskCompletedWithSnapshot(false)
            self.backgroundUrlSession = nil
            scheduleSnapshot()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.pendingBackgroundURLTask?.setTaskCompletedWithSnapshot(false)
            self.backgroundUrlSession = nil
            scheduleSnapshot()
        }
    }
    
   
    
    func scheduleSnapshot(){
        let check = UserDefaults.standard.string(forKey: "token")
        if ( check != nil ) {
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 30 * 60), userInfo: nil) { (error: Error?) in
                
                //NSLog("ExtensionDelegate: background task %@",
                //error == nil ? "scheduled successfully" : "NOT scheduled: \(error!)")
            }
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
       //scheduleSnapshot()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //scheduleSnapshot()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        scheduleSnapshot()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                if var request = self.getRequestForRefreshSoC() {
                    request.httpMethod = "GET" //set http method as GET
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/vnd.hmrc.1.0+json", forHTTPHeaderField: "Accept")
                    
                    let backgroundConfig = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
                    backgroundConfig.sessionSendsLaunchEvents = true
                    backgroundConfig.httpAdditionalHeaders = ["Accept":"application/vnd.hmrc.1.0+json","Content-Type":"application/json"]
                    backgroundConfig.isDiscretionary = true
                    //Be sure to set self as delegate on this urlSession
                    let urlSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
                    let downloadTask = urlSession.downloadTask(with: request)
                    downloadTask.resume()
                }
                
                if var request = self.getRequestForRefreshExtend() {
                
                    request.httpMethod = "GET" //set http method as GET
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/vnd.hmrc.1.0+json", forHTTPHeaderField: "Accept")
                    
                    let backgroundConfig = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
                    backgroundConfig.sessionSendsLaunchEvents = true
                    backgroundConfig.httpAdditionalHeaders = ["Accept":"application/vnd.hmrc.1.0+json","Content-Type":"application/json"]
                    //Be sure to set self as delegate on this urlSession
                    let urlSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
                    let downloadTaskExt = urlSession.downloadTask(with: request)
                    downloadTaskExt.resume()
                }
                scheduleSnapshot()
                backgroundTask.setTaskCompletedWithSnapshot(false)
                
                //backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
                //Be sure to set self as delegate on this urlSession
                self.backgroundUrlSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil) //set to nil in task:didCompleteWithError: delegate method

                self.pendingBackgroundURLTask = urlSessionTask
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func getRequestForRefreshSoC() -> URLRequest? {
        let check = UserDefaults.standard.string(forKey: "token")
        if ( check != nil ) {
            let akey = UserDefaults.standard.string(forKey: "akey")!
            let token = UserDefaults.standard.string(forKey: "token")!
            guard let url = URL(string: "https://app.evnotify.de/soc?akey=" + akey + "&token=" + token) else{
                return nil
            }
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    func getRequestForRefreshExtend() -> URLRequest? {
        let check = UserDefaults.standard.string(forKey: "token")
        if ( check != nil ) {
            let akey = UserDefaults.standard.string(forKey: "akey")!
            let token = UserDefaults.standard.string(forKey: "token")!
            guard let url = URL(string: "https://app.evnotify.de/extended?akey=" + akey + "&token=" + token) else{
                return nil
            }
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                }
            }
        }
    }
}
