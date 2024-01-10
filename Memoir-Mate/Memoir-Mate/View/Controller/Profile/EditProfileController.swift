//
//  EditProfileController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/12/23.
//


import UIKit
import FirebaseAuth
import Photos

private let reuseIdentifier = "EditProfileCell"
@available(iOS 16.0, *)
protocol EditProfileControllerDelegate: class {
    
    // 데이터 수정후 데이터 베이스 변경은 되지만 피드와 현제 수정후 변환된 값으로 리로드를 하기위한 프로토콜
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
    func handleLogout() // 로그아웃 버튼 클릭시 로그인 화면으로 돌아가기위한 메서드
}

@available(iOS 16.0, *)
class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private lazy var footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    var validationErrorMessages: [String] = []

    
    private var userInfoChanged = false
    
    private var imageChanged: Bool {
        return selectedImage != nil // 기본적으로 선택한 이미지에 값이 있으면 이미지가 변경되었음을 의미
    }
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        // 해당 컨트롤러는 사용자 정보로 채워져야함 초기화할때 사용자 정보 받는 부분이 필수
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImagePicker()
        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        //        dismiss(animated: true, completion: nil)
        
        view.endEditing(true) // 완료를 누르면 보기 끝 편집이 사실이라고 말하고 싶습니다.
        // 둘중 하나의 데이터도 업데이트 되지 않으면 동작되지 않음
        guard imageChanged || userInfoChanged else { return }
        updateUserData()
    }
    
    
    // MARK: - API
    
    func updateUserData() {
        
        // 이런식으로 구분하여 API 호출 하는게 훨씬 효율적이고 불필요하게 저장되는 과부화를 막을 수 있음
        
        if imageChanged && !userInfoChanged {
            // 이미지가 업데이트 되었지만 사용자 정보는 업데이트 되지 않았을때
            print("이미지가 업데이트 되었지만 사용자 정보는 업데이트 되지 않았음")
            updateProfileImage()
        }
        
        if userInfoChanged && !imageChanged {
            // 사용자 정보는 업데이트 되었지만 이미지는 그대로일때
            print("사용자 정보는 업데이트 되었지만 이미지는 그대로")
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInfoChanged && imageChanged {
            // 둘다 업데이트 되었을때
            print("사용자 정보, 이미지 둘다 업데이트 ")
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.updateProfileImage()
            }
        }
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageURL in
            
            // 업데이트한 이미지 URL을 반환 받음 다시 화면에 적용하기
            self.user.photoURLString = profileImageURL
            self.delegate?.controller(self, wantsToUpdate: self.user)
            // 업데이트후 리로드를 위해 위임
        }
    }
        
  

        
        // MARK: - Helpers
        func configureNavigationBar() {
            
            navigationController?.navigationBar.barTintColor = .mainColor
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = .white
            
            
            // 네비게이션 바 타이틀 색상 설정
            navigationItem.title = "프로필 편집"
            
            
            // 네비게이션 바 아이템 설정
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                               target: self,
                                                               action: #selector(handleCancel))
            
            let customButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                               target: self,
                                               action: #selector(handleDone))
            let customButton2 =  UIBarButtonItem(customView: privacySettingsButton)
        
            
//            // 네비게이션 바 아이템 사이에 임의로 간격 설정하기
//            let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//            space.width = 32 // 원하는 간격을 설정하세요

            navigationItem.rightBarButtonItems = [customButton, customButton2]

            
            
        }
        
        func configureTableView() {
            // 헤더등록 밑 델리게이트 설정
            tableView.tableHeaderView = headerView
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
            headerView.delegate = self
            
            // 풋터 설정
            tableView.tableFooterView = footerView
            footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
            footerView.delegate = self
            
            // 셀등록
            tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        }
        
        func configureImagePicker() {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
        }
}

