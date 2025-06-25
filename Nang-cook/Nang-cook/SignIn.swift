//
//  SignIn.swift
//  Nang-cook
//
//  Created by 강윤호 on 6/25/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String=""
    
    var body: some View {
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
            
            TextField("email@domain.com", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button(action: {
                // TODO: 이메일로 계속하기 로직 추가
                print("Continue with email: \(email)")
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 15)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            // Or 구분선
            HStack {
                VStack { Divider() }
                Text("Or").padding(.horizontal)
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
                .foregroundColor(.black)
                .fontWeight(.medium)
                .frame(width: 250, height: 15)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            Button(action: {
                // TODO: Apple 로그인 로직 추가
            }) {
                HStack {
                    Text("Continue with Apple")
                }
                .foregroundColor(.black)
                .fontWeight(.medium)
                .frame(width: 250, height: 15)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
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

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
