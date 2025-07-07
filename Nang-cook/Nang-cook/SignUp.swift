//
//  SignUp.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/7/25.
//

//
//  SignIn.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String=""
    @State private var showPasswordFields: Bool = false
    @State private var password: String=""
    @State private var confirmPassword: String=""
    
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
                
                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                if !showPasswordFields {
                    Button(action: {
                        withAnimation {
                            showPasswordFields = true
                        }
                    }) {
                        Text("Continue")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 15)
                            .padding()
                            .background(Color("FontColor2"))
                            .cornerRadius(8)
                    }
                } else {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                }
                if showPasswordFields {
                    Button(action: {
                        // TODO: 이메일로 계속하기 로직 추가
                        print("Send verification to \(email)")
                    }) {
                        Text("이메일 인증 보내기")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 15)
                            .padding()
                            .background(Color("FontColor2"))
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                
                // Or 구분선
                HStack {
                    VStack { Divider() }
                    Text("또는")
                        .padding(.horizontal)
                        .font(.system(size: 15))
                    VStack { Divider() }
                }
                .padding(.vertical)
                
                // 소셜 로그인 버튼들
                // 구글로 계속하기
                Button(action: {
                    //TODO: 구글 로그인 로직 추가
                }) {
                    HStack {
                        Text("Continue with Google")
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 10)
                    .padding()
                    .background(Color("FontColor2"))
                    .cornerRadius(8)
                }
                Button(action: {
                    // TODO: Apple 로그인 로직 추가
                }) {
                    HStack {
                        Text("Continue with Apple")
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 10)
                    .padding()
                    .background(Color("FontColor2"))
                    .cornerRadius(8)
                }
                Text("계정이 있으신가요?")
                    .font(.system(size: 15))
                    .padding(.top)
                
                HStack {
                    Button(action: {
                        //TODO: 구글 로그인 로직 추가
                    }) {
                        NavigationLink {
                            SignInView()
                        } label: {
                            Text("로그인")
                                .font(.system(size: 16))
                                .underline()
                        }
                        .foregroundColor(Color("FontColor2"))
                        .frame(width: 250, height: 15)
                        .padding()
                        .underline()
                    }
                }
                
                Spacer()
                
                Text("By clicking continue, you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            .padding()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
