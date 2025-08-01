//
//  Nang_cookApp.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    #if targetEnvironment(simulator)
    let host = "127.0.0.1"
    #else
    let host = "192.168.1.223"   // (실제 Mac IP로 교체)
    #endif

    Firestore.firestore().useEmulator(withHost: host, port: 8080)
    Auth.auth().useEmulator(withHost: host, port: 9099)

    return true
  }
}
@main
struct NangCook: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        FirebaseApp.configure()
        
        let settings = Firestore.firestore().settings
        settings.host = "127.0.0.1:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
    }

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
