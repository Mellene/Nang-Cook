//
//  NewView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/12/25.
//

import SwiftUI
import PhotosUI // PhotosPicker를 위해 임포트
import FirebaseAuth
import FirebaseFirestore

// MARK: - 1. 화면의 상태를 명확히 정의
enum NavigationDestination: Hashable {
    case analyzing(UIImage)
    case results(image: UIImage, ingredients: [String])
}

struct NewView: View {
    @StateObject private var userVM = UserViewModel()
    
    // MARK: - 상태 변수
    @State private var path = [NavigationDestination]()
    @State private var showingConfirmationDialog = false // ✅ 메뉴 표시 여부
    @State private var showingImagePicker = false      // ✅ 이미지 피커 표시 여부
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera // ✅ 카메라/앨범 소스
        
    var body: some View {
        // 내비게이션 경로(path)를 추적하는 NavigationStack
        NavigationStack(path: $path) {
            VStack {
                // 상단 커스텀 네비게이션 바
                HStack {
                    Spacer()
                    Text("냉쿡").font(.headline)
                    Spacer()
                }
                .frame(height: 44)
                
                // 메인 컨텐츠
                mainContentView
            }
            .safeAreaInset(edge: .bottom) { TabBar() }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            
            // MARK: - 내비게이션 목적지 설정
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .analyzing(let image):
                    AnalyzingView(image: image, path: $path)
                case .results(let image, let ingredients):
                    ResultsView(image: image, ingredients: ingredients)
                }
            }
        }
    }
    
    // MARK: - Helper Views & Actions
    
    /// 메인 컨텐츠 뷰
    private var mainContentView: some View {
        VStack {
            Spacer()
            
            Text("요리합시다!")
                .font(.largeTitle).bold()
                .padding(.bottom, 8)
            
            Text("\(userVM.nickname)님의 냉장고를\nAI로 분석해 재료를 확인해보세요!")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            // 사진 선택을 위한 Confirmation Dialog를 띄우는 버튼
            Button(action: {
                showingConfirmationDialog = true
            }) {
                Text("냉장고 속 들여다 보기")
                    .font(.title3).bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        // MARK: - 이미지 피커 시트
        // UIKit의 UIImagePickerController를 띄우기 위해 .sheet를 사용
        .confirmationDialog("사진 가져오기", isPresented: $showingConfirmationDialog, titleVisibility: .visible) {
            Button("카메라로 촬영") {
                self.imagePickerSource = .camera
                self.showingImagePicker = true
            }
            Button("사진 보관함에서 선택") {
                self.imagePickerSource = .photoLibrary
                self.showingImagePicker = true
            }
            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: self.imagePickerSource) { image in
                // 이미지가 선택되면, .analyzing 화면으로 이동
                path.append(.analyzing(image))
            }
        }
    }
}

// MARK: – UIKit 래퍼: UIImagePickerController
// ImagePicker.swift (또는 코드가 위치한 파일)
struct ImagePicker: UIViewControllerRepresentable {
    // ‼️ 타입이 @Binding이 아닌, (UIImage) -> Void 클로저 타입이어야 합니다.
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // ‼️ 바인딩에 값을 할당하는 대신, onImagePicked 클로저를 호출합니다.
                parent.onImagePicked(image)
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
    // 'db'를 저장 프로퍼티가 아닌 '계산 프로퍼티'로 변경
    private var db: Firestore {
        // db를 처음 사용하려는 시점에 인스턴스 생성
        return Firestore.firestore()
    }
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
