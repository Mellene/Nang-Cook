//
//  SignUp.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/7/25.
//

//
//  SignUp.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct SignUpView: View {
    @State private var email: String = ""
    @State private var showPasswordFields: Bool = false
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMsg: String?
    @State private var infoMsg: String?
    @State private var isVerified = false
    @State private var googleSignUpError: String?
    @State private var appleSignUpError: String?
    @State private var currentNonce: String?
    
    @State private var emailSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text("냉쿡")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("계정 생성")
                    .fontWeight(.medium)
                
                Text("계정 생성을 위해서 이메일을 입력해주세요")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 32)
                
                // 이메일 입력
                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // 1단계: Continue → 비밀번호 필드 노출
                if !showPasswordFields {
                    Button("Continue") {
                        withAnimation {
                            showPasswordFields = true
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("FontColor2"))
                    .cornerRadius(8)
                }
                
                // 2단계: 비밀번호 입력
                if showPasswordFields {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("패스워드가 일치하지 않습니다.")
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    // 에러/정보 메시지
                    if let err = errorMsg {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    if let info = infoMsg {
                        Text(info)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    // 회원가입 + 인증 메일 발송
                    Button("이메일 인증 보내기") {
                        errorMsg = nil
                        infoMsg = nil
                        
                        guard password == confirmPassword else {
                            errorMsg = "비밀번호가 서로 다릅니다."
                            return
                        }
                        Auth.auth().createUser(withEmail: email, password: password) { _, error in
                            if let error = error {
                                errorMsg = error.localizedDescription
                                return
                            }
                            // 인증 메일 발송
                            Auth.auth().currentUser?.sendEmailVerification { error in
                                if let error = error {
                                    errorMsg = "인증 메일 발송 실패: \(error.localizedDescription)"
                                } else {
                                    infoMsg = "인증 메일을 보냈습니다. 메일함을 확인해주세요."
                                    emailSent = true     // ✅ 발송 완료 플래그 설정
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("FontColor2"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(emailSent)
                                        
                    // 2) 이메일 발송 후에만 보이는 “인증 완료 확인” 버튼
                    if emailSent {
                        Button("인증 완료 확인") {
                            errorMsg = nil
                            Auth.auth().currentUser?.reload { err in
                                if let err = err {
                                    errorMsg = err.localizedDescription
                                }
                                else if Auth.auth().currentUser?.isEmailVerified == true {
                                    isVerified = true   // 네비게이트 트리거!
                                } else {
                                    errorMsg = "아직 이메일 인증이 완료되지 않았습니다."
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("FontColor2"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                // Or 구분선
                VStack {
                    
                    Text("또는")
                        .font(.system(size: 15))
                        .padding(.horizontal)
                }
                .padding(.vertical)
                
                // 소셜 로그인 버튼들
                Button("Continue with Google") {
                    // TODO: Google 로그인 로직
                    googleSignUp()
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.white)
                .border(Color.black, width: 2)
                .cornerRadius(8)
                
                if let err = googleSignUpError {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }
                
                SignInWithAppleButton(
                    .signUp,
                    onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = sha256(nonce)
                        },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            handleApple(authResults: authResults)
                        case .failure(let error):
                            appleSignUpError = "Apple 로그인 실패: \(error.localizedDescription)"
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: .infinity, height: 44)
                .cornerRadius(8)
                
                if let err = appleSignUpError {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                // 기존 로그인 링크
                HStack {
                    Text("계정이 있으신가요?")
                        .font(.system(size: 15))
                    NavigationLink("로그인", destination: SignInView())
                        .font(.system(size: 15))
                        .underline()
                        .foregroundColor(Color("FontColor2"))
                }
                .padding(.top)
                
                Spacer()
                
                Text("By clicking continue, you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $isVerified){
                MainView()
            }
        }
    }
    private func googleSignUp() {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive}) as? UIWindowScene
        else {
            googleSignUpError = "앱 창을 찾을 수 없습니다."
            return
        }
        
        AuthService.shared.signInWithGoogle(presenting: windowScene) { result in
            switch result {
            case .success(let authResult):
                print("✅ 구글 로그인 성공: \(authResult.user.email ?? "")")
                isVerified = true
            case .failure(let error):
                googleSignUpError = "Google 로그인 실패: \(error.localizedDescription)"
            }
        }
    }
    // Apple 로그인 처리
        private func handleApple(authResults: ASAuthorization) {
            guard
                let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let idTokenData = credential.identityToken,
                let idTokenString = String(data: idTokenData, encoding: .utf8)
            else {
                appleSignUpError = "Apple 인증 데이터가 유효하지 않습니다."
                return
            }

            let firebaseCred = OAuthProvider.credential(
                providerID: .apple,           // ← AuthProviderID.apple
                idToken: idTokenString,
                rawNonce: nonce,
                accessToken: nil
            )

            Auth.auth().signIn(with: firebaseCred) { result, error in
                if let error = error {
                    appleSignUpError = "Firebase 로그인 실패: \(error.localizedDescription)"
                } else {
                    isVerified = true
                }
            }
        }

        // Nonce 생성
        private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0); let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""; var remaining = length
            while remaining > 0 {
                let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
                for byte in randoms where remaining > 0 {
                    if byte < charset.count {
                        result.append(charset[Int(byte)])
                        remaining -= 1
                    }
                }
            }
            return result
        }

        // SHA256 해싱
        private func sha256(_ input: String) -> String {
            let data = Data(input.utf8)
            return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

