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
                
                // At this point, our user is signed in
                if let user = Auth.auth().currentUser {
                    
                    // 여기서부터 로그인된 사용자의 프로필 정보에 접근 가능.
            
                    let uid = user.uid ?? ""
                    let email = user.email ?? ""
                    let userName = user.displayName ?? ""
                    let photoURLString = user.photoURL?.absoluteString ?? ""
                   
                    print("User ID : \(uid)")
                    print("User Email : \(email)")
                    print("User Name : \(userName)")
                    print("User photoURL : \(photoURLString)")
                   
                    
                    let values = ["email" : email,
                                  "username" : userName,
                                  "profileImageUrl" : photoURLString]
                    
                    REF_USERS.child(uid).updateChildValues(values)
                    
                  
//
//                    let values = ["profileImageUrl" : result?.user.p]
//
//                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    
                    // 다시 메인화면 보여주기
//                               guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
//                                   return }
//
//                               guard let tab = window.rootViewController as? MainTabController else {return}
//
//                               tab.authenticateUserAndConfigureUI()
//
//                               self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인 컨트롤러를 닫고
                }
                
                // 다시 메인화면 보여주기
                guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
                    return }
                
                guard let tab = window.rootViewController as? MainTabController else {return}
                
                tab.authenticateUserAndConfigureUI()
                
                self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인
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

             ])
    }
    
    
    
    
}

