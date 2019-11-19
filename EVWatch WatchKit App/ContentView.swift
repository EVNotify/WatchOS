//
//  ContentView.swift
//  EVWatch WatchKit Extension
//
//  Created by EVSalomon on 06.11.19.
//

import SwiftUI

class EVData: ObservableObject {
    @Published var soc: Double = 0.0
    @Published var isCharging: Bool = false
    @Published var chargeSpeed:String = ""
    @Published var timestamp:Double = 0.0
    @Published var ladeText:String = "Nicht Ladend"
    @Published var minTemp: Double = 0.0
    @Published var maxTemp: Double = 0.0
    @Published var inletTemp: Double = 0.0
    @Published var isLoggedIn: Bool = true
    @Published var isConnected: Bool = true
    @Published var aviableTemp = (minTemp:false,maxTemp:false,inletTemp:false)
    
    func setSoc(newSoc:Double){
        soc = newSoc
        UserDefaults.standard.set(soc, forKey: "soc")
        
        self.reloadComplications()
        //WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate:userInfo:)

    }
    
    private func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                }
                //WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.click) // haptic only for debugging
            }
        }
    }

    
    func getSocColor() -> Color{
        if soc < 15 { return .red }
        else if soc < 30 { return .orange }
        else if soc < 50 { return .yellow }
        return .green
    }
    
    func getSoc() -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: soc as NSNumber) ?? ""
    }
    
    func getTempColor(type:Int) -> Color{
        switch(type) {
            case 0:
                if (minTemp < 20) { return .blue; }
                else if (minTemp < 30) { return .green; }
                else if (minTemp < 35) { return .orange; }
                return .red;
            case 1:
                if (maxTemp < 20) { return .blue; }
                else if (maxTemp < 30) { return .green; }
                else if (maxTemp < 35) { return .orange; }
                return .red;
            case 2:
                if (inletTemp < 20) { return .blue; }
                else if (inletTemp < 30) { return .green; }
                else if (inletTemp < 35) { return .orange; }
                return .red;
            default: return .white
        }
    }
    
    func getTimestamp() -> String{
        
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+1") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss" //Specify your format that you want
        
        return dateFormatter.string(from: date)
    }
    
    func getTimestampColor() -> Color{
        
        let timeInterval = NSDate().timeIntervalSince1970
        let diffInterval = (timeInterval - self.timestamp) / 60
        
        if ( self.isConnected ) {
            if ( diffInterval >= 1 && diffInterval < 10 ) {
                return .yellow
            } else if ( diffInterval > 10 ) {
                return .orange
            } else {
                
                return .white
            }
        } else {
            return .red
        }
    }
    
    func setIsCharging(newState:Bool){
        isCharging = newState
        if ( isCharging ) {
            ladeText = "Ladend"
        } else {
            ladeText = "Nicht Ladend"
        }
    }
    
    func setChargeSpeed(newSpeed:String){
        if ( isCharging ) {
            chargeSpeed = newSpeed + "kW"
        } else {
            chargeSpeed = ""
        }
    }
    
    func setTimestamp(newTime:Double){
        timestamp = newTime
    }
    
    func setTemperatures(newTemp:Double,section:Int){
        switch(section){
        case 0:
            minTemp = newTemp
            break;
        case 1:
            maxTemp = newTemp
            break;
        case 2:
            inletTemp = newTemp
            break;
        default:
            break;
        }
    }
    
    func getMinTemp() -> String{
        let ret = Int(Darwin.round(minTemp))
        return "\(ret)°";
    }
    func getMaxTemp() -> String{
        let ret = Int(Darwin.round(maxTemp))
        return "\(ret)°";
    }
    func getInletTemp() -> String{
        let ret = Int(Darwin.round(inletTemp))
        return"\(ret)°";
    }
    
    init(){
        self.startRefresh()
    }
    
    func startRefresh(){
        
        if ( isLoggedIn ) {
            let token = UserDefaults.standard.string(forKey: "token")!
            let akey = UserDefaults.standard.string(forKey: "akey")!
                    
            //let parameters = ["akey":akey,"token":token]
                    
            var url = URL(string: "https://app.evnotify.de/soc?akey=" + akey + "&token=" + token)!
            
            var session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "GET" //set http method as GET
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/vnd.hmrc.1.0+json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                    return
                }

                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        //print(json)
                        if json.keys.contains("soc_display") {
                            let soc_json = json["soc_display"] as? NSNumber
                            DispatchQueue.main.async {
                                self.isConnected = true
                                if ( soc_json != nil ) {
                                    let socdata = json["soc_display"] as! NSNumber
                                    self.setSoc(newSoc: socdata.doubleValue)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.isLoggedIn = false
                                if let appDomain = Bundle.main.bundleIdentifier {
                                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                }
                            }
                        }
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                    print(error.localizedDescription)
                }
            })
            task.resume()
            
            if ( isLoggedIn ) {
            
                url = URL(string: "https://app.evnotify.de/extended?akey=" + akey + "&token=" + token)!
                
                session = URLSession.shared

                //now create the URLRequest object using the url object
                request = URLRequest(url: url)
                request.httpMethod = "GET" //set http method as GET

                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/vnd.hmrc.1.0+json", forHTTPHeaderField: "Accept")
                
                task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    guard error == nil else {
                        DispatchQueue.main.async {
                            self.isConnected = false
                        }
                        return
                    }

                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.isConnected = false
                        }
                        return
                    }

                    do {
                        //create json object from data
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                                    
                            if json.keys.contains("last_extended") {
                                
                                DispatchQueue.main.async {
                                    
                                    let chargingJson = json["charging"] as? Bool
                                    if ( chargingJson != nil ) {
                                        let charging2 = json["charging"] as! Bool
                                        self.setIsCharging(newState: charging2)
                                    } else {
                                        self.setIsCharging(newState: false)
                                    }
                                    
                                    let chargeSpeedJson = json["dc_battery_power"] as? NSNumber
                                    if ( chargeSpeedJson != nil ) {
                                        let chargeSpeed2 = json["dc_battery_power"] as! NSNumber
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .decimal
                                        formatter.maximumFractionDigits = 1
                                        self.setChargeSpeed(newSpeed: String(formatter.string(from: chargeSpeed2) ?? ""))
                                    } else {
                                        self.setChargeSpeed(newSpeed: "")
                                    }
                                    
                                    
                                    
                                    let timestamp2 = json["last_extended"] as! NSNumber
                                    self.setTimestamp(newTime: timestamp2.doubleValue)
                                    
                                    let formatter_temp = NumberFormatter()
                                    formatter_temp.numberStyle = .decimal
                                    formatter_temp.maximumFractionDigits = 0
                                     
                                    let minTempNumberJson = json["battery_min_temperature"] as? NSNumber
                                    if ( minTempNumberJson != nil ) {
                                        let minTempNumber = json["battery_min_temperature"] as! NSNumber
                                        self.setTemperatures(newTemp: minTempNumber.doubleValue, section: 0)
                                        self.aviableTemp.minTemp = true
                                    } else {
                                        self.aviableTemp.minTemp = false
                                        self.setTemperatures(newTemp: 0.0, section: 0)
                                    }
                                    
                                    let maxTempNumberJson = json["battery_max_temperature"] as? NSNumber
                                    if ( maxTempNumberJson != nil ) {
                                        let maxTempNumber = json["battery_max_temperature"] as! NSNumber
                                        self.setTemperatures(newTemp: maxTempNumber.doubleValue, section: 1)
                                        self.aviableTemp.maxTemp = true
                                    } else {
                                        self.setTemperatures(newTemp: 0.0, section: 1)
                                        self.aviableTemp.maxTemp = false
                                    }

                                    let inletTempNumberJson = json["battery_inlet_temperature"] as? NSNumber
                                    if ( inletTempNumberJson != nil ) {
                                        let inletTempNumber = json["battery_inlet_temperature"] as! NSNumber
                                        self.setTemperatures(newTemp: inletTempNumber.doubleValue, section: 2)
                                        self.aviableTemp.inletTemp = true
                                    } else {
                                        self.setTemperatures(newTemp: 0.0, section: 2)
                                        self.aviableTemp.inletTemp = false
                                    }
                                    self.isConnected = true
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.isLoggedIn = false
                                    if let appDomain = Bundle.main.bundleIdentifier {
                                        UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.isConnected = false
                            }
                        }
                    } catch let error {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.isConnected = false
                        }
                    }
                })
                task.resume()
                
                if ( self.isLoggedIn ) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.startRefresh()
                    }
                }
            }
        }
    }
    
    func LoggedIn() -> Bool{
        return isLoggedIn
    }
    
    func setLogout() {
        isLoggedIn = false
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var evdata = EVData()
    
    var body: some View {
        VStack(alignment: .center){
            if ( self.evdata.LoggedIn() ) {
                ScrollView {
                
                    Text(self.evdata.getSoc() + "%").padding(.bottom,5).font(Font.custom("Arial", size: 42)).foregroundColor(self.evdata.getSocColor())
                    Text(self.evdata.chargeSpeed).font(.footnote).foregroundColor(.blue)
                    Text(self.evdata.ladeText).padding(.bottom,10).font(.subheadline)
                    
                    if ( self.evdata.aviableTemp.minTemp || self.evdata.aviableTemp.maxTemp || self.evdata.aviableTemp.inletTemp ) {
                        HStack(alignment: .center){
                            if self.evdata.aviableTemp.minTemp  {
                                Text("Min").font(.footnote)
                                
                            }
                            if self.evdata.aviableTemp.maxTemp  {
                                if self.evdata.aviableTemp.minTemp {
                                    Text("/").font(.footnote)
                                }
                                Text("Max").font(.footnote)
                            }
                            if self.evdata.aviableTemp.inletTemp  {
                                if self.evdata.aviableTemp.minTemp || self.evdata.aviableTemp.maxTemp {
                                    Text("/").font(.footnote)
                                }
                                Text("Inlet").font(.footnote)
                            }
                        }
                        
                        HStack(alignment: .center){
                            if self.evdata.aviableTemp.minTemp  {
                                Text(self.evdata.getMinTemp()).foregroundColor(self.evdata.getTempColor(type: 0)).font(.footnote)
                                
                            }
                            if self.evdata.aviableTemp.maxTemp  {
                                if self.evdata.aviableTemp.minTemp {
                                    Text("/").font(.footnote)
                                }
                                Text(self.evdata.getMaxTemp()).foregroundColor(self.evdata.getTempColor(type: 1)).font(.footnote)
                            }
                            if self.evdata.aviableTemp.inletTemp  {
                                if self.evdata.aviableTemp.minTemp || self.evdata.aviableTemp.maxTemp {
                                    Text("/").font(.footnote)
                                }
                                Text(self.evdata.getInletTemp()).foregroundColor(self.evdata.getTempColor(type: 2)).font(.footnote)
                            }
                        }.padding(.bottom,12)
                        
                    } else {
                        HStack(alignment: .center){
                            Text("Keine Batterie-Temperaturen vorhanden").font(Font.custom("Arial", size: 10)).frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        }.padding(.bottom,20)
                    }
                     
                    Text(self.evdata.getTimestamp()).font(Font.custom("Arial", size: 10)).padding(.bottom,20).foregroundColor(self.evdata.getTimestampColor())
                    
                    Button(action: {
                        self.evdata.setLogout()
                    }) {
                        Text("Logout")
                    }
                    
                }.padding(.bottom,3)
            } else {
               LoginView(isLoggedin:false)
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
