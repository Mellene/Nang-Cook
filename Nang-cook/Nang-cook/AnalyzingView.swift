//
//  AnalyzingView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/29/25.
//

import SwiftUI

struct AnalyzingView: View {
    let image: UIImage // 분석할 이미지
    @Binding var path: [NavigationDestination] // 화면 전환 경로
    
    var body: some View {
        VStack {
            Spacer()
            
            // 로딩 스피너 UI
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: 0.2)
                    .stroke(Color.green, lineWidth: 10)
                    .rotationEffect(.degrees(Date().timeIntervalSince1970 * 200)) // 회전 애니메이션
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: Date().timeIntervalSince1970)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            }
            .frame(width: 180, height: 180)
            .padding(.bottom, 20)
            
            Text("AI가 재료를 분석중입니다...")
                .font(.title2).bold()
                .padding(.bottom, 5)
            
            Text("잠시만 기다려주세요")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: analyzeImage) // 뷰가 나타나면 분석 시작
    }
    
    private func analyzeImage() {
        Task {
            // AI 분석 시뮬레이션
            let results = await runAIAnalysis(on: image)
            // 분석 완료 후, .results 화면으로 이동
            path.append(.results(image: image, ingredients: results))
        }
    }
    
    // 실제 AI 모델을 호출하는 부분 (현재는 2초 지연으로 대체)
    private func runAIAnalysis(on image: UIImage) async -> [String] {
        // ---
        // ‼️ 여기에 실제 AI Object Detection 모델을 호출하는 코드를 넣으세요.
        // ---
        try? await Task.sleep(for: .seconds(2))
        return ["양파", "달걀", "대파", "토마토", "삼겹살", "두부", "버섯", "마늘", "고추장"]
    }
}
