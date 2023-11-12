//
//  AuthService.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/10/23.
//


import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
struct AuthCredentials {
    //let email : String
    let userID : String
    let userNickName : String
    let photoURLString : UIImage
    // let userSetting : Bool
    //    let backgroundCustomImage1 : UIImage
    //    let backgroundCustomImage2 : UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    //    func logUserIn(withEmail email: String, password: String, handler: @escaping (AuthDataResult?, Error?) -> Void){
    //        //print("DEBUG: Email is \(email), password is \(password)")
    //        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    //    }
    
    
    func registerUser(user: User, credentials : AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void){
        var cuuUser: User = user
        let userID = credentials.userID
        let userNickName = credentials.userNickName
        guard let imageData = credentials.photoURLString.jpegData(compressionQuality: 0.3) else {return}
        
        let filename = NSUUID().uuidString // filename은 유일한 값을 생성하여 이미지를 저장할 때 파일 이름을 만드는 데 사용됩니다.
        let storageRef = STORAGE_PROFILE_IMAGE.child(filename)
        
        storageRef.putData(imageData) { (mata, error) in
            // 다운로드 URL를 받아야함
            storageRef.downloadURL { (result: Result<URL, Error>) in
                var profileImageUrl = ""
                switch result {
                case .success(let url):
                    profileImageUrl = url.absoluteString
                    // profileImageUrl 사용하기
                case .failure(let error): break
                    // 오류 처리
                }
                
                let userSetting = true
                
                // 파이어베이스의 사용자를 생성;
                let uid = cuuUser.uid
                let name = cuuUser.username
                let email = cuuUser.email
                
                var userID = userID
                
                let values = [
                              "username": name,
                              "email": email,
                              "userNickname": userNickName,
                              "userID": userID,
                              "photoURLString": profileImageUrl,
                              "userSetting" : userSetting,
                              "backgroundCustomImage1": "",
                              "backgroundCustomImage2": "" ]
                as [String : AnyObject]
                
                REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
            
            }
        }

        
        
    }
}

