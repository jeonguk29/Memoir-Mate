//
//  User.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/18.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct User {
//    let values = ["email" : email,
//                  "username" : userName,
//                  "userNickName" :  userNickName,
//                  "profileImageUrl" : photoURLString,
//                  "userSetting" : userSetting,
//                  "backgroundCustomImage1" : backgroundCustomImage1,
//                  "backgroundCustomImage2" : backgroundCustomImage2
                  
    let email: String
    var username: String
    var userNickName: String
    var userID: String
    var photoURLString: URL?
    let uid: String
    let userSetting : Bool
    var stats: UserRelationStats? // API 호출되면 이 속성을 설정할 것임
    
    var isFollowed = false // 유저가 팔로우 했는지 안했는지 동작을 처리하기 위한 속성
    
    // 사용자가 현재 사용자인지 여부를 파악하기 위한 변수
    var isCurrentUser: Bool {return Auth.auth().currentUser?.uid == uid}
    
    var bio: String? //  사용자가 자기를 표현하는 말을 저장하기 위한 변수
    var backgroundCustomImage1 :URL?
    var backgroundCustomImage2 :URL?
    
    init(uid: String, dictionary: [String: AnyObject]){
        print("젠장할\(dictionary)")
        
     
        self.uid = uid
    
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        self.userNickName = dictionary["userNickname"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? ""
        self.userSetting = dictionary["userSetting"] as? Bool ?? false
        
        // 없으면 빈 문자열이 기본임
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        // 이게 마지막에 있어야함
        /*
         if let backgroundCustomImage1 = dictionary["backgroundCustomImage1"] as? String {
                guard let url = URL(string: backgroundCustomImage1) else {else {return}}
                self.backgroundCustomImage1 = url
            }
         기존에 이렇게 해서 변한 안되면 else {return} 실행되서 종료 되었음 그래서 나머지 아래 소스코드가 실행되지 않아서 프로필 이미지가 표시되지 않았음
         */
        if let backgroundCustomImage1 = dictionary["backgroundCustomImage1"] as? String {
            if let url = URL(string: backgroundCustomImage1) {
                self.backgroundCustomImage1 = url
            } else {
                print("backgroundCustomImage1 URL 변환 실패: \(backgroundCustomImage1)")
            }
        }
                
        if let backgroundCustomImage2 = dictionary["backgroundCustomImage2"] as? String {
            if let url = URL(string: backgroundCustomImage2) {
                self.backgroundCustomImage2 = url
            } else {
                print("backgroundCustomImage2 URL 변환 실패: \(backgroundCustomImage2)")
            }
        }
        
        if let profileImageUrlString = dictionary["photoURLString"] as? String {
            print("이미지 파베 저장후 모델 만들때 사진 값 URL 값 재대로 변환 되는가? 1 \(profileImageUrlString)")
            if let url = URL(string: profileImageUrlString) {
                print("이미지 파베 저장후 모델 만들때 사진 값 URL 값 재대로 변환 되는가? 2 \(url)")
                self.photoURLString = url
            } else {
                print("URL 변환 실패: \(profileImageUrlString)")
            }
        }
        
   
        
//        let url = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/memoir-mate-8cf5e.appspot.com/o/profile_images%2F6595BBE5-86BE-495C-9ADD-22C31AA4EB5E?alt=media&token=68266ce2-c201-42c2-a695-dee4cd4d185f") else {return}
       
        
    }
}


struct UserRelationStats {
    var followers: Int
    var following: Int
}
