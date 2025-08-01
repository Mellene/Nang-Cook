//
//  MainView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct MainView: View {
    
    @StateObject private var vm = NicknameViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 80)
                
                // ───── 안내 ─────
                Text("환영합니다!")
                    .font(.title).bold()
                
                Text("신규 회원이신가요?\n회원님의 닉네임을 정해주세요!")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                
                // ───── 닉네임 입력 ─────
                VStack(spacing: 12) {
                    TextField("ex: 동동이", text: $vm.nickname)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: vm.nickname) { vm.validateNickname() }
                        .disabled(vm.isSaved) // 저장 후에는 입력 비활성화
                    
                    // 👇 --- 버튼 로직 변경 --- 👇
                    // isSaved, isAvailable 상태에 따라 버튼을 다르게 보여줍니다.
                    if vm.isSaved {
                        // 3. 최종 저장 완료 후 "확인" 버튼
                        Button(action: {
                            
                        }) {
                            // TODO: 닉네임 설정 완료 후 다음 화면으로 넘어가거나
                            // 현재 뷰를 닫는 코드를 여기에 추가하세요.
                            NavigationLink {
                                NewView()
                            } label: {
                                Text("확인")
                                    .frame(width: 240, height: 44)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    } else if vm.isAvailable {
                        // 2. 닉네임 사용 가능 시 "닉네임 확정" 버튼
                        Button("닉네임 확정") { vm.saveNickname() }
                            .frame(width: 240, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(vm.isSaving) // 저장 중에는 비활성화
                        
                    } else {
                        // 1. 초기 상태 "닉네임 중복 확인" 버튼
                        Button("닉네임 중복 확인") { vm.checkAvailability() }
                            .frame(width: 240, height: 44)
                            .background(Color("FontColor2"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(!vm.canCheck)
                    }
                    // --- 버튼 로직 변경 끝 ---
                    
                    // 결과 메시지
                    if let msg = vm.feedback {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(vm.feedbackColor)
                    }
                }
                .padding(.horizontal)
                
                // ‼️ 기존의 최종 저장 버튼은 위의 로직에 통합되어 제거합니다.
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("냉쿡")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("오류", isPresented: $vm.showError, actions: {
            Button("확인", role: .cancel) { }
        }, message: {
            Text(vm.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        })
    }
}

final class NicknameViewModel: ObservableObject {
    // 👉 입력값
    @Published var nickname: String = ""
    
    // 👉 상태 플래그
    @Published private(set) var isValidFormat = false
    @Published private(set) var isAvailable   = false
    @Published private(set) var isChecking    = false
    @Published private(set) var isSaving      = false
    @Published private(set) var isSaved       = false // ✅ 최종 저장 완료 상태
    
    // 👉 피드백
    @Published var feedback: String?
    @Published var showError = false
    var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    // ───── 규칙 ─────
    private let maxLength = 12
    private let regex = #"^[A-Za-z0-9가-힣]{2,\#(12)}$"#
    private let bannedWords: [String] = [
        "sex", "porn", "fuck", "shit", "kill", "murder", "rape", "terror",
        "씨발", "병신", "개새끼", "자지", "보지", "성범죄자", "자지털", "보지털",
        "pussy", "dick", "suck", "섹스", "야동", "존나"
    ]
    
    /// 입력 형식 검증 (onChange)
    func validateNickname() {
        isAvailable = false // 새로 입력되면 “미확인” 상태로
        isSaved = false     // ✅ 새로 입력되면 "미저장" 상태로 초기화
        feedback    = nil
        
        // 1) 길이 체크
        guard nickname.count <= maxLength else {
            isValidFormat = false
            feedback = "최대 \(maxLength)자까지 입력 가능합니다."
            return
        }
        
        // 2) 정규식 체크
        guard nickname.range(of: regex, options: .regularExpression) != nil else {
            isValidFormat = false
            feedback = "한글·영문·숫자 2~\(maxLength)자만 허용됩니다."
            return
        }
        
        // 3) 금지어 필터링
        let lower = nickname.lowercased()
        if bannedWords.contains(where: { lower.contains($0) }) {
            isValidFormat = false
            feedback = "부적절한 단어가 포함되어 있습니다."
            return
        }
        
        // 모두 통과
        isValidFormat = true
    }
    
    // ───── 중복 확인 ─────
    func checkAvailability() {
        guard isValidFormat, !isChecking else { return }
        isChecking = true
        feedback   = "확인 중..."
        
        let nickDoc = db.collection("nicknames")
                          .document(nickname.lowercased())
        
        nickDoc.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isChecking = false
            
            if let error = error {
                self.presentError(error.localizedDescription)
                return
            }
            self.isAvailable = snapshot?.exists == false
            self.feedback = self.isAvailable ? "사용 가능한 닉네임입니다 🙆‍♂️"
                                             : "이미 사용 중인 닉네임입니다 😢"
        }
    }
    
    // ───── 저장 (트랜잭션) ─────
    func saveNickname() {
        // ‼️ canSave 조건에서 isAvailable만 확인하도록 변경
        guard isValidFormat, isAvailable, !isSaving, let uid = Auth.auth().currentUser?.uid else { return }
        isSaving  = true
        
        let nickRef = db.collection("nicknames")
                        .document(nickname.lowercased())
        let userRef = db.collection("users")
                        .document(uid)
        
        db.runTransaction({ (tx, err) -> Any? in
            if (try? tx.getDocument(nickRef))?.exists == true {
                err?.pointee = NSError(domain: "Nickname",
                                      code: 1,
                                      userInfo: [NSLocalizedDescriptionKey : "이미 사용 중입니다"])
                return nil
            }
            tx.setData(["uid" : uid], forDocument: nickRef)
            tx.setData(["nickname": self.nickname], forDocument: userRef, merge: true)
            return nil
        }) { [weak self] _, error in
            guard let self = self else { return }
            self.isSaving = false
            
            if let error = error {
                self.presentError(error.localizedDescription)
                // ✅ 실패 시 다시 중복 확인을 하도록 상태 초기화
                self.isAvailable = false
            } else {
                // ✅ 성공 시 isSaved 상태를 true로 변경
                self.isSaved = true
                self.feedback = "닉네임이 설정되었습니다 🎉"
            }
        }
    }
    
    // ───── 유틸 ─────
    private func presentError(_ message: String) {
        errorMessage = message
        showError    = true
    }
    
    // ───── Button 활성/비활성 조건 ─────
    var canCheck: Bool { isValidFormat && !isChecking }
    // ‼️ canSave는 이제 사용되지 않습니다.
    
    // 결과 메시지 색상
    var feedbackColor: Color {
        // ✅ isSaved 상태 추가
        if isSaved { return .blue }
        return isAvailable ? .green : .red
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
