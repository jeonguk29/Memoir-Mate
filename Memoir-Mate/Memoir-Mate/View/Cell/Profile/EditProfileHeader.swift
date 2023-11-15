//
//  EditProfileHeader.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/12/23.

import UIKit

protocol EditProfileHeaderDelegate: class {
    func didTapChangeProfilePhoto() // 프로필 이미지 선택시 이미지 수정 하는 것을 위임
}

class EditProfileHeader: UIView {

    // MARK: - Properties
    private let user: User
    weak var delegate: EditProfileHeaderDelegate?

    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3.0
        iv.setDimensions(width: 100, height: 100)
        iv.layer.cornerRadius = 100 / 2
        return iv
    }()

    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 사진 변경", for: .normal)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()


    // MARK: - Lifecycle
    init(user: User) {
        self.user = user // 헤더에 프로필 사진을 수정할거라 유저 값을 받아야함
        super.init(frame: .zero)

        backgroundColor = .mainColor

        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16) // 중앙에 배치한 다음 y축에서 16픽셀 위로 이동합니다.

        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self,
                                  topAnchor: profileImageView.bottomAnchor,
                                  paddingTop: 8)

        profileImageView.sd_setImage(with: user.photoURLString)
    }

    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors
    @objc func handleChangeProfilePhoto() {
        delegate?.didTapChangeProfilePhoto()
    }
}
