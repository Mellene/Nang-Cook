//
//  main.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/7/25.
//

import SwiftUI
import FirebaseAuth
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
                    
                    // 중복 확인 버튼
                    Button("닉네임 중복 확인") { vm.checkAvailability() }
                        .frame(width: 240, height: 44)
                        .background(Color("FontColor2"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    // 결과 메시지
                    if let msg = vm.feedback {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(vm.feedbackColor)
                    }
                }
                .padding(.horizontal)
                
                // ───── 최종 저장 ─────
                Button("확인") { vm.saveNickname() }
                    .buttonStyle(.bordered)
                    .disabled(!vm.canSave)
                
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
    
    // 👉 피드백
    @Published var feedback: String?
    @Published var showError = false
    var errorMessage: String?
    
    // ───── 규칙 ─────
    /// 한글/영문/숫자 2~12자   (특수문자·공백 불가)
    private let maxLength = 12
    private let regex = #"^[A-Za-z0-9가-힣]{2,\#(12)}$"#  // 2~12자
    private let bannedWords: [String] = [
            // 예시
            "sex", "porn", "fuck", "shit",
            "kill", "murder", "rape", "terror",
            "씨발", "병신", "개새끼", "자지", "보지",
            "성범죄자", "자지털", "보지털", "pussy",
            "dick", "suck", "섹스", "야동", "존나"
            // 한글 비속어도 추가
        ]
    
    /// 입력 형식 검증 (onChange)
    func validateNickname() {
        isAvailable = false      // 새로 입력되면 “미확인” 상태로
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
        
        let db = Firestore.firestore()
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
        guard canSave, let uid = Auth.auth().currentUser?.uid else { return }
        isSaving  = true
        
        let db          = Firestore.firestore()
        let nickRef     = db.collection("nicknames")
                            .document(nickname.lowercased())
        let userRef     = db.collection("users")
                            .document(uid)
        
        db.runTransaction({ (tx, err) -> Any? in
            if (try? tx.getDocument(nickRef))?.exists == true {
                err?.pointee = NSError(domain: "Nickname",
                                       code: 1,
                                       userInfo: [NSLocalizedDescriptionKey : "이미 사용 중입니다"])
                return nil
            }
            tx.setData(["uid" : uid], forDocument: nickRef)      // 닉네임 → UID 매핑
            tx.updateData(["nickname" : self.nickname], forDocument: userRef)
            return nil
        }) { [weak self] _, error in
            guard let self = self else { return }
            self.isSaving = false
            
            if let error = error {
                self.presentError(error.localizedDescription)
            } else {
                self.feedback = "닉네임이 설정되었습니다 🎉"
                // ✅ 성공 후 다른 화면으로 이동하거나 dismiss 처리
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
    var canSave : Bool { isValidFormat && isAvailable && !isSaving }
    
    // 결과 메시지 색상
    var feedbackColor: Color {
        isAvailable ? .green : .red
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
