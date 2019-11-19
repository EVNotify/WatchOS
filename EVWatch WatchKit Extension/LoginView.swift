//
//  LoginView.swift
//  EVWatch
//
//  Created by EVSalomon on 06.11.19.
//
import SwiftUI

struct LoginView: View {
    @State var akey = ""
    @State var pass = ""
    @State var isDisabled = false
    @State var isLoggedin = true
    @State var isError = false
    @State var errorText = ""
    
    var body: some View {
        VStack(alignment: .center){
            if ( !self.isLoggedin) {
                TextField("AKey",text:$akey)
                .textContentType(.username)
                .multilineTextAlignment(.center)
                .padding(.bottom,3)
                SecureField("Password", text: $pass)
                .textContentType(.password)
                .multilineTextAlignment(.center)
                .padding(.bottom,3)
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
                                    self.isLoggedin = true;
                                } else {
                                    self.pass = ""
                                    self.isError = true
                                    self.errorText = "Error Text"
                                    let m = json["error"];
                                    if let userInfo = m as? [String: Any] {
                                        self.errorText = userInfo["message"] as? String ?? ""
                                    }
                                    self.isDisabled = false
                                    self.isLoggedin = false
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
                    Alert(title: Text(""), message: Text(self.errorText), dismissButton: .default(Text("Erneut versuchen")))
                }
            } else {
                ContentView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedin:false)
    }
}
