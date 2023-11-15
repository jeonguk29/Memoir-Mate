//
//  EditProfileFooter.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/12/23.
//

import UIKit

protocol EditProfileFooterDelegate: class {
    func handleLogout()
}

class EditProfileFooter: UIView {

    // MARK: - Properties
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)

        return button
    }()

    weak var delegate: EditProfileFooterDelegate?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(logoutButton)
        logoutButton.anchor(left: leftAnchor,
                            right: rightAnchor,
                            paddingLeft: 16,
                            paddingRight: 16)
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.centerY(inView: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    // MARK: - Selectors
    @objc func handleLogout() {
        delegate?.handleLogout()
    }
}
