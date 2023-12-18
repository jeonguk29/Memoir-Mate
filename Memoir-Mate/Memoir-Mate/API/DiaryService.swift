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
    func uploadDiary(userSelectDate: String, userSelectWeather: String ,caption: String, type: UploadDiaryConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        
        var values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes" : 0, "retweets": 0, "caption": caption, "userSelectWeather" : userSelectWeather, "userSelectDate": userSelectDate, "isShare" : false] as [String : Any]
        
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
    
   
    func updateDiary(diary: Diary?, userSelectDate: String, userSelectWeather: String,caption: String, completion: @escaping(DatabaseCompletion)) {
        guard let diary = diary else {return}
        let diaryID = diary.diaryID // diary.diaryID를 옵셔널이 아닌 변수로 선언
        let uid = diary.user.uid // diary.user.uid를 옵셔널이 아닌 변수로 선언
        
        let timestamp = Int(diary.timestamp.timeIntervalSince1970) // Unix 타임스탬프

        var values = ["uid": uid, "timestamp": timestamp, "caption": caption, "userSelectDate": userSelectDate, "userSelectWeather" : userSelectWeather] as [String: Any]
        
        // 파이어 베이스에 일기 업데이트 하기
        REF_DIARYS.child(diaryID).updateChildValues(values, withCompletionBlock: completion)
    
    }
    
    
    func shareDiary(diary: Diary?, completion: @escaping(DatabaseCompletion)) {
        guard let diary = diary else {return}
        let diaryID = diary.diaryID // diary.diaryID를 옵셔널이 아닌 변수로 선언
        let uid = diary.user.uid // diary.user.uid를 옵셔널이 아닌 변수로 선언
        
        let timestamp = Int(diary.timestamp.timeIntervalSince1970) // Unix 타임스탬프

        var values = ["uid": uid, "timestamp": timestamp,
                      "likes": 0, "retweets": 0, "caption": diary.caption, "userSelectDate": diary.userSelectDate, "isShare" : true] as [String: Any]
        
        // 파이어 베이스에 일기 업데이트 하기
        REF_DIARYS.child(diaryID).updateChildValues(values, withCompletionBlock: completion)
        REF_USER_SHAREDIARYS.child(diaryID).updateChildValues([diaryID : 1], withCompletionBlock: completion)
    }
    
    func shareClearDiary(diary: Diary?, completion: @escaping(DatabaseCompletion)) {
        guard let diary = diary else {return}
        let diaryID = diary.diaryID // diary.diaryID를 옵셔널이 아닌 변수로 선언
        let uid = diary.user.uid // diary.user.uid를 옵셔널이 아닌 변수로 선언
        
        let timestamp = Int(diary.timestamp.timeIntervalSince1970) // Unix 타임스탬프

        var values = ["uid": uid, "timestamp": timestamp,
                      "likes": 0, "retweets": 0, "caption": diary.caption, "userSelectDate": diary.userSelectDate, "isShare" : false] as [String: Any]
        
        // 파이어 베이스에 일기 업데이트 하기
        REF_DIARYS.child(diaryID).updateChildValues(values, withCompletionBlock: completion)
        REF_USER_SHAREDIARYS.child(diaryID).updateChildValues([diaryID : 1], withCompletionBlock: completion)
    }
    
    func deleteDiary(diary: Diary?, completion: @escaping(DatabaseCompletion)) {
        guard let diary = diary else {return}
        let diaryID = diary.diaryID // diary.diaryID를 옵셔널이 아닌 변수로 선언
        let userID = diary.user.uid // diary.diaryID를 옵셔널이 아닌 변수로 선언
        
    
        REF_DIARYS.child(diaryID).removeValue(completionBlock: completion)
        REF_USER_DIARYS.child(userID).child(diaryID).removeValue(completionBlock: completion)
        REF_USER_SHAREDIARYS.child(diaryID).removeValue(completionBlock: completion)
       
    }
    
    
    // 일기 가져오는 메서드 만들기
    func fatchDiarys(completion: @escaping([Diary]) -> Void){
        var diarys = [Diary]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_DIARYS.child(currentUid).observe(.childAdded) { snapshot in
            //print(snapshot)// 내 피드의 나와야할 트윗 id를 표시
            let diaryID = snapshot.key
            
            self.fetchDiary(with: diaryID) { diary in
                diarys.append(diary)
                completion(diarys)
            }
        }
    }
    
    // 공유 일기 가져오는 메서드 만들기
    func communityFatchDiarys(completion: @escaping([Diary]) -> Void){
        var diarys = [Diary]()
        
        REF_USER_SHAREDIARYS.observeSingleEvent(of: .value) { snapshot in
            guard let snapshotValue = snapshot.value as? [String: Any] else {
                completion(diarys)
                return
            }
            
            let diaryIDs = Array(snapshotValue.keys)
            
            diaryIDs.forEach { diaryID in
                self.fetchDiary(with: diaryID) { diary in
                    diarys.append(diary)
                    
                    if diarys.count == diaryIDs.count {
                        completion(diarys)
                    }
                }
            }
        }
    }

    // 일기 댓글 남기는 메서드
    func diaryComment(user : User? ,diary: Diary?, type: UploadDiaryConfiguration ,caption: String, completion: @escaping(DatabaseCompletion)){
        
        //        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let diary = diary else {return}
        let diaryID = diary.diaryID // diary.diaryID를 옵셔널이 아닌 변수로 선언
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        var replyingTo = diary.user.username
        let values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes": 0, "retweets": 0, "caption": caption, "replyingTo" : replyingTo] as [String: Any]
        
     
        guard let user = user else {return}
        
        REF_DIARY_Comments.child(diaryID).childByAutoId().updateChildValues(values){ (err, ref) in
            guard let replyKey = ref.key else { return }
            // 사용자가 답글을 단 트윗을 저장하기 위함
            // 트윗 남길때 현제 사용자 uid를 id 값으로 하위 구조는 상대방 트윗 id가 키 : 그의 대한 값으로 답글 남긴 트윗 id를 전달
            
            REF_USER_Comments.child(uid).updateChildValues([diary.diaryID: replyKey],
                                                           withCompletionBlock: completion)
            
         
            //현제 사용자가 남기는 댓글이 아닐때만 댓글 알림 보내기
       
            if diary.user.userID != user.userID{
                NotificationService.shared.uploadNotification(toUser: diary.user,
                                                              type: .reply,
                                                              diaryID: diary.diaryID)
            }
           
            
            
        }
    }
      
               

    
    func fetchDiaryComment(with diaryID: String, completion: @escaping([Diary]) -> Void) {
        var diarys = [Diary]()
        print("fetchDiaryComment 시작")
        
        REF_DIARY_Comments.child(diaryID).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    completion(diarys)
                    return
                }
                
                for (commentKey, commentData) in value {
                    guard let commentDict = commentData as? [String: Any],
                          let caption = commentDict["caption"] as? String,
                          let likes = commentDict["likes"] as? Int,
                          let retweets = commentDict["retweets"] as? Int,
                          let timestamp = commentDict["timestamp"] as? TimeInterval,
                          let uid = commentDict["uid"] as? String else {
                        continue
                    }
                    
                    UserService.shared.fetchUser(uid: uid) { user in
                        let diary = Diary(user: user, DiaryID: "", dictionary: [
                            "caption": caption,
                            "likes": likes,
                            "retweets": retweets,
                            "timestamp": timestamp
                        ])
                        
                        print("댓글 \(diary.caption)")
                        
                        diarys.append(diary)
                        
                        if diarys.count == value.count {
                            completion(diarys)
                        }
                    }
                }
            }
        
    }
    
    
    func fetchDiary(with diaryID: String, completion: @escaping(Diary) -> Void) {
        print("fetchDiary 전달 \(diaryID)")
        REF_DIARYS.child(diaryID).observeSingleEvent(of: .value) { snapshot  in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let diary = Diary(user: user, DiaryID: diaryID, dictionary: dictionary)
                print("fetchDiary 일기 \(diary)")
                completion(diary)
            }
        }
    }
    
    // 알림탭에서, 상대방이 좋아요 누른 트윗으로 이동하는 메서드 : 위 코드를 복사
    func fetchNotificationsDiary(with diaryID: String,completion: @escaping(Diary) -> Void) {
        print("fetchDiary 전달 \(diaryID)")
        REF_DIARYS.child(diaryID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                //print("fetchDiary 일기 \(user)")
                let diary = Diary(user: user, DiaryID: diaryID, dictionary: dictionary)
                //print("fetchDiary 일기 \(diary)")
                completion(diary)
            }
        }
    }
    
    
    // 사용자 프로필을 위해 만듬
    // 사용자가 작성한 모든 트윗에 대한 변경 내역을 실시간으로 검색하는 데 사용됩니다.
       func fatchDiarys(forUser user: User, completion: @escaping([Diary]) -> Void){
           var diarys = [Diary]()
           
           REF_USER_DIARYS.child(user.uid).observe(.childAdded) { snapshot in
               let diaryID = snapshot.key
               print(snapshot.key)
               
               
               // 리팩토링 작업
               self.fetchDiary(with: diaryID) { diary in
                   diarys.append(diary)// 해당 사용자에 맞는 모든 일기을 찾아 담고 반환
                   completion(diarys)
               }
        
               
               // 프로필 이미지를 눌렀을때 user.uid에 해당하는것을 파이어베이스의가서 실제 값들을 건져오면 됨
           }
       }
    
    
    // 사용자 프로필에서 좋아요 누른 트윗을 가져오기
    func fetchLikes(forUser user: User, completion: @escaping([Diary]) -> Void) {
           var diarys = [Diary]()

           REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
               let diaryID = snapshot.key
               self.fetchDiary(with: diaryID) { likeddiarys in
                   var diary = likeddiarys
                   diary.didLike = true // 프로필에서 좋아요누른 트윗 보여줄때 빨간 하트 활성화

                   diarys.append(diary)
                   completion(diarys)
               }
           }


       }
    
    func likeDiary(diary: Diary, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 좋아요 누르면 카운트 증감
        let likes = diary.didLike ? diary.likes - 1 : diary.likes + 1
        REF_DIARYS.child(diary.diaryID).child("likes").setValue(likes)
        
        if diary.didLike {
            // remove like data from firebase - unlike tweet
            //그래서 tweet-like 들어가서 트윗키찾고 좋아요 누른 유저 아이디찾고 지우기
            //user-likes들어가서 현재 사용자 ID를 찾은 다음 좋아요 취소한 트윗을 찾아 지우기
            REF_USER_LIKES.child(uid).child(diary.diaryID).removeValue { (err, ref) in
                REF_DIARY_LIKES.child(diary.diaryID).removeValue(completionBlock: completion)
            }
        } else {
            // add like data to firebase - like tweet
            REF_USER_LIKES.child(uid).updateChildValues([diary.diaryID: 1]) { (err, ref) in
                REF_DIARY_LIKES.child(diary.diaryID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
            
        }
    }
    
    func checkIfUserLikedDiary(_ diary: Diary, completion: @escaping(Bool) -> Void) {
         guard let uid = Auth.auth().currentUser?.uid else { return }

         REF_USER_LIKES.child(uid).child(diary.diaryID).observeSingleEvent(of: .value) { snapshot in
             completion(snapshot.exists())
         }
     }
   

}
