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
            //print("UserService에서 실행 이때는 값이 정상적입 DEBUG: Dictionary is \(dictionary)")
            
            // 두개는 미우 비슷하지만 우리가 이것을 어떨게 사용하게 될지에 따라 큰 차이를 만듬
            // 스냅샷은 해당 스냅샷에 대한 키도 나옴 Snapshot Snap (NO6TkcQJs3MFpMOXLNnIRJ5Br8S2)
            // 해당 스냅샷의 값들을 딕셔너리 타입으로 케스팅하여 편하게 사용할 것임
            //guard let username = dictionary["username"] as? String else {return}
            //print("DEBUG: 현제 사용자의 이름 \(username)")
            
            let user = User(uid: uid, dictionary: dictionary)
            //print("DEBUG: 현제 사용자의 name \(user.username)")
            //print("DEBUG: 현제 사용자의 fullname \(user.fullname)")
            completion(user)
        }
    }
    
    func LoginfetchUser(uid: String, completion: @escaping(User?) -> Void) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(uid: uid, dictionary: dictionary)
                completion(user)
            } else {
                completion(nil)
            }
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
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)){
        // 사용자 A가 B를 팔로우 하면 B사용자 밑에 A, C ... 등등을 연결하고
        // 사용자 A가 누구를 팔로우 하는지 A밑에 B를 추가 해서 각각 관리하는 구조임
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
        
        
        //print("DEBUG: Current uid \(currentUid) started following \(uid)")
        //print("DEBUG: Uid \(uid) gained \(currentUid) as a follower")
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue() { (err, ref) in
            // 팔로잉을 먼저 제거하고 팔로우를 제거하기
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
        
    }
    
    func blockUser(blockUserUid: String, completion: @escaping(DatabaseCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        // 한명이 차단하면 서로의 일기가 안보이게 구현
        // 일기 목록 확인시 해당일기가 차단 사용자면 배열에서 제거 
        REF_BLOCK_USER.child(currentUid).updateChildValues([blockUserUid: 1]) { (err, ref) in
            REF_BLOCK_USER.child(blockUserUid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
        
    }
    
    func blockUserFetch(completion: @escaping ([String]?, Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        print("블락 유져 테스트 시작")
        
        REF_BLOCK_USER.child(currentUid).observe(.value) { snapshot, error in
            if let error = error {
                print("블락 유져 에러")
                completion(nil, error as? Error)
            } else if let blockDictionary = snapshot.value as? [String: Any] {
                let blockList = Array(blockDictionary.keys)
                print("블락 유져 목록")
                print(blockList)
                completion(blockList, nil)
            } else {
                // 차단 사용자가 없는 경우
                print("차단 사용자 없음")
                completion([], nil)
            }
        }

    }



    
    // 사용자 객체는 isFollowed = false로 항상 초기화 되기 때문에 팔로우를 눌러도 다시 나갔다 들어오면 재설정 됨
    // 사용자가 실제로 누군가를 팔로우하는지 여부에 따라 해당 속성을 설정하는 방법이 필요합니다.
    // 이게 그 방법으로 속석을 설정하는 방법임
    func checkIfUserIsFollowd(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            print("DEBUG: User is followed is \(snapshot.exists())") // 팔로잉 하고있는지 여부
            completion(snapshot.exists())
        }
    }
    /*
     위의 함수는 Firebase Realtime Database에서 현재 사용자가 선택한 사용자의 프로필을 팔로우했는지 확인하는 함수입니다. 함수는 먼저 Auth.auth().currentUser?.uid를 사용하여 현재 로그인 된 사용자의 uid를 가져옵니다. 가져오지 못하면 함수를 종료하고, 현재 사용자의 uid가 있는 경우 REF_USER_FOLLOWING.child(currentUid).child(uid) 경로에 대한 'single event'를 관찰합니다. 'degree event'를 관찰하면 콜백 함수 completion으로 전달된 Bool 값에 따라 팔로우 여부가 반환됩니다. 만약 snapshot이 존재한다면 (즉, 사용자가 팔로우 중이면) ture, 아니면 false입니다.
     */
    
    // 사용자 팔로우, 팔로잉 실제 값으로 출력하게
    func fetchUserStats(uid:String, completion: @escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot  in
            let followers = snapshot.children.allObjects.count
            
            print("DEBUG: Followers count is \(followers)")
            
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot   in
                let following = snapshot.children.allObjects.count
                print("DEBUG: Following \(following) people")
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
                
            }
        }
    }
    
    
    // 사용자 프로필 이미지를 업데이트 하기위한 메서드
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //이미지를 Jpeg 데이터로 변환한 다음 해당 이미지 데이터를 업로드하는 방법
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let ref = STORAGE_PROFILE_IMAGE.child(filename)
        
        ref.putData(imageData, metadata: nil) { (meta, err) in
            ref.downloadURL { (url, error) in
                guard let profileImageURL = url?.absoluteString else { return }
                
                let values = ["photoURLString": profileImageURL]
                //이미지 업로드 후 받아온 url을 다시 사용자 프로필 url로 업데이트
                REF_USERS.child(uid).updateChildValues(values) { (err, ref) in
                    completion(url)// 업데이트한 이미지를 다시 사용자의 화면에 보여주기위해 url을 전달
                }
            }
        }
    }
    
    // 프로필 편집에서 사용자 데이터 저장 하는 메서드
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["userNickName": user.userNickName,
                      "userID": user.userID,
                      "bio": user.bio ?? ""]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    // 프로필 편집에서 사용자 탈퇴시 모든 정보를 삭제
    func deleteAllUserData(user: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("uid \(uid)")
        
        // 유저가 쓴 전체 일기 uid 가져오기
        REF_USER_DIARYS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("Error: Unable to retrieve data.")
                return
            }

            // value는 [String: Any] 형태로 해당 경로의 데이터를 나타냅니다.
            // 이제 반복문을 사용하여 각 하위 항목을 가져올 수 있습니다.

            for (diaryID, diaryData) in value {
                
                // diaryID는 하위 항목의 키, diaryData는 해당 항목의 데이터입니다.
                //print("Diary ID: \(diaryID), Data: \(diaryData)")
                
                // 1. 유저가 작성한 전체 일기 삭제하게
                REF_DIARYS.child(diaryID).removeValue()
                
            
                // 2. 공유일기에 저장된 일기 uid 삭제
                REF_USER_SHAREDIARYS.child(diaryID).removeValue()
                
                
                // 3. 유저가 쓴 공유 일기에 누군가 남긴 댓글 및 유저가 작성한 댓글들 삭제 하는 로직
                REF_USER_Comments.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                    guard let value = snapshot.value as? [String: Any] else {
                        print("Error: Unable to retrieve data.")
                        return
                    }
                    
                    // 4. 일기안에 저장된 댓글 삭제
                    for (diaryCommentsID, diaryData) in value {
                        // diaryID는 하위 항목의 키, diaryData는 해당 항목의 데이터입니다.
                        print("Diary ID: \(diaryID), Data: \(diaryData)")
                        REF_DIARY_Comments.child(diaryCommentsID).removeValue()
                        // 여기에서 가져온 데이터를 사용하거나 저장하는 작업을 수행할 수 있습니다.
                        
                        // 5. 유저가 남긴 댓길 기록 삭제
                        REF_USER_Comments.child(uid).removeValue()
                    }
                }
                
            }
            
            
        }
        
        // 5. 유저가 작성한 일기 기록 삭제
        REF_USER_DIARYS.child(uid).removeValue()
        
        
        // 6. 사용자 삭제
        REF_USERS.child(uid).removeValue()
    
    }
}
