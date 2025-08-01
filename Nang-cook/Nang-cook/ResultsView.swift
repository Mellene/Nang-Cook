// ResultsView.swift

import SwiftUI

struct ResultsView: View {
    let image: UIImage
    // ✅ @State로 받아야 수정이 가능
    @State private var ingredients: [String]
    // ✅ 수정 모드 상태를 추적하는 변수
    @State private var isEditing = false
    
    // Grid 레이아웃 설정
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    init(image: UIImage, ingredients: [String]) {
        self.image = image
        // State 변수를 외부 파라미터로 초기화
        self._ingredients = State(initialValue: ingredients)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 분석된 이미지 표시
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
                // 2. 재료 확인 섹션
                Text("재료 확인")
                    .font(.title2).bold()
                
                // 3. 재료 그리드
                // ✅ 인덱스로 반복하도록 ForEach 수정
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        // ✅ isEditing 상태에 따라 Text 또는 TextField 표시
                        if isEditing {
                            HStack(spacing: 4) {
                                // ✅ $ingredients[index]로 데이터 바인딩
                                TextField("재료명", text: $ingredients[index])
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                // ✅ 삭제 버튼
                                Button(action: {
                                    ingredients.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1.5) // 수정 중일 땐 파란색 테두리
                            )
                        } else {
                            Text(ingredients[index])
                                .font(.headline)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                
                // ✅ 수정 모드일 때만 "재료 추가" 버튼 표시
                if isEditing {
                    Button(action: {
                        // 새 재료를 추가할 수 있도록 빈 문자열 아이템 추가
                        ingredients.append("")
                    }) {
                        Label("재료 추가", systemImage: "plus")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                
                // 4. 안내 및 버튼
                VStack {
                    if !isEditing {
                        Text("소지하고 계신 재료가 다르다면,\n직접 수정해주세요!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    }
                    
                    // ✅ isEditing 상태에 따라 버튼의 제목과 기능 변경
                    Button(isEditing ? "수정 완료" : "재료 수정") {
                        // 수정 모드 토글
                        isEditing.toggle()
                    }
                    .font(.headline).bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isEditing ? Color.blue : Color.white)
                    .foregroundColor(isEditing ? .white : .black)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(isEditing ? Color.clear : Color.gray, lineWidth: 1))
                    
                    // ✅ 수정 모드가 아닐 때만 등록 버튼 표시
                    if !isEditing {
                        Button("재료를 등록할게요!") {
                            saveIngredientsToFirestore()
                        }
                        .font(.headline).bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
            .padding(.vertical)
            .animation(.default, value: isEditing) // UI 변경에 애니메이션 효과 추가
            .animation(.default, value: ingredients)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    func saveIngredientsToFirestore() {
        // ---
        // ‼️ 여기에 'ingredients' 배열을 Firestore에 저장하는 코드를 구현하세요.
        // ---
        print("저장할 재료: \(ingredients.filter { !$0.isEmpty })") // 빈 재료는 제외하고 저장
    }
}
