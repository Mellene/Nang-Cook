//
//  AuthServiceGoogle.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/9/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class AuthService {
    static let shared = AuthService()
    
    /// Google 로그인 + FirebaseAuth 연동
    func signInWithGoogle(presenting windowScene: UIWindowScene,
                          completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard (FirebaseApp.app()?.options.clientID) != nil else {
            return completion(.failure(NSError(domain: "MissingFirebaseClientID", code: -1)))
        }
        
        // 키 윈도우의 rootViewController 찾아서 GoogleSignIn에 전달
        guard let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return completion(.failure(NSError(domain: "NoRootViewController", code: -1)))
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard
                let user         = signInResult?.user,
                let idToken      = user.idToken?.tokenString  // idToken은 여전히 옵셔널
            else {
                return completion(.failure(NSError(domain:"GoogleAuthFailed", code:-1)))
            }
            // 이제 accessToken은 non-optional이므로 ? 없이 바로 꺼내세요
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error)); return
                }
                completion(.success(authResult!))
            }
        }
    }
}
