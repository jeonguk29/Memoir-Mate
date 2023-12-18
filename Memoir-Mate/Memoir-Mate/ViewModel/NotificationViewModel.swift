//
//  NotificationViewModel.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.
//


import Foundation
import UIKit
import SDWebImage

struct NotificationViewModel {

    private let notification: Notification
    private let type: NotificationType
    private let user: User

    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: notification.timestamp, to: now) ?? "1m"
    }

    var notificationMessage: String {
        switch type {

        case .follow: return "님이 당신을 팔로우 하기 시작했습니다."
        case .like: return "님이 당신의 일기을 좋아합니다."
        case .reply: return "님이 당신의 일기에 댓글을 남겼습니다."
        case .retweet: return "님이 당신의 트윗을 리트윗했습니다"
        case .mention: return "님이 트윗에서 당신을 언급했습니다"
        }
    }

    // 알림 표시 텍스트
    var notificationText: NSAttributedString? {
        guard let timestamp = timestampString else { return nil}

        let attributedText = NSMutableAttributedString(string: user.userNickName,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(timestamp) ",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        return attributedText
    }

    var profileImageURL: URL? {
        return user.photoURLString
    }
    
    var shouldHideFollowButton: Bool {
        return type != .follow // 알림 유형이 팔로우와 같이 않으면 해당 팔로우 버튼 숨기기
    }
    
    var followButtonText: String { // 알림 유형이 팔로우와 같을때는 값(팔로우 했는지 안했는지)에 따라 다르게 표시
        return user.isFollowed ? "Following" : "Follow"
    }

    init(notification: Notification) { // 초기화시 알림을 받음
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
