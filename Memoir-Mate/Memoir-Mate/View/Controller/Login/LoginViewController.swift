//
//  LoginViewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//

import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import UIKit
import AuthenticationServices // apple login 관련 라이브러리
import CryptoKit // 해시 값 추가

@available(iOS 16.0, *)
class LoginViewController: UIViewController {
    
    
    
    let backgroundImage = UIImage(named: "Login3") // 'your_image_name' 대신 실제 이미지 파일 이름 입력
    
    // UIImageView 인스턴스 생성 및 설정
    lazy var backgroundImageView: UIImageView = {
        let ImageView = UIImageView()
        ImageView.image = self.backgroundImage
        ImageView.contentMode = .scaleAspectFill  // 콘텐츠 모드에 따라 변경 가능
        ImageView.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return ImageView
    }()
    
    private let googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.colorScheme = .light
        button.style = .wide
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    
    
    
    //애플 로그인
    
    private let appleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Apple", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(tapAppleLoginButton), for: .touchUpInside)
        return button
    }()
    
    var currentNonce: String? = ""
    
    @objc func tapAppleLoginButton(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    
    @objc func handleGoogleLogin(){
        print("로그인 버튼 클릭")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
              return
          }
            

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                if let loginUser = Auth.auth().currentUser {
                    UserService.shared.LoginfetchUser(uid: loginUser.uid) { fetchedUser in
                        let uid = loginUser.uid
                        let email: String
                        let userName: String
                        let userNickName: String
                        let photoURLString: String?
                        let userSetting: Bool
                        let bio: String
                        let backgroundCustomImage1: String
                        let backgroundCustomImage2: String

                        if let user = fetchedUser {
                            // 사용자 정보가 이미 있는 경우
                            email = user.email ?? loginUser.email!
                            userName = user.username ?? loginUser.displayName!
                            userNickName = user.userNickName ?? ""
                            photoURLString = user.photoURLString?.absoluteString ?? loginUser.photoURL!.absoluteString
                            userSetting = user.userSetting ?? false
                            bio = user.bio ?? "Memoir Mate User"
                            backgroundCustomImage1 = user.backgroundCustomImage1?.absoluteString ?? ""
                            backgroundCustomImage2 = user.backgroundCustomImage2?.absoluteString ?? ""
                        } else {
                            // 처음 로그인하는 사용자의 경우
                            email = loginUser.email!
                            userName = loginUser.displayName!
                            userNickName = ""
                            photoURLString = loginUser.photoURL!.absoluteString
                            userSetting = false
                            bio = "Memoir Mate User"
                            backgroundCustomImage1 = ""
                            backgroundCustomImage2 = ""
                        }

                        let values: [String: Any] = ["email" : email,
                                      "username" : userName,
                                      "userNickName" : userNickName,
                                      "photoURLString" : photoURLString as Any,
                                      "userSetting" : userSetting,
                                      "bio" : bio,
                                      "backgroundCustomImage1" : backgroundCustomImage1,
                                      "backgroundCustomImage2" : backgroundCustomImage2
                        ]

                        // 로그인된 사용자 정보를 업데이트
                        REF_USERS.child(uid).updateChildValues(values)

                        // 다시 메인화면 보여주기
                        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
                            return }
                        
                        guard let tab = window.rootViewController as? MainTabController else {return}
                        
                        tab.authenticateUserAndConfigureUI()
                        
                        self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인
                    }
                }
            }


        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // UIImageView 인스턴스를 뷰의 서브뷰로 추가
        view.addSubview(backgroundImageView)
        
        // 오토레이아웃 제약조건 설정 (백그라운드 이미지가 화면 전체를 채우도록)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false  // 오토레이아웃 사용을 위해 필요함
        
        backgroundImageView.addSubview(googleButton) // 필요한 경우 버튼을 뷰에 추가
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        backgroundImageView.addSubview(appleButton) // 필요한 경우 버튼을 뷰에 추가
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        //emailInfoLabel.leadingAnchor.constraint(equalTo: emailTextFieldView.leadingAnchor, constant: 8).isActive = true
             // 이런식으로 .isActive = true 끝에 다 활성화 붙일 필요 없음
        NSLayoutConstraint.activate([

                // Set height of the button
                googleButton.heightAnchor.constraint(equalToConstant: 60),
                
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                           backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                           backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                           backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                // Set button's centerXAnchor to be equal to view's centerXAnchor
                googleButton.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),

                // Set button's centerYAnchor to be equal to view's centerYAnchor
                googleButton.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),

                // Set leading and trailing constraints for the button with 30 points padding from screen edges.
                googleButton.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 40),
                googleButton.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: -40),
                
                appleButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 20),
                appleButton.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 40),
                appleButton.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: -40),
                
             ])
    }
    
    
    
    
}





@available(iOS 16.0, *)
extension LoginViewController {
    func startSignInWithAppleFlow() {
           let nonce = randomNonceString()
           currentNonce = nonce
           let appleIDProvider = ASAuthorizationAppleIDProvider()
           let request = appleIDProvider.createRequest()
           // request 요청을 했을 때 none가 포함되어서 릴레이 공격을 방지
           // 추후 파베에서도 무결성 확인을 할 수 있게끔 함
           request.requestedScopes = [.fullName, .email]
           request.nonce = sha256(nonce)
           
           let authorizationController = ASAuthorizationController(authorizationRequests: [request])
           authorizationController.delegate = self
           authorizationController.presentationContextProvider = self
           authorizationController.performRequests()
       }
       
       private func sha256(_ input: String) -> String {
           let inputData = Data(input.utf8)
           let hashedData = SHA256.hash(data: inputData)
           let hashString = hashedData.compactMap {
               return String(format: "%02x", $0)
           }.joined()
           
           return hashString
       }
       
       // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
       private func randomNonceString(length: Int = 32) -> String {
           precondition(length > 0)
           let charset: Array<Character> =
               Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
           var result = ""
           var remainingLength = length
           
           while remainingLength > 0 {
               let randoms: [UInt8] = (0 ..< 16).map { _ in
                   var random: UInt8 = 0
                   let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                   if errorCode != errSecSuccess {
                       fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                   }
                   return random
               }
               
               randoms.forEach { random in
                   if remainingLength == 0 {
                       return
                   }
                   
                   if random < charset.count {
                       result.append(charset[Int(random)])
                       remainingLength -= 1
                   }
               }
           }
           
           return result
       }
}

@available(iOS 16.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // controller로 인증 정보 값을 받게 되면은, idToken 값을 받음
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // nonce : 암호화된 임의의 난수, 단 한번만 사용 가능
            // 동일한 요청을 짧은 시간에 여러번 보내는 릴레이 공격 방지
            // 정보 탈취 없이 안전하게 인증 정보 전달을 위한 안전장치
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                // 안전하게 인증 정보를 전달하기 위해 nonce 사용
            
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // token들로 credential을 구성해서 auth signin 구성 (google과 동일)
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                ///Main 화면으로 보내기
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController")
                mainViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.show(mainViewController, sender: nil)
            }
        }
    }
}

@available(iOS 16.0, *)
extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
