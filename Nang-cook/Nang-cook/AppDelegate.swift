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
    
    // 1. Firebase 앱을 가장 먼저 초기화합니다.
    FirebaseApp.configure()
    
    // 2. 디버그 모드일 때만 로컬 에뮬레이터에 연결합니다.
    #if DEBUG
    print("🐛 디버그 모드: Firebase 로컬 에뮬레이터에 연결합니다.")
    
    // 로컬 네트워크의 Mac IP 주소 또는 localhost
    // 시뮬레이터에서는 localhost(127.0.0.1)를 사용하고,
    // 실제 기기 테스트 시에는 Mac의 IP 주소를 사용해야 합니다.
    let host = "127.0.0.1" // 실제 기기 테스트 시 "192.168.1.223" 등으로 변경
    
    // Firestore 에뮬레이터 설정
    let settings = Firestore.firestore().settings
    settings.host = "\(host):8080"
    settings.isSSLEnabled = false
    settings.cacheSettings = MemoryCacheSettings()
    Firestore.firestore().settings = settings
    
    // Auth 에뮬레이터 설정
    Auth.auth().useEmulator(withHost: host, port: 9099)
    
    #else
    // --- 실제 앱 배포(릴리즈) 시에는 이 부분이 실행됩니다. ---
    // 별도의 코드가 없어도 FirebaseApp.configure()에 의해
    // 자동으로 실제 Firebase 서버에 연결됩니다.
    print("🚀 릴리즈 모드: 실제 Firebase 서버에 연결합니다.")
    #endif

    return true
  }
}

// --- App 진입점 ---
@main
struct NangCook: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  // App 구조체의 init()은 제거합니다. 모든 설정은 AppDelegate에서 처리됩니다.

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
