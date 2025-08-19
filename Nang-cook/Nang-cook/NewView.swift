//
//  NewView.swift
//  Nang-cook
//
//  Created by 강윤호 on 7/12/25.
//
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

// ‼️ NavigationDestination은 프로젝트 내에서 단 한 번만 정의되어야 합니다.
// 모든 내비게이션 목적지를 여기에 포함해야 합니다.
enum NavigationDestination: Hashable {
    case analyzing(UIImage)
    case results(image: UIImage, ingredients: [String])
    case newView // MainView에서 NewView로 이동하기 위해 이 case가 반드시 필요합니다.

    // Hashable을 올바르게 구현합니다.
    func hash(into hasher: inout Hasher) {
        switch self {
        case .analyzing(let image):
            hasher.combine("analyzing")
            hasher.combine(image)
        case .results(let image, let ingredients):
            hasher.combine("results")
            hasher.combine(image)
            hasher.combine(ingredients)
        // newView case에 대한 해시 로직을 추가합니다.
        case .newView:
            hasher.combine("newView")
        }
    }
}

struct NewView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    // 내비게이션 스택과 이미지 피커 관련 상태
    @State private var path = [NavigationDestination]()
    @State private var showingConfirmationDialog = false
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera
    
    // 👇 --- 탭바 선택 상태를 관리할 변수 추가 --- 👇
    @State private var selectedTab: Int = 0
            
    var body: some View {
        // 내비게이션 경로(path)를 추적하는 NavigationStack
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // 상단 커스텀 네비게이션 바
                HStack {
                    Spacer()
                    Text("냉쿡").font(.headline)
                    Spacer()
                }
                .frame(height: 44)
                
                // 👇 --- 선택된 탭에 따라 다른 뷰를 보여줌 --- 👇
                currentTabView
            }
            .safeAreaInset(edge: .bottom) {
                // TabBar에 selection 바인딩을 전달
                TabBar(selection: $selectedTab)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            
            // MARK: - 내비게이션 목적지 설정
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .analyzing(let image):
                    AnalyzingView(image: image, path: $path)
                case .results(let image, let ingredients):
                    ResultsView(image: image, ingredients: ingredients)
                case .newView:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Views
    
    /// 선택된 탭에 따라 보여줄 뷰를 결정
    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case 0: // 홈 탭
            homeContentView
        case 3: // 프로필 탭
            SettingsView()
        default: // 나머지 탭
            // 각 탭에 맞는 뷰를 여기에 추가할 수 있습니다.
            VStack {
                Spacer()
                Text("탭 \(selectedTab + 1)")
                Spacer()
            }
        }
    }
    
    /// 홈 탭의 메인 컨텐츠 뷰
    private var homeContentView: some View {
        VStack {
            Spacer()
            
            Text("요리합시다!")
                .font(.largeTitle).bold()
                .padding(.bottom, 8)
            
            if let nickname = userVM.user?.nickname {
                Text("\(nickname)님의 냉장고를\nAI로 분석해 재료를 확인해보세요!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
            }
            
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
                path.append(.analyzing(image))
            }
        }
    }
}

// MARK: - 설정 페이지 뷰 (새로 추가)
struct SettingsView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        List {
            Section(header: Text("계정")) {
                if let nickname = userVM.user?.nickname {
                    Text(nickname)
                }
                
                Button(role: .destructive, action: {
                    // 👇 --- 로그아웃 액션 설명 추가 --- 👇
                    // 이 코드가 실행되면 Firebase에서 사용자가 로그아웃됩니다.
                    // UserViewModel이 이 로그아웃 상태 변화를 감지하고,
                    // 최상위 뷰(ContentView)가 화면을 자동으로
                    // 로그인/초기 화면(StartView)으로 전환시켜 줍니다.
                    try? Auth.auth().signOut()
                }) {
                    Text("로그아웃")
                }
            }
        }
        .listStyle(.grouped)
    }
}


// MARK: - UIKit 래퍼: UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
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
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 하단 탭바 (수정됨)
struct TabBar: View {
    // 👇 --- @State 대신 @Binding으로 변경 --- 👇
    @Binding var selection: Int
    private let icons = ["house.fill", "slash.circle", "bell", "person"]
    
    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { idx in
                Spacer()
                Button {
                    // 바인딩된 selection 값을 변경
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

struct NewView_Previews: PreviewProvider {
    static var previews: some View {
        NewView()
    }
}
