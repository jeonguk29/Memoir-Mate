//
//  ProfileHeaderViewModel.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/1/23.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case diarys
    case likes
    
    var description: String {
        switch self {
        case .diarys: return "작성 일기"
        //case .replies: return "Tweets & Replies"
        case .likes: return "좋아요 누른 일기"
        }
    }
}

// 헤더 ProfileView에 부담을 주지 않기 위해 동적 기능을 처리 하는 부분을 구현
// 실제 유저의 데이터를 받아와서 이쪽에서 처리하고 뷰로 전달 할것임(ProfileHeader)
struct ProfileHeaderViewModel {
    private let user: User
    
     let usernameText : String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var actionButtonTitle: String {
        // 자신의 프로필 눌렀을때는 프로필 수정 버튼으로 표시
        // 아니라면 상대방 팔로우 버튼으로 표시
        // 이를 위해 User모델의 속성을 하나 추가했음
        
        if user.isCurrentUser {
            return "프로필 수정"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            // 따라서 사용자가 팔로우되지 않고 사용자가 현재 사용자가 아닌 경우 돌아가서 팔로우할 것입니다.
            return "Follow"
        }
        
        if user.isFollowed {
            return "Following"
        }
        
        return "Loading"
    }
    
    init(user: User) {
        self.user = user
        self.usernameText = "@" + user.userNickName
    }
    
    // fileprivate 비공계로 설정, 도움이 함수일 뿐임
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
