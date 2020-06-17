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
    @Published var chargeSpeed:Double = 0.00
    @Published var timestamp:Double = 0.0
    @Published var ladeText:String = "Not Charging"
    @Published var minTemp: Double = 0.0
    @Published var maxTemp: Double = 0.0
    @Published var inletTemp: Double = 0.0
    @Published var isLoggedIn: Bool = false
    @Published var isConnected: Bool = true
    @Published var aviableTemp = (minTemp:false,maxTemp:false,inletTemp:false)
    
    func setSoc(newSoc:Double){
        UserDefaults.standard.set(newSoc, forKey: "soc")
        if ( soc != newSoc ) {
            soc = newSoc
        }
    }
    
    private func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                }
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
        dateFormatter.timeZone = .current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    func getTimestampColor() -> Color{
        
        let timeInterval = NSDate().timeIntervalSince1970
        let diffInterval = (timeInterval - self.timestamp) / 60
        
        if ( self.isConnected ) {
            if ( diffInterval >= 1 && diffInterval < 10 ) {
                UserDefaults.standard.set("1", forKey: "timestampColor")
                return .yellow
            } else if ( diffInterval > 10 ) {
                UserDefaults.standard.set("2", forKey: "timestampColor")
                return .orange
            } else {
                UserDefaults.standard.set("0", forKey: "timestampColor")
                return .white
            }
        } else {
            UserDefaults.standard.set("3", forKey: "timestampColor")
            return .red
        }
    }
    
    func setIsCharging(newState:Bool){
        if ( newState != isCharging ) {
            isCharging = newState
            if ( isCharging ) {
                ladeText = "Charging"
            } else {
                ladeText = "Not Charging"
            }
        }
    }
    
    func setChargeSpeed(newSpeed:Double){
        if ( chargeSpeed != newSpeed ) {
            if ( isCharging ) {
                chargeSpeed = newSpeed
            } else {
                chargeSpeed = 0.00
            }
        }
    }
    
    func getChargeSpeed() -> String{
        if ( isCharging ) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter.string(from: chargeSpeed as NSNumber)! + " kW"
        } else {
            return ""
        }
    }
    
    func setTimestamp(newTime:Double){
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = .current //Set timezone that you want
        dateFormatter2.locale = NSLocale.current
        dateFormatter2.dateFormat = "HH:mm:ss" //Specify your format that you want
        let dateComp = Date()
        UserDefaults.standard.set(dateFormatter2.string(from: dateComp), forKey: "timestampComp")

        if ( newTime != timestamp ) {
            timestamp = newTime
            
            let date = Date(timeIntervalSince1970: timestamp)
            UserDefaults.standard.set(dateFormatter2.string(from: date), forKey: "timestamp")
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .current //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            UserDefaults.standard.set(dateFormatter.string(from: date), forKey: "timestampLong")
        }
    }
    
    func setTemperatures(newTemp:Double,section:Int){
        switch(section){
        case 0:
            if ( minTemp != newTemp ) {
                minTemp = newTemp
                let ret = Int(Darwin.round(newTemp))
                UserDefaults.standard.set("\(ret)°", forKey: "minTemp")
            }
            break;
        case 1:
            if ( maxTemp != newTemp ) {
                maxTemp = newTemp
                let ret = Int(Darwin.round(newTemp))
                UserDefaults.standard.set("\(ret)°", forKey: "maxTemp")
            }
            break;
        case 2:
            if ( inletTemp != newTemp ) {
                inletTemp = newTemp
                let ret = Int(Darwin.round(newTemp))
                UserDefaults.standard.set("\(ret)°", forKey: "inletTemp")
            }
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
        let token = UserDefaults.standard.string(forKey: "token")
        if ( token != nil ) {
            isLoggedIn = true
                        
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                self.startRefresh()
            }
            self.startRefresh()
        }
    }
    
    @objc func startRefresh(){
        if ( isLoggedIn ) {
            let token = UserDefaults.standard.string(forKey: "token")!
            let akey = UserDefaults.standard.string(forKey: "akey")!
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
                        if json.keys.contains("soc_display") {
                            let soc_display_json = json["soc_display"] as? NSNumber
                            let soc_bms_json = json["soc_bms"] as? NSNumber
                            DispatchQueue.main.async {
                                self.isConnected = true
                                if ( soc_display_json != nil ) {
                                    let socdata = json["soc_display"] as! NSNumber
                                    self.setSoc(newSoc: socdata.doubleValue)
                                } else if ( soc_bms_json != nil ) {
                                    let socdata = json["soc_bms_json"] as! NSNumber
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
                                    
                                    let timestamp2 = json["last_extended"] as! NSNumber
                                    self.setTimestamp(newTime: timestamp2.doubleValue)
                                    
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
                                        self.setChargeSpeed(newSpeed: chargeSpeed2.doubleValue)
                                    } else {
                                        self.setChargeSpeed(newSpeed: 0.00)
                                    }

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
                                    self.reloadComplications()
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
    
    func setLoginStatus(newState:Bool) {
        isLoggedIn = newState
    }
}

struct ContentView: View {
    
    //EV Stuff
    @ObservedObject var evdata = EVData()
    @State private var showingLogoutAlert = false
    
    //Login Stuff
    @State var akey = ""
    @State var pass = ""
    @State var isError = false
    @State var errorText = ""
    @State var isDisabled = false

    var body: some View {
        VStack(alignment: .center){
            if ( self.evdata.LoggedIn() ) {
                ScrollView {
                
                    Text(self.evdata.getSoc() + "%").padding(.bottom,5).font(Font.custom("Arial", size: 42)).foregroundColor(self.evdata.getSocColor())
                    Text(self.evdata.getChargeSpeed()).font(.footnote).foregroundColor(.blue)
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
                            Text("No battery temperatures available").font(Font.custom("Arial", size: 10)).frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        }.padding(.bottom,20)
                    }
                     
                    Text(self.evdata.getTimestamp()).font(Font.custom("Arial", size: 10)).padding(.bottom,20).foregroundColor(self.evdata.getTimestampColor())
                    
                    Button(action: {
                        self.showingLogoutAlert = true
                    }) {
                        Text("Logout")
                    }
                    .alert(isPresented:$showingLogoutAlert) {
                        Alert(title: Text("Logout"), message: Text("You really want to log out?"), primaryButton: .default(Text("No")) {
                                self.showingLogoutAlert = false
                            }, secondaryButton: .default(Text("Yes")){
                                self.showingLogoutAlert = false
                                self.isDisabled = false;
                                self.akey = ""
                                self.pass = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.evdata.setLogout()
                                }
                            })
                    }
                    
                }.padding(.bottom,3)
            } else {
                
                TextField("AKey",text:$akey).textContentType(.username).multilineTextAlignment(.center).padding(.bottom,3)
                SecureField("Password", text: $pass).textContentType(.password).multilineTextAlignment(.center).padding(.bottom,3)
                Button(action: {
                    self.isDisabled = true
                    
                    let parameters = ["akey":self.akey,"password":self.pass]
                    let url = URL(string: "https://app.evnotify.de/login")!
                    
                    let session = URLSession.shared

                    //now create the URLRequest object using the url object
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST" //set http method as POST

                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                    } catch let error {
                        print(error.localizedDescription)
                    }

                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/vnd.hmrc.1.0+json", forHTTPHeaderField: "Accept")
                    
                    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                        guard error == nil else {
                            return
                        }

                        guard let data = data else {
                            return
                        }

                        do {
                            //create json object from data
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                
                                if let appDomain = Bundle.main.bundleIdentifier {
                                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                }
                                
                                if json.keys.contains("token") {
                                    UserDefaults.standard.set(json["token"], forKey: "token")
                                    UserDefaults.standard.set(self.akey, forKey: "akey")
                                    //self.evdata.isLoggedIn = true;
                                    
                                    DispatchQueue.main.async {
                                        self.evdata.setLoginStatus(newState: true)
                                        self.evdata.startRefresh()
                                    }
                                    
                                    
                                    
                                } else {
                                    self.pass = ""
                                    self.isError = true
                                    self.errorText = "Error Text"
                                    let m = json["error"];
                                    if let userInfo = m as? [String: Any] {
                                        self.errorText = userInfo["message"] as? String ?? ""
                                    }
                                    self.isDisabled = false
                                    //self.evdata.isLoggedIn = false
                                    DispatchQueue.main.async {
                                        self.evdata.setLoginStatus(newState: false)
                                    }
                                }
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    })
                    task.resume()
                }) {
                    Text("Login")
                }.disabled(akey.isEmpty || pass.isEmpty || self.isDisabled)
                .alert(isPresented: $isError ) {
                    Alert(title: Text(""), message: Text(self.errorText), dismissButton: .default(Text("Try again")))
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
