//
//  StartView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/7/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경색 (에셋 카탈로그에 등록하거나 직접 RGB 지정)
                Color("StartColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // 1) 로고 & 타이틀
                    VStack(spacing: -20) {
                        Image("AppMainIcon")    // Assets.xcassets 에 넣은 냉장고 캐릭터
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    }
                    
                    // 2) 설명 문구
                    Text("""
                        자취를 시작하면서 요리하기로 다짐하고,\  
                        배달앱을 키고 계셨나요?  
                        여러분의 다짐을 실현시켜드릴게요 :)
                        """)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("FontColor"))
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 3) 버튼들
                    VStack(spacing: 16) {
                        Button(action: {
                            // TODO: 로그인 화면으로 이동
                        }) {
                            NavigationLink {
                                SignInView()
                            } label: {
                                Text("로그인 하기")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .frame(width: 200, height: 15)
                                    .padding()
                                    .background(Color("FontColor2"))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            // TODO: 계정 생성(SignUp) 화면으로 이동
                        }) {
                            NavigationLink {
                                SignUpView()
                            } label: {
                                Text("계정 생성하기")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .frame(width: 200, height: 15)
                                    .padding()
                                    .background(Color("FontColor2"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.bottom, 200)
                }
            }
        }
    }
}


struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
