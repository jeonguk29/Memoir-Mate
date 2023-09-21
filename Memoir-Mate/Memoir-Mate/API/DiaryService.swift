//
//  DiaryService.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/18.
//


import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct DiaryService {
    static let shared = DiaryService()
    
    // 별명 적용 : DatabaseCompletion
    func uploadDiary(userSelectDate: String,caption: String, type: UploadDiaryConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        
        var values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes" : 0, "retweets": 0, "caption": caption, "userSelectDate": userSelectDate] as [String : Any]
        
        // 파이어 베이스에 답장 업로드하기
        switch type {
        case .diary:
            REF_DIARYS.childByAutoId().updateChildValues(values) { (error, ref) in
                // update user-tweet structure after tweet upload completes
                guard let tweetID = ref.key else { return }
                REF_USER_DIARYS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
                
                // 작성한 사용자의 uid가 최종 부모 값이고 그 아래에 트윗 key를 저장
                // 따라서 궁극적으로 우리는 사용자가 어떤 트윗을 작성했는지 알아낼 수 있을 것입니다.
                // 이런것을 팬 아웃이라고 하며 : 서버 작업이 훨씬 줄어듬
            }
        case .reply(let tweet): break
//            values["replyingTo"] = tweet.user.username // 누구에게 답글 남기는지 이름 값을 추가
//            // 답글일때는 기준 트윗 아이디 밑에 답글 트윗 을 생성
//            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId()
//                .updateChildValues(values) { (err, ref) in
//                    guard let replyKey = ref.key else { return }
//                    // 사용자가 답글을 단 트윗을 저장하기 위함
//                    // 트윗 남길때 현제 사용자 uid를 id 값으로 하위 구조는 상대방 트윗 id가 키 : 그의 대한 값으로 답글 남긴 트윗 id를 전달
//                    REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey],
//                                                                  withCompletionBlock: completion)
//                }
//
        }
    }
    // 트윗 가져오는 메서드 만들기
    func fatchDiarys(completion: @escaping([Diary]) -> Void){
        var diarys = [Diary]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_DIARYS.child(currentUid).observe(.childAdded) { snapshot in
            print(snapshot)// 내 피드의 나와야할 트윗 id를 표시
            let diaryID = snapshot.key
            
            self.fetchDiary(with: diaryID) { diary in
                diarys.append(diary)
                completion(diarys)
            }
        }
    }
    
    
    // 알림탭에서, 상대방이 좋아요 누른 트윗으로 이동하는 메서드 : 위 코드를 복사
    func fetchDiary(with diaryID: String, completion: @escaping(Diary) -> Void) {
        
        REF_DIARYS.child(diaryID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let diary = Diary(user: user, DiaryID: diaryID, dictionary: dictionary)
                completion(diary)
            }
        }
    }
   

}
