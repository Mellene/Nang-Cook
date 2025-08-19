//
//  AnalyzingView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/29/25.
//

import SwiftUI
import GoogleGenerativeAI
import FirebaseAuth

struct AnalyzingView: View {
    let image: UIImage // 분석할 이미지
    @Binding var path: [NavigationDestination] // 화면 전환 경로
    
    @State private var isAnimating = false
    
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
                    .rotationEffect(.degrees(isAnimating ? 360 : 0)) // 회전 애니메이션
                
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
        .onAppear {
            // 애니메이션 시작
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            analyzeImageAndSave()
        }
    }
    
    private func analyzeImageAndSave() {
        Task {
            // AI 분석 시뮬레이션
            let ingredients = await runAIAnalysis(on: image)
            // 분석 완료 후, .results 화면으로 이동
            guard !ingredients.isEmpty else {
                // TODO: 사용자에게 분석 실패를 알리는 UI 처리
                // 예: path를 pop 하거나 에러 화면으로 전환
                print("분석 실패. 이전 화면으로 돌아갑니다.")
                path.removeLast()
                return
            }
            // 2. Firebase에 결과 저장 (오류 처리를 포함한 비동기 호출)
            await saveToFirebase(image: image, ingredients: ingredients)
            
            // 3. 분석 완료 후, .results 화면으로 이동
            path.append(.results(image: image, ingredients: ingredients))
        }
    }
    
    // 실제 AI 모델을 호출하는 부분 (현재는 2초 지연으로 대체)
    private func runAIAnalysis(on image: UIImage) async -> [String] {
        // ---
        let apiKey = "AIzaSyCxD1K7QLYjvMT7pY8Y7aIpwVH74CZAY-o"
        //모델 설정
        let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: apiKey)
        let prompt = """
이 이미지에 있는 식재료들을 감지하고, 그 목록을 JSON 문자열 배열 형태로 반환해 줘. 다른 설명은 필요 없고, 오직 JSON 배열만 제공해야 해. 예시: ["양파", "달걀", "대파", "토마토", "삼겹살", "두부", "버섯", "마늘", "고추장"]
"""
        do {
            // UIImage를 모델이 이해할 수 있는 Data로 변환
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Error: 이미지 데이터를 변환할 수 없습니다.")
                return []
            }
            
            // 이미지와 프롬프트를 함께 전송하여 응답 요청
            let response = try await model.generateContent(prompt, imageData as! ThrowingPartsRepresentable)
            
            // 응답 텍스트를 JSON으로 파싱
            if let responseText = response.text,
               let data = responseText.data(using: .utf8) {
                
                let ingredients = try JSONDecoder().decode([String].self, from: data)
                print("✅ AI 분석 결과: \(ingredients)")
                return ingredients
            }
            
        } catch {
            print("❌ Gemini API 호출 중 에러 발생: \(error.localizedDescription)")
        }
        
        // 실패 시 빈 배열 반환
        return []
    }
    
    private func saveToFirebase(image: UIImage, ingredients: [String]) async {
        return await withCheckedContinuation { continuation in
            FirebaseManager.shared.saveAnalysisResult(image: image, ingredients: ingredients) { error in
                if let error = error {
                    print("Firebase 저장 중 에러 발생: \(error.localizedDescription)")
                    // TODO: 사용자에게 저장 실패를 알리는 UI 처리 (선택 사항)
                }
                continuation.resume()
            }
        }
    }
}
