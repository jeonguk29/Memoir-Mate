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
    let email: String
    var username: String
    var profileImageUrl: URL?
    let uid: String
    var stats: UserRelationStats? // API 호출되면 이 속성을 설정할 것임
    
    var isFollowed = false // 유저가 팔로우 했는지 안했는지 동작을 처리하기 위한 속성
    
    // 사용자가 현재 사용자인지 여부를 파악하기 위한 변수
    var isCurrentUser: Bool {return Auth.auth().currentUser?.uid == uid}
    
    var bio: String? //  사용자가 자기를 표현하는 말을 저장하기 위한 변수
    
    
    init(uid: String, dictionary: [String: AnyObject]){
        self.uid = uid
    
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        // 없으면 빈 문자열이 기본임
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else {return}
            self.profileImageUrl = url
        }
        
    }
}


struct UserRelationStats {
    var followers: Int
    var following: Int
}
