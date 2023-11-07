//
//  NotificationsController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.
//

import UIKit
private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    } // 알림 배열 만들기 : 현재 사용자가 받은 알림들을 담기위한
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    override func viewWillAppear(_ animated: Bool) {
        // 프로필로 이동하고 다시 올때 네비게이션바가 다시 보일 수 있도록
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors
        @objc func handleRefresh() {
            print("DEBUG: 새로 고침")
            fetchNotifications()
        }
    
    // MARK: - API
    func fetchNotifications() {
        refreshControl?.beginRefreshing() // 새로 고침 제어
        NotificationService.shared.fetchNotifications { (notifications) in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    // 사용자를 팔로우 하는지 판단하는 함수 : 리팩토링
    func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            guard case .follow = notification.type else { return }
            
            let user = notification.user
            
            UserService.shared.checkIfUserIsFollowd(uid: user.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
                
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier) // 셀 등록
        tableView.rowHeight = 60 // 셀 높이 설정
        tableView.separatorStyle = .none // 셀 구분선 없애기
        
        let refreshControl = UIRefreshControl() // 위로 화면 스크롤시 새로고침 가능하게 만들기
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
}


// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 알림 종류에 맞춰 기능 구현하기, 좋아요 누른 트윗 가져와 표시해주기
        let notification = notifications[indexPath.row]
        print("DEBUG: Tweet id is \(notification.diaryID)")
        // DEBUG: Tweet id is Optional("-NbmZWTCWHNu10HoWyR1") 트윗 id 잘 넘어옴
                
        
        // 오류나는 것을 수정 : 속성 기본값 때문에 크래시 나는걸 방지하고 해당 라인 만나면 탈출 하기 때문에 아래 코드 라인까지 가지 않아서 크래시 충돌나지 않음
        guard let diaryID = notification.diaryID else { return }

        DiaryService.shared.fetchDiary(with: diaryID) { tweet in
            //let controller = CommentFeedViewController(diary: diaryID)
            //self.navigationController?.pushViewController(controller, animated: true)
        }
        // 이제 클릭하면 데이터베이스에서 내 트윗을 가져오고 실제로 채워짐
    }
}

// MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    
    // 셀에서 알림과 연결된 사용자 가져오기 : 프로필 이미지 클릭시
    func didTapProfileImage(_ cell: NotificationCell) {
        // 셀에 사용자 정보가 있기 때문에 가능
        guard let user = cell.notification?.user else { return }

        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // 팔로우 버튼 클릭시
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        print("DEBUG: User is followed \(user.isFollowed)")
        
        if user.isFollowed {
            // 팔로우 하는 경우 팔로우를 해제
            UserService.shared.unfollowUser(uid: user.uid) { (error, red) in
                cell.notification?.user.isFollowed = false
            }
        }
        else {
            // 팔로우하지 않는 경우 팔로우
            UserService.shared.followUser(uid: user.uid) { (error, red) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
}