// MARK: - UITableViewDataSource
@available(iOS 16.0, *)
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count // 3개의 case가 있음
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        
        cell.delegate = self
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell}
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
@available(iOS 16.0, *)
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        // 셀의 높이를 조절 bio 셀만 좀더 높이를 크게 100 아니면 다른 셀은 48로
        return option == .bio ? 100 : 48
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
@available(iOS 16.0, *)
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 사용자 프로필 이미지를 바꾸는 부분
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image //DidSet의 의하여 헤더에 바로 적용 되는 걸 확인 할 수 있음
        
        // 실제 사용자 정보를 업데이트 해주는 부분을 만들기만 하면 됨
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - EditProfileHeaderDelegate

@available(iOS 16.0, *)
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
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
                // 권한 거부 시 사용자에게 사진 권한을 허용해야 함을 알림
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
                // 선택하지 않음 시 사용자에게 사진 권한을 허용해야 함을 알림
                let alertController = UIAlertController(title: "사진 권한 필요", message: "앱에서 사진을 사용하려면 사진에 대한 권한을 허용해야 합니다. 설정 -> 개인정보 보호 및 보안 -> 사진에서 권한을 허용해주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                // 현재 화면에 알림창 표시
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                break

            @unknown default:
                break

                
            }
            
        }
    }
}

// MARK: - EditProfileCellDelegate
@available(iOS 16.0, *)
extension EditProfileController: EditProfileCellDelegate {
  
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        userInfoChanged = true
    
        // 일단 처음에 사용자 버튼이 눌리지 못하게
        self.disableDoneButton()
        
