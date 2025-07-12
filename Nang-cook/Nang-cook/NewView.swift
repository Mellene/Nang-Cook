//
//  NewView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/12/25.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore

struct NewView: View {
    @StateObject private var userVM = UserViewModel()
    
    // MARK: – 사진 선택 관련 상태
    @State private var showingSourceAction = false
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var pickedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("냉쿡").font(.headline)
                    Spacer()
                  }
                  .frame(height: 44)
                  .background(Color.white)
                  .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                Spacer(minLength: 80)
                
                // ───── 제목 & 안내 ─────
                VStack(spacing: 12) {
                    Text("요리합시다!")
                        .font(.title).bold()
                    Text("""
                       \(userVM.nickname)님의 냉장고 속
                       식재료를 찍어주세요!
                       """)
                    .font(.body)
                    .multilineTextAlignment(.center)
                }
                
                Spacer(minLength: 40)
                
                // ───── 선택 버튼 ─────
                Button {
                    showingSourceAction = true
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("식재료 사진 찍으러 가기")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(.systemGreen).opacity(0.8))
                    )
                    .foregroundColor(.white)
                }
                // 확인 대화창
                .confirmationDialog("사진을 어디에서 가져올까요?", isPresented: $showingSourceAction, titleVisibility: .visible) {
                    Button("카메라로 촬영") {
                        imagePickerSource = .camera
                        showingImagePicker = true
                    }
                    Button("사진 보관함에서 선택") {
                        imagePickerSource = .photoLibrary
                        showingImagePicker = true
                    }
                    Button("취소", role: .cancel) { }
                }
                // 이미지 피커 모달
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(sourceType: imagePickerSource, image: $pickedImage)
                }
                
                Spacer()
                
                // ───── 미리보기 ─────
                if let uiImg = pickedImage {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .padding()
                }
            }
            
            .safeAreaInset(edge: .bottom) {
                TabBar()
            }
        }
    }
}


// MARK: – UIKit 래퍼: UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate   = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

    // MARK: - 2) 하단 탭바 (재사용)
    struct TabBar: View {
        @State private var selection = 0
        private let icons = ["house.fill", "slash.circle", "bell", "person"]
        
        var body: some View {
            HStack {
                ForEach(icons.indices, id: \.self) { idx in
                    Spacer()
                    Button {
                        selection = idx
                    } label: {
                        Image(systemName: icons[idx])
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(selection == idx ? .primary : .secondary)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground).ignoresSafeArea())
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator)),
                alignment: .top
            )
        }
    }

final class UserViewModel: ObservableObject {
    @Published var nickname: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchNickname()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchNickname() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid)
        
        // 실시간으로 변경 감지하려면 snapshotListener 사용
        listener = userRef.addSnapshotListener { [weak self] snap, err in
            guard let data = snap?.data(), err == nil else { return }
            let name = data["nickname"] as? String ?? ""
            DispatchQueue.main.async {
                self?.nickname = name
            }
        }
    }
}

struct NewView_Previews: PreviewProvider {
    static var previews: some View {
        NewView()
    }
}
