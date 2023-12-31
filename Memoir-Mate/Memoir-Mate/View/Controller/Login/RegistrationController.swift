
//
//  RegistrationController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SwiftUI
import AVFoundation
import Photos

@available(iOS 16.0, *)
class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    
    
    private let PlusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    var user: User
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private lazy var userNicknameContainerView: UIView = {
        let image = UIImage(systemName: "person")!.withTintColor(.white, renderingMode: .alwaysOriginal)
        let view = Utilities().inputContaimerView(withImage: image, textField: userNicknameTextField)
        return view
    }()

    private lazy var userIDContainerView: UIView = {
        let image = UIImage(systemName: "person.badge.shield.checkmark")!.withTintColor(.white, renderingMode: .alwaysOriginal)
        let view = Utilities().inputContaimerView(withImage: image, textField: userIDTextField)
        return view
    }()

    
    private let userNicknameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Nickname을 입력해 주세요")
        return tf
    }()
    
    private let userIDTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "ID를 만들어 주세요")
        return tf
    }()
    
    // 텍스트 필드 설정을 구성하는 예제 함수
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        // 텍스트 필드에 대한 추가 구성을 원하는대로 추가합니다.
    }

    // 텍스트 필드에 유효성 검증을 추가하는 예제 함수
    private func validateTextField(_ textField: UITextField, minLength: Int, maxLength: Int, regex: String? = nil) -> Bool {
        guard let text = textField.text else { return false }
        guard text.count >= minLength && text.count <= maxLength else { return false }
        
        if let regex = regex {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: text)
        }
        
        return true
    }
    
    
    private let registrationButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("등록하기", for: .normal)
        button.setTitleColor(.mainColor, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - LandingPage
//    var userLandingPageCheck: Bool {
//          get {
//              UserDefaults.standard.bool(forKey: "userLandingPageCheck")
//          }
//          set {
//              UserDefaults.standard.set(newValue, forKey: "userLandingPageCheck")
//          }
//      }
    
    // MARK: - LandingPage SWiftUI View Open
    private func openSwiftUIView() {
        // 해당 컨트롤러로 오면 무조건 신규 사용자라 그냥 보여주면 됨 
        //if userLandingPageCheck == false {
            let hostingController = UIHostingController(rootView: LandingPageView())
            hostingController.sizingOptions = .preferredContentSize
            hostingController.modalPresentationStyle = .fullScreen
            self.present(hostingController, animated: true)
        //}
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.openSwiftUIView()
        }
        configureUI()
    }
    
    func checkCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("Camera: 권한 허용")
            } else {
                print("Camera: 권한 거부")
            }
        })
     }
    
    // MARK: - Selectors
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAddProfilePhoto(){
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.present(self.imagePicker, animated: true, completion: nil)
                        // 권한 허용 시 추가적인 작업 수행
                    }
                    break
                case .denied:
                    print("Album: 권한 거부")
                    // 권한 거부 시 사용자에게 프로필 등록 필요 메시지 표시
                    self.showProfileRegistrationAlert()
                    break
                case .restricted, .notDetermined:
                    print("Album: 선택하지 않음")
                    // 선택하지 않음 시 사용자에게 프로필 등록 필요 메시지 표시
                    self.showProfileRegistrationAlert()
                    break
                @unknown default:
                    break
                }
            }
    }
    
    @objc func handleRegistration() {
        guard let profileImage = profileImage else {
            print("DEBUG: 프로필 이미지를 선택해주세요")
            return
        }
        
        if validateTextField(userNicknameTextField, minLength: 3, maxLength: 14) {
            // userNicknameTextField의 입력이 유효합니다.
        } else {
            // 유효하지 않은 입력에 대한 오류 메시지 표시
            showAlert(message: "별명은 3~14자 사이여야 합니다.")
            return
        }
        
        if validateTextField(userIDTextField, minLength: 3, maxLength: 14, regex: "^[a-zA-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]{3,14}$") {
            // userIDTextField의 입력이 유효합니다.
        } else {
            // 유효하지 않은 입력에 대한 오류 메시지 표시
            showAlert(message: "사용자 ID는 3~14자 사이의 영어, 숫자, 특수문자 조합만 가능합니다.")
            return
        }
        
        guard let userNickName = userNicknameTextField.text else {return}
        guard let userID = userIDTextField.text else {return}
//        guard let userNickname = userNicknameTextField.text?.lowercased() else {return}
//        // 사용자의 이름이 항상 소문자인지 확인
        
        let credentials = AuthCredentials(userID: userID, userNickName: userNickName, photoURLString: profileImage)
        AuthService.shared.registerUser(user: self.user, credentials: credentials){ (error, ref) in
//            print("사용자가 성공적으로 가입되었습니다.")
//            print("사용자의 인터페이스를 업데이트 할 부분입니다.")
            
//            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
//                return }
//
//            guard let tab = window.rootViewController as? MainTabController else {return}
            
            // 사용자 정보 업데이트 완료
            UserService.shared.fetchUser(uid: self.user.uid) { (user) in
                guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                      let tab = window.rootViewController as? MainTabController else { return }
                print("RegistrationController 에서 이미지 등록후 \(user.photoURLString)")
                tab.user = user
                //tab.fetchUser()
                
                
                //tab.authenticateUserAndConfigureUI()
                
                self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인 컨트롤러를 닫고
            }
            
           
            /*
             이 코드는 사용자 인증(authentication)을 하고, UI(user interface)를 설정합니다. 먼저, guard let 키워드를 사용해서 현재 앱에서 가장 위에 올려져있는 화면, 즉 키 윈도우(key window)를 찾습니다. 그 다음에는, 이 화면에서 rootViewController로 설정된 컨트롤러(MainTabController)가 있는지 확인합니다. 만약 없다면, 해당 메서드는 실행되지 않고 종료됩니다. 하지만 MainTabController가 발견된다면, 해당 컨트롤러의 메서드인 authenticateUserAndConfigureUI()를 실행합니다. 이 메서드는 사용자 인증 과정을 거치고, UI를 설정합니다. 마지막으로, dismiss 메서드를 호출하여 현재 present되어 있는 로그인 컨트롤러를 닫습니다. 이러한 과정을 통해 사용자는 로그인 컨트롤러를 명확하게 닫고, MainTabController로 이동할 수 있습니다.
             */
            
            
            
        }
        
    }

    func showProfileRegistrationAlert() {
        let alertController = UIAlertController(title: "프로필 등록 필요", message: "앱을 사용하기 위해서는 프로필 등록이 필요합니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            // 프로필 등록 화면으로 이동
            // 필요한 작업 수행
        }
        alertController.addAction(okAction)
        // 필요한 경우 추가적인 액션 및 메시지 설정
        // alertController.addAction(...)
        
        // 현재 화면에 알림창 표시
        // self.present(alertController, animated: true, completion: nil)
    }

    

    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .mainColor
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(PlusPhotoButton)
        PlusPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        PlusPhotoButton.setDimensions(width: 128, height: 128)
        
        //registrationButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [userNicknameContainerView, userIDContainerView,registrationButton])
        stack.axis = .vertical // 세로축 정렬
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: PlusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32,
        paddingLeft: 32, paddingRight: 32)
        
    
    }
    
}


