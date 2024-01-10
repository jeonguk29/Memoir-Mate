
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
                    let alertController = UIAlertController(title: "사진 권한 필요", message: "앱에서 사진을 사용하려면 사진에 대한 권한을 허용해야 합니다. 설정 -> 개인정보 보호 및 보안 -> 사진에서 권한을 허용해주세요.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    // 현재 화면에 알림창 표시
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                case .restricted, .notDetermined:
                    print("Album: 선택하지 않음")
                    // 선택하지 않음 시 사용자에게 프로필 등록 필요 메시지 표시
                    break
                @unknown default:
                    break
                }
            }
    }
    
    @objc func handleRegistration() {
        guard let profileImage = profileImage else {
            let randomImageIndex = Int.random(in: 1...6)
            let imageName = "defultImage\(randomImageIndex)"
            
            if let image = UIImage(named: imageName) {
                profileImage = image
            }
            
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

        UserService.shared.userIdDuplicateCheck(checkUserID: userID) { bool in
            if bool == true {
                DispatchQueue.main.async {
                    self.showAlert(message: "중복된 사용자 ID입니다. 다시 만들어 주세요.")
                    return
                }
            } else { // 중복되지 않은 ID인 경우
                let credentials = AuthCredentials(userID: userID, userNickName: userNickName, photoURLString: profileImage)
                AuthService.shared.registerUser(user: self.user, credentials: credentials){ (error, ref) in
                    
                    UserService.shared.fetchUser(uid: self.user.uid) { (user) in
                        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                              let tab = window.rootViewController as? MainTabController else { return }
                        print("RegistrationController 에서 이미지 등록후 \(user.photoURLString)")
                        tab.user = user
                        
                        self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인 컨트롤러를 닫고
                    }
                }
            }
        }



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
