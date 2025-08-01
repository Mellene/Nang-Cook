//
//  SignIn.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var showPasswordFields: Bool = false
    @State private var password: String = ""
    @State private var errorMsg: String?
    @State private var isVerified = false  // 로그인 성공 플래그

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text("냉쿡")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("로그인")
                    .fontWeight(.medium)
                
                Text("이메일을 입력해주세요")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                
                // 1) 이메일 입력
                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // 2) Continue → 비밀번호 폼 노출
                if !showPasswordFields {
                    Button("Continue") {
                        withAnimation { showPasswordFields = true }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("FontColor2"))
                    .cornerRadius(8)
                }
                
                // 3) 비밀번호 입력 & 로그인 버튼
                if showPasswordFields {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // 에러 메시지
                    if let err = errorMsg {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button("Log-in") {
                        errorMsg = nil
                        guard !email.isEmpty, !password.isEmpty else {
                            errorMsg = "이메일과 비밀번호를 모두 입력해주세요."
                            return
                        }
                        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                            if let error = error {
                                errorMsg = error.localizedDescription
                            } else {
                                isVerified = true
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("FontColor2"))
                    .cornerRadius(8)
                    .padding(.top, 8)
                }
                
                Divider()
                    .padding(.vertical)
                
                // 소셜 로그인 버튼들
                Button("Continue with Google") {
                    // TODO: Google 로그인 로직
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color("FontColor2"))
                .cornerRadius(8)
                
                Button("Continue with Apple") {
                    // TODO: Apple 로그인 로직
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color("FontColor2"))
                .cornerRadius(8)
                
                Spacer()
                
                // 기존 로그인 링크
                HStack {
                    Text("계정이 없으신가요?")
                        .font(.system(size: 15))
                    NavigationLink("계정 생성", destination: SignUpView())
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
            .padding()
            // 로그인 성공(isVerified == true)이 되면 MainView()로 푸시
            .navigationDestination(isPresented: $isVerified) {
                MainView()
            }
        }
    }
}



struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
