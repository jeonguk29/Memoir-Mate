//
//  Diary.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/18.
//


import UIKit

// 일기를 담을 모델
struct Diary{
    let caption: String
    let diaryID: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    let user:User
    var didLike = false // Is follow 했던 것과 거의 똑같은 개념 이속성을 이용해 좋아요 누른것을 기억하고 처리하는 작업을 할것임
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil } // 답글인지에 따라 누구에게 답글 다는건지 라벨을 표시할지 말지 정하는 속성값
    
    // 모델을 조금 더 세분화하면 사용자 없이 트윗이 존재할 수 없습니다.
    // 따라서 모든 트윗은 누군가의 것이어야 합니다.
    init(user: User ,DiaryID: String, dictionary: [String: Any]) {
        self.diaryID = DiaryID
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweetCount"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
                  self.replyingTo = replyingTo
        }
      
    }
}

