//
//  ContentView.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

// ContentView.swift
import SwiftUI
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        // NavigationStack은 여기에 딱 한 번만 선언합니다.
        NavigationStack {
            if userViewModel.isLoading {
                ProgressView()
            } else if userViewModel.user == nil {
                // 👇 --- 이 부분이 추가되었습니다 --- 👇
                // 1. 로그인된 사용자가 아예 없으면 LoginView를 보여줍니다.
                SignUpView()
                    .environmentObject(userViewModel) // LoginView도 ViewModel이 필요할 수 있습니다.
            } else if userViewModel.user?.nickname != nil {
                // 2. 닉네임이 있으면 NewView를 보여줍니다.
                NewView()
                    .environmentObject(userViewModel)
            } else {
                // 3. 닉네임이 없으면 MainView를 보여줍니다.
                MainView()
                // MainView도 userViewModel을 사용하도록 전달해주는 것이 좋습니다.
                    .environmentObject(userViewModel)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
