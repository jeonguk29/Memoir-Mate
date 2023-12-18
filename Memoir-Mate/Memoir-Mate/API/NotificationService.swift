//
//  NotificationService.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.
//


import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct NotificationService {
    static let shared = NotificationService()
    
    // 알림 유형을 전달 할것임
    // 알림에는 항상 사용자가 있음
    func uploadNotification(toUser user: User,
                            type: NotificationType,
                            diaryID: String? = nil) {
        print("DEBUG: Type: is \(type)")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        // 우리가 여기서 트윗 좋아요를 누르면 트윗 알림은 누군가의 트윗 알림으로 사전 형태로 저장
        if let diaryID = diaryID {
            values["diaryID"] = diaryID
        }
        // 해당 사용자(우기)로 이동하여 해당 사용자에 대한 구조(알림 구조)를 만들고 자식 값을 업데이트합니다.
        // 자식 값 : 시간, 좋아요 누른 트윗 id, 알림 타입(좋아요, 팔로우), 누른 사용자의 uid
        
        REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
    }
    
    // 알림 가져오는 메서드
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]() // 알림을 담을 배열
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // 현제 사용자 uid 뽑기
        
        
        // 사용자에 대한 알림이 있는지 확인
        REF_NOTIFICATIONS.child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                // 사용자에게 알림이 없음을 의미
                completion([])
            } else {
                getNotifications(uid: uid, completion: completion)
            }
        }
    }
    
    
    fileprivate func getNotifications(uid: String,
                                      completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        
        // 현재 사용자의 uid를 기준으로 모든 알림들 가져오기
        REF_NOTIFICATIONS.child(uid).observe(.childAdded) { (snapshot,err)  in
            /*
             알림이 없을때 빙빙 도는 것은 해당 블록을 수행 할 수 없어서
             마지막   completion(notifications)을 실행 할수 없기 때문임
             */
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            // 알림에 있는 uid와 연결된 사용자를 가져오기 (누가 좋아요를 눌렀고, 팔로우를 했는지 알림을 보낸 사람 정보를 가져오기 위함)
            UserService.shared.fetchUser(uid: uid) { (user) in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }

}