// MARK: - UIImagePickerControllerDelegate
@available(iOS 16.0, *)
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 이 기능을 사용하면 선택한 미디어 항목이 사진이든 동영상이든 액세스할 수 있습니다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이 정보는 당신이 어떤 유형을 선택했는지 알아야 하기 때문에 사전입니다.
        // 원본이든 편집된 이미지든 영화든 영상이든 뭐든 그래서 우리는 이편집 이미지 키를 사용하여 해당 사전에서 값을 가져옵니다.
        guard let profileImage = info[.editedImage] as? UIImage else {return}
        self.profileImage = profileImage
        
        // 둥글게 설정
        PlusPhotoButton.layer.cornerRadius = 128 / 2
        PlusPhotoButton.layer.masksToBounds = true
        
        // 가로 세로 비율 맞추기 : 이미지가 포함된 프레임에 맞게 이미지의 크기를 조정합니다.
        PlusPhotoButton.imageView?.contentMode = .scaleAspectFill
        PlusPhotoButton.imageView?.clipsToBounds = true // 프레임 범위를 벗어나지 않도록 설정
        
        // 테두리 추가
        PlusPhotoButton.layer.borderColor = UIColor.white.cgColor // 보더 색상 설정시 .cgColor를 붙여줘야함
        PlusPhotoButton.layer.borderWidth = 3
        
        // 선택한 원본 이미지를 이미지 버튼에 삽입
        self.PlusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil) // 해당 코드가 있어야 이미지 선택후 빠져나올수 있음
    
    }
}
