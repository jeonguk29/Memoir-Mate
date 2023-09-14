//
//  LoginViewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//

import GoogleSignIn
import Firebase
import FirebaseCore
import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    
    
    private let googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.colorScheme = .light
        button.style = .standard
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    @objc func handleGoogleLogin(){
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
                    // 사용자 이름 가져오기
                    let userName = user.displayName
                    print("사용자 이름: \(userName ?? "사용자 이름 없음")")
                    
                }
                
            }
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(googleButton) // 필요한 경우 버튼을 뷰에 추가
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        
        //emailInfoLabel.leadingAnchor.constraint(equalTo: emailTextFieldView.leadingAnchor, constant: 8).isActive = true
             // 이런식으로 .isActive = true 끝에 다 활성화 붙일 필요 없음
        NSLayoutConstraint.activate([
                // Set button's centerXAnchor to be equal to view's centerXAnchor
                googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                // Set button's centerYAnchor to be equal to view's centerYAnchor
                googleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                // Set leading and trailing constraints for the button with 30 points padding from screen edges.
                googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

                // Set height of the button
                googleButton.heightAnchor.constraint(equalToConstant: 60)
             ])
    }
    
    
    
    
}

