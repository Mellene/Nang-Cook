//
//  FirebaseManager.swift
//  Nang-cook
//
//  Created by 강윤호 on 8/12/25.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit

class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    // 분석 결과(이미지, 재료 목록)를 Firebase에 저장하는 함수
    func saveAnalysisResult(image: UIImage, ingredients: [String], completion: @escaping (Error?) -> Void) {
        // 1. 현재 로그인된 사용자 ID 가져오기
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: 사용자가 로그인되어 있지 않습니다.")
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // 2. 이미지를 JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))
            return
        }
        
        // 3. Firebase Storage에 이미지 업로드
        let imageRef = storage.reference().child("user_images/\(userId)/\(UUID().uuidString).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil, error == nil else {
                completion(error)
                return
            }
            
            // 4. 업로드된 이미지의 다운로드 URL 가져오기
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(error)
                    return
                }
                
                // 5. Firestore에 데이터 저장
                // 사용자별로 분석 기록을 저장하기 위해 `users/{userId}/analyses` 경로 사용
                let docRef = self.db.collection("users").document(userId).collection("analyses").document()
                
                let data: [String: Any] = [
                    "imageUrl": downloadURL.absoluteString,
                    "ingredients": ingredients,
                    "createdAt": Timestamp(date: Date())
                ]
                
                docRef.setData(data) { error in
                    if let error = error {
                        print("❌ Firestore 저장 실패: \(error)")
                    } else {
                        print("✅ Firestore에 분석 결과 저장 완료!")
                    }
                    completion(error)
                }
            }
        }
    }
}
