//
//  UserViewModel.swift
//  Nang-cook
//
//  Created by 강윤호 on 8/13/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// 사용자 정보를 담을 간단한 구조체
struct AppUser {
    let uid: String
    var nickname: String?
}

// 사용자 정보를 Firestore에서 가져오고 감시하는 ViewModel
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = true
    
    private var listenerRegistration: ListenerRegistration?

    init() {
        // 현재 로그인된 사용자가 있는지 확인
        guard let firebaseUser = Auth.auth().currentUser else {
            // 로그인된 사용자가 없으면 로딩 종료
            self.isLoading = false
            print("로그인된 사용자가 없습니다.")
            return
        }
        
        // Firestore에서 사용자 정보 가져오기
        let db = Firestore.firestore()
        // addSnapshotListener를 사용해 실시간으로 변경사항을 감시합니다.
        listenerRegistration = db.collection("users").document(firebaseUser.uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            // 데이터 수신 후 로딩 상태 변경
            self.isLoading = false
            
            guard let document = snapshot, document.exists, error == nil else {
                // 문서가 없거나 에러 발생 시, 닉네임이 없는 사용자로 처리
                self.user = AppUser(uid: firebaseUser.uid, nickname: nil)
                print("사용자 문서를 찾을 수 없거나 에러 발생. 닉네임 설정이 필요합니다.")
                return
            }
            
            // 문서에서 닉네임 데이터 가져오기
            let nickname = document.data()?["nickname"] as? String
            self.user = AppUser(uid: firebaseUser.uid, nickname: nickname)
            print("사용자 정보 업데이트: \(self.user?.nickname ?? "닉네임 없음")")
        }
    }
    
    deinit {
        // ViewModel이 메모리에서 해제될 때 리스너도 함께 제거합니다.
        listenerRegistration?.remove()
        print("UserViewModel 리스너가 제거되었습니다.")
    }
}
