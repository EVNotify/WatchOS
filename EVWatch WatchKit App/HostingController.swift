//
//  HostingController.swift
//  EVWatch WatchKit Extension
//
//  Created by EVSalomon on 06.11.19.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<LoginView> {
    override var body: LoginView {
        
        let token = UserDefaults.standard.string(forKey: "token")
        var isLoggedin = false;
        if ( token != nil ) {
            isLoggedin = true
        }
        return LoginView(isLoggedin:isLoggedin)
    }
}
