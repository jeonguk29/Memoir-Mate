//
//  EditProfileCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/12/23.

import UIKit


protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell) // 변경한 유저의 정보를 업데이트 하는 것을 위임하기 위함
}

class EditProfileCell: UITableViewCell {

    // MARK: - Properties
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .mainColor
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return tf
    }()
    
    // 기존에 CaptionTextView를=> InputTextView로 리팩토링해서 사용
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .mainColor
        tv.placeholderLabel.text = "안녕하세요!!"
        return tv
    }()
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

               contentView.addSubview(titleLabel)
               titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
               titleLabel.anchor(top: topAnchor,
                                 left: leftAnchor,
                                 paddingTop: 12,
                                 paddingLeft: 16)

               contentView.addSubview(infoTextField)
               infoTextField.anchor(top: topAnchor,
                                    left: titleLabel.rightAnchor,
                                    bottom: bottomAnchor,
                                    right: rightAnchor,
                                    paddingTop: 4,
                                    paddingLeft: 16,
                                    paddingBottom: 8)

               contentView.addSubview(bioTextView)
               bioTextView.anchor(top: topAnchor,
                                  left: titleLabel.rightAnchor,
                                  bottom: bottomAnchor,
                                  right: rightAnchor,
                                  paddingTop: 4,
                                  paddingLeft: 10,
                                  paddingBottom: 8)
        
        
        // 텍스트 보기에 대해 종료되었음을 관찰자에게 알려주는 것임
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUpdateUserInfo),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }

}
