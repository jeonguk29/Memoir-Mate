//
//  UserCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/1/23.
//

import UIKit

class UserCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    var user: User? { // 실제 사용자 정보를 채우기 위한 변수
        didSet { configure() } // 사용자 정보를 받으면 해당 함수 호출하여 UI 뷰에 사용자 정보를 대입
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40/2
        iv.backgroundColor = .mainColor
        
        return iv
    }()
    
    private let userIdmarkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "사용자 ID : "
        label.textColor = .systemGray
        return label
    }()
    
    private let userNickmarkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "사용자 이름 : "
        label.textColor = .systemGray
        return label
    }()
    
    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Username"
        return label
    }()
    
    private let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Fullname"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        //profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
//        let userId = UIStackView(arrangedSubviews: [userIdmarkLabel, userIdLabel])
//        userId.axis = .horizontal
//        userId.alignment = .leading
//        userId.spacing = 1
//        
//        let userNick = UIStackView(arrangedSubviews: [userNickmarkLabel, userNicknameLabel])
//        userNick.axis = .horizontal
//        userNick.alignment = .leading
//        userNick.spacing = 1
        
        let stack = UIStackView(arrangedSubviews: [userIdLabel, userNicknameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        //stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            //stack.firstBaselineAnchor.constraint(equalTo: profileImageView.firstBaselineAnchor)
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    
    func configure() {
        guard let user = user else {return}
        //profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.sd_setImage(with: user.photoURLString)
        userIdLabel.text = user.userID
        userNicknameLabel.text = user.userNickName
    }
    
    
}
