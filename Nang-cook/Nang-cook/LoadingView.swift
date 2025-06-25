//
//  LoadingView.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
            VStack {
                Spacer() // 컨텐츠를 중앙으로 밀기 위한 Spacer
                Spacer()
                // 로고 이미지와 원형 배경
                ZStack {
                    // 로고 이미지
                    Image("AppMainIcon") // 2단계에서 추가한 에셋 이름
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .clipShape(Circle())
                        
                }

                Spacer().frame(height: 50) // 로고와 아래 텍스트 사이 간격

                // 하단 텍스트
                Text("자취하는 당신의")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("요리 품격을 높여줄,")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // 컨텐츠를 중앙으로 밀기 위한 Spacer
                Spacer()
            }
        }
    }

    // 미리보기용 코드
    struct LoadingView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
