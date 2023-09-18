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
    func uploadDiary(caption: String, type: UploadDiaryConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        
        var values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes" : 0, "retweets": 0, "caption": caption] as [String : Any]
        
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
    
//    // 트윗 가져오는 메서드 만들기
//    func fatchTweets(completion: @escaping([Tweet]) -> Void){
//        var tweets = [Tweet]()
//
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
//            print(snapshot) // Snap (BiZ3OJRTclSTljANKX9NOsVL8D92) 1 : 내가 팔로우한 사용자의 id를 통해 해당 사용자가 작성한 트윗을 보게 하려고함
//            let followingUid = snapshot.key
//
//            REF_USER_TWEETS.child(followingUid).observe(.childAdded) { snapshot in
//                print(snapshot)// 내 피드의 나와야할 트윗 id를 표시
//                let tweetID = snapshot.key
//
//                self.fetchTweet(with: tweetID) { tweet in
//                    tweets.append(tweet)
//                    completion(tweets)
//                }
//            }
//        }
//
//        REF_USER_TWEETS.child(currentUid).observe(.childAdded) { snapshot in
//            let tweetID = snapshot.key
//
//            self.fetchTweet(with: tweetID) { tweet in
//                tweets.append(tweet)
//                completion(tweets)
//            }
//        }
//
//        //        REF_TWEETS.observe(.childAdded) { snapshot in
//        //            print("DEBUG: Snapshot is \(snapshot.value)")
//        //            guard let dictionary = snapshot.value as? [String: Any] else {return}
//        //            guard let uid = dictionary["uid"] as? String else {return}
//        //            //트윗 내부에 사용자 uid를 저장했음, 해당 uid는 user테이블의 키와 값음 해당 값을 이용하여 사용자를 가져와 트윗 모델에 전달 할 것임
//        //            let tweetID = snapshot.key // 각 트윗의 키를 얻을 수 있음
//        //
//        //            UserService.shared.fetchUser(uid: uid) { user in
//        //                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
//        //                tweets.append(tweet)// 모든 트윗을 찾아 담고 반환
//        //                completion(tweets)
//        //            }
//        //            // 이제 각 트윗과 연결된 사용자가 있음
//
//    }
//
//    // 사용자가 작성한 모든 트윗에 대한 변경 내역을 실시간으로 검색하는 데 사용됩니다.
//    func fatchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void){
//        var tweets = [Tweet]()
//
//        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
//            let tweetID = snapshot.key
//            print(snapshot.key)
//
//
//            // 리팩토링 작업
//            self.fetchTweet(with: tweetID) { tweet in
//                tweets.append(tweet)// 모든 트윗을 찾아 담고 반환
//                completion(tweets)
//            }
//
////            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
////                guard let dictionary = snapshot.value as? [String: Any] else {return}
////                guard let uid = dictionary["uid"] as? String else {return}
////
////                UserService.shared.fetchUser(uid: uid) { user in
////                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
////
////                }
////            }
//
//            // 프로필 이미지를 눌렀을때 user.uid에 해당하는것을 파이어베이스의가서 실제 값들을 건져오면 됨
//        }
//    }
//
//
//
//    // 알림탭에서, 상대방이 좋아요 누른 트윗으로 이동하는 메서드 : 위 코드를 복사
//    func fetchTweet(with tweetID: String, completion: @escaping(Tweet) -> Void) {
//
//        REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//            guard let uid = dictionary["uid"] as? String else { return }
//
//            UserService.shared.fetchUser(uid: uid) { user in
//                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
//                completion(tweet)
//            }
//        }
//    }
//
//    // 사용자 프로필에서 사용자가 답글 남긴  누른 트윗을 가져오기
//    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
//          var replies = [Tweet]()
//
//          REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
//              let tweetID = snapshot.key
//              guard let replyID = snapshot.value as? String else { return }
//
//              print("DEBUG: Tweet key is \(tweetID)")
//              print("DEBUG: Reply key is \(replyID)")
//
//              REF_TWEET_REPLIES.child(tweetID).child(replyID).observeSingleEvent(of: .value) { snapshot in
//                  guard let dictionary = snapshot.value as? [String: Any] else { return }
//                  guard let uid = dictionary["uid"] as? String else { return }
//                  let replyID = snapshot.key // 기존에 원래 트윗 ID를 제공하는 것을 답글 ID로 제공하는 것으로 수정
//                  // 내가 남긴 답글 트윗으로 바로 이동가능하게
//                  UserService.shared.fetchUser(uid: uid) { user in
//                      let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
//                      replies.append(reply)
//                      completion(replies)
//                  }
//              }
//          }
//
//      }
//
//    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
//          var tweets = [Tweet]()
//
//          REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
//              guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
//              guard let uid = dictionary["uid"] as? String else { return }
//              let tweetID = snapshot.key
//
//              UserService.shared.fetchUser(uid: uid) { user in
//                  let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
//                  tweets.append(tweet)
//                  completion(tweets)
//              }
//          }
//      }
//
//    // 사용자 프로필에서 좋아요 누른 트윗을 가져오기
//    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
//           var tweets = [Tweet]()
//
//           REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
//               let tweetID = snapshot.key
//               self.fetchTweet(with: tweetID) { likedTweet in
//                   var tweet = likedTweet
//                   tweet.didLike = true // 프로필에서 좋아요누른 트윗 보여줄때 빨간 하트 활성화
//
//                   tweets.append(tweet)
//                   completion(tweets)
//               }
//           }
//
//
//       }
//
//    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        // 좋아요 누르면 카운트 증감
//        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
//        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
//
//        if tweet.didLike {
//            // remove like data from firebase - unlike tweet
//            //그래서 tweet-like 들어가서 트윗키찾고 좋아요 누른 유저 아이디찾고 지우기
//            //user-likes들어가서 현재 사용자 ID를 찾은 다음 좋아요 취소한 트윗을 찾아 지우기
//            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (err, ref) in
//                REF_TWEET_LIKES.child(tweet.tweetID).removeValue(completionBlock: completion)
//            }
//        } else {
//            // add like data to firebase - like tweet
//            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { (err, ref) in
//                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
//            }
//
//        }
//    }
//
//    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
//         guard let uid = Auth.auth().currentUser?.uid else { return }
//
//         REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
//             completion(snapshot.exists())
//         }
//     }
//
}
