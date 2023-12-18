//
//  ActionSheetViewModel.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.
//

import Foundation

struct ActionSheetViewModel {

    private let user: User

    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        // 아래서 만든 케이스들을 어떤 조건에따라 각각 배치할지 파악해야함
        
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            //사용자가 팔로우된 경우 팔로우 취소 작업을 추가, 아니면 팔로우 할수 있게
            let followOptions: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOptions)
        }

        results.append(.report)
        return results
    }

    init(user: User) {
        self.user = user
    }
}

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete

    var description: String {
        switch self {
        case .follow(let user): return "Follow @\(user.username)"
        case .unfollow(let user): return "Unfollow @\(user.username)"
        case .report: return "Report Tweet"
        case .delete: return "Delete Tweet"
        }
    }
}
