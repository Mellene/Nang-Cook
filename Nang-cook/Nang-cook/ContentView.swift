//
//  ContentView.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    // 현재 로딩 중인지 상태를 관리하는 변수
    @State private var isLoading = true

    var body: some View {
        // isLoading 값에 따라 보여줄 뷰를 결정
        if isLoading {
            LoadingView()
                .onAppear {
                    // LoadingView가 화면에 나타나면 2초 후에 실행
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        // 애니메이션과 함께 부드럽게 전환
                        withAnimation {
                            self.isLoading = false
                        }
                    }
                }
        } else {
            StartView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
