//
//  UserService.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/17.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

typealias DatabaseCompletion = ((Error? , DatabaseReference) -> Void)

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        //print("DEBUG: 현재 사용자 정보를 가져온다.")
        // guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //💁 전달받는 uid에 따른 사용자를 가져오게 수정함
        // 데이터베이스에서 이 정보를 한번만 가져오려고 함, 단일 이벤트를 관찰
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot,err  in
            
            //print("DEBUG: Snapshot \(snapshot)")
            guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
            //print("DEBUG: Dictionary is \(dictionary)")
            
            // 두개는 미우 비슷하지만 우리가 이것을 어떨게 사용하게 될지에 따라 큰 차이를 만듬
            // 스냅샷은 해당 스냅샷에 대한 키도 나옴 Snapshot Snap (NO6TkcQJs3MFpMOXLNnIRJ5Br8S2)
            // 해당 스냅샷의 값들을 딕셔너리 타입으로 케스팅하여 편하게 사용할 것임
            guard let username = dictionary["username"] as? String else {return}
            //print("DEBUG: 현제 사용자의 이름 \(username)")
            
            let user = User(uid: uid, dictionary: dictionary)
            //print("DEBUG: 현제 사용자의 name \(user.username)")
            //print("DEBUG: 현제 사용자의 fullname \(user.fullname)")
            completion(user)
        }
    }
    
    
    // 사용자 검색을 위해 사용할 부분
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            print(user.username)
            users.append(user)
            completion(users)
        }
    }
}