        // 유효성 검증 시작
        switch viewModel.option {
            
        case .userNickName:
            guard let userNickName = cell.infoTextField.text else {
                validationErrorMessages.append("UserNickName은 3~14자 사이여야 합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            // Validate userNickName length
            guard userNickName.count >= 3 && userNickName.count <= 14 else {
                validationErrorMessages.append("UserNickName은 3~14자 사이여야 합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            user.userNickName = userNickName
            
        case .userID:
            guard let username = cell.infoTextField.text else {
                validationErrorMessages.append("사용자 ID는 3~14자 사이여야 합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                return
            }

            // Validate username length and that it contains only English letters, numbers, and special characters
            let usernameRegex = "^[a-zA-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]{3,14}$"
            guard username.count >= 3 && username.count <= 14, NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username) else {
                validationErrorMessages.append("사용자 ID는 3~14자 사이의 영어 문자, 숫자, 특수문자 조합만 가능합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            // Check for duplicate userID
            guard let username = cell.infoTextField.text else {
                validationErrorMessages.append("사용자 ID를 입력하세요.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            
            UserService.shared.userIdDuplicateCheck(checkUserID: username) { isDuplicate in
                print("isDuplicate \(isDuplicate)")
                
                // 중복 체크가 완료된 후 실행되어야 하는 코드
                if isDuplicate {
                    // 중복된 사용자 ID 경고창 보여주기
                    DispatchQueue.main.async {
                        // 사용자에게 알림을 보여줄 메서드 또는 함수를 호출하도록 수정
                        self.validationErrorMessages.append("중복된 사용자 ID입니다. 다시 만들어 주세요.")
                        self.showAlert(message: self.validationErrorMessages.joined(separator: "\n"))
                        self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                        self.disableDoneButton()
                        return
                    }
                } else {
                    // duplicateCheck 값이 false인 경우에만 아래 코드가 실행됨
                    self.user.userID = username
                }
            }
            
        case .bio:
            guard let bioText = cell.bioTextView.text else {
                validationErrorMessages.append("자기소개는 최대 40자까지 가능합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            // Validate bioText length
            guard bioText.count <= 40 else {
                validationErrorMessages.append("자기소개는 최대 40자까지 가능합니다.")
                showAlert(message: validationErrorMessages.joined(separator: "\n"))
                self.validationErrorMessages = []  // 경고창이 닫힐 때 초기화
                self.disableDoneButton()
                break
            }
            user.bio = bioText
        }
        
        // 유효성 검증 끝 (무사 통과)
        self.enableDoneButton() // 업데이트 가능한 버튼 누를수 있게
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "검증 오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            // 확인 버튼이 눌렸을 때 실행되는 핸들러
            print("최종확인 \(self.validationErrorMessages)")
            if self.validationErrorMessages.isEmpty {
                self.disableDoneButton()
            } else {
                self.enableDoneButton()
            }
        })
        present(alertController, animated: true, completion: nil)
    }

    
    private func enableDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func disableDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}



// MARK: - EditProfileFooterDelegate
@available(iOS 16.0, *)
extension EditProfileController: EditProfileFooterDelegate {
    func handleLogout() {
        
        // 로그아웃을 위한 Alert창 보여주기
        let alert = UIAlertController(title: nil,
                                      message: "정말 로그아웃하시겠습니까?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.dismiss(animated: true) { // 현제 보여지는 화면을 사라지게 하고
                self.delegate?.handleLogout()// 로그아웃 로직을 처리
            }
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - PrivacySetting
@available(iOS 16.0, *)
extension EditProfileController {
    enum PrivacySettingList: String, CaseIterable {
        case deleteAccount = "계정 탈퇴"
        // 추가적인 이유를 필요에 따라 열거형에 추가할 수 있습니다.
    }
    
    var privacySettingsButton: UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray5
        button.setImage(UIImage(systemName: "gear.badge.questionmark"), for: .normal)
        button.addTarget(self, action: #selector(privacySettingsTapped), for: .touchUpInside)
        return button
    }

    
    @objc func privacySettingsTapped() {

     
        let alertController = UIAlertController(title: "개인 정보 설정", message: nil, preferredStyle: .actionSheet)

        // Enum의 모든 케이스를 액션으로 추가
        for reason in PrivacySettingList.allCases {
            let action = UIAlertAction(title: reason.rawValue, style: .default) { [weak self] _ in
                // Handle the selected option
                self?.handlePrivacySetting(reason)
            }
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    func handlePrivacySetting(_ setting: PrivacySettingList) {
        switch setting {
        case .deleteAccount:
            showDeleteAccountConfirmation()
        // Handle additional cases if needed
        }
    }

    func showDeleteAccountConfirmation() {
        let deleteAlertController = UIAlertController(title: "계정 탈퇴", message: "정말로 계정을 탈퇴하시겠습니까? \n모든 데이터가 삭제 되어 복구 하실 수 없습니다.", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            // Handle the deletion logic here
            self?.deleteAccount()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        deleteAlertController.addAction(confirmAction)
        deleteAlertController.addAction(cancelAction)

        present(deleteAlertController, animated: true, completion: nil)
    }
    
   

    func deleteAccount() {
        if let user = Auth.auth().currentUser {
            UserService.shared.deleteAllUserData(user: self.user)
            // 로그인 상태 확인
            if user.isEmailVerified {
                user.delete { [self] error in
                    if let error = error {
                        print("Firebase Error: ", error)
                        
                            let deleteAlertController = UIAlertController(title: "계정 탈퇴", message: "계정을 삭제 하기 위해서 로그아웃 이후 재 로그인이 필요 합니다.", preferredStyle: .alert)

                            let confirmAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
                                // Handle the deletion logic here
//                                let loginViewController = LoginViewController()
//
//                                // 로그인 화면을 full screen으로 present
//                                loginViewController.modalPresentationStyle = .fullScreen
//                                self?.present(loginViewController, animated: true, completion: nil)

                            }

                            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

                            deleteAlertController.addAction(confirmAction)
                            deleteAlertController.addAction(cancelAction)

                            present(deleteAlertController, animated: true, completion: nil)
                    
    
                    } else {
                        print("계정 탈퇴 성공 ")
                        let loginViewController = LoginViewController()
                        
                        // 로그인 화면을 full screen으로 present
                        loginViewController.modalPresentationStyle = .fullScreen
                        self.present(loginViewController, animated: true, completion: nil)
                    
                    }
                }
            }
        } else {
            print("로그인 정보가 존재하지 않습니다.")
        }
        print("Account deletion requested.")
    }

}
