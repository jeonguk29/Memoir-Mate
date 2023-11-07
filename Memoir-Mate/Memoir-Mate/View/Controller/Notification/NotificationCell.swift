//
//  NotificationCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.
//


import UIKit
import SDWebImage


// 셀에서 컨트롤러로 작업을 위임하는 프로토콜 구현
protocol NotificationCellDelegate: class {
    func didTapProfileImage(_ cell: NotificationCell) // 사용자 프로필로 이동
    func didTapFollow(_ cell: NotificationCell) // 팔로우 이벤트 처리
}

// 알림 셀 구현
class NotificationCell: UITableViewCell {

    // MARK: - Properties
    var notification: Notification? {
        didSet {configure()}
    }
    
    weak var delegate: NotificationCellDelegate?

    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .mainColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private lazy var followButton: UIButton = {
            let button = UIButton(type: .system)
            button.setDimensions(width: 62, height: 18)
            button.layer.cornerRadius = 18 / 2
            button.setTitle("Loading", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitleColor(.mainColor, for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.mainColor.cgColor
            button.layer.borderWidth = 2
            button.addTarget(self, action: #selector(handleFollowButtonTapped), for: .touchUpInside)

            return button
        }()

    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification message"

        return label
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
                stack.spacing = 8
                stack.alignment = .center

        contentView.addSubview(stack) // 바뀐 부분
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.anchor(right: rightAnchor, paddingRight: 12)
        
        
        addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12)
            
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selector
    @objc func handleProfileImageTapped() {
        print("HERE!")
        delegate?.didTapProfileImage(self)
    }
    
    @objc func handleFollowButtonTapped() {
          delegate?.didTapFollow(self)
      }
    
    
    // MARK: - Helpers
    func configure() {
        // 알림이 들어온 순간 실행 되며 viewModel에서 동적값을 전달 받아 적용함
        guard let notification = notification else { return }
        
        let viewModel = NotificationViewModel(notification: notification)
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
}
