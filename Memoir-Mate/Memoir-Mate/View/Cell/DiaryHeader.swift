//
//  DiaryHeader.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.

import UIKit
import ActiveLabel

// 작업 시트를 위해 위임할 프로토콜 생성
protocol DiaryHeaderDelegate: class {
    func showActionSheet()
    func handleFetchUser(withUsername username: String)
}

class DiaryHeader: UICollectionReusableView {
    
    
    // MARK: - Properties
    
    // 실제 데이터를 담기 위한 트윗 변수
    var diary: Diary? {
          didSet { configure() }
      }
    
    weak var delegate: DiaryHeaderDelegate? // 델리게이트 변수 생성
    
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .mainColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Peter Parker"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "spiderman"
        return label
    }()
    
    // 내용 표시
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = "Some test caption from spiderman for now"
        label.mentionColor = .mainColor
        label.hashtagColor = .mainColor
        return label
    }()
    
    // 날짜 표시
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "6:33 PM - 1/28/2020"
        return label
    }()
    
    
    // MARK: - 헤더 맨 오른쪽 옵션 버튼
    private lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 리트윗, 좋아요 하위 뷰 만들기
    private lazy var retweetsLabel =  UILabel()
    
    
    // 답글 라벨
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .mainColor
        label.hashtagColor = .mainColor
        return label
    }()
    
    private lazy var likesLabel =  UILabel()
    
    private lazy var statsView: UIView = {
        // 하위뷰 뼈대
        let view = UIView()
        view.backgroundColor = .white
        
        
        // 상위 구분선
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)
        
        // 구분선 사이 담을 내용
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 16)
        
        // 히위 구분선
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)
        
        return view
    }()
    
    
    // MARK: - 4개의 버튼
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .vertical // 세로
        labelStack.spacing = -6
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStack])
        imageCaptionStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack) // 기본 수평
        stack.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        
        addSubview(dateLabel)
        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 16)
        
        addSubview(optionButton)
        optionButton.centerY(inView: stack)
        optionButton.anchor(right: rightAnchor, paddingRight: 8)
        
        // 하위 뷰 올리기
        addSubview(statsView)
        statsView.anchor(top: dateLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, height: 40)
        
        // 4개의 버튼을 담은 스택뷰 올리기
        let actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStack.spacing = 72
        
        addSubview(actionStack)
        actionStack.centerX(inView: self) // 현제 메인 뷰의 가운데 정렬
        actionStack.anchor(top: statsView.bottomAnchor, paddingTop: 16)
        // 왼쪽 지점에 위치, 그다음 간격(패딩) 정하기
        
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        print("유저의 프로파일로 이동")
    }
    
    @objc func showActionSheet() {
        print("우측 옵션 버튼을 클릭")
        delegate?.showActionSheet()
    }
    
    
    @objc func handleCommentTapped() {
        
    }
    
    @objc func handleRetweetTapped() {
        
    }
    
    @objc func handleLikeTapped() {
        
    }
    
    @objc func handleShareTapped() {
        
    }
    
    
    // MARK: - Helpers
    
    // 실제 트윗 정보가 넘어오면 실행할 부분 뷰 모델에서 동적 데이터 받아오기
    func configure() {
        guard let diary = diary else { return }
        
        let viewModel = DiaryViewModel(diary: diary)
        
        captionLabel.text = diary.caption
        fullnameLabel.text = diary.user.email
        usernameLabel.text = viewModel.usernameText
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        dateLabel.text = viewModel.headerTimestamp
        retweetsLabel.attributedText = viewModel.retweetsAttributedString
        
        // 좋아요 누른 트윗 눌렀을때 헤더에 좋아요 버튼 표시
        likesLabel.attributedText = viewModel.likesAttributedString
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        
        // 뷰모델에서 동적 처리에 따른 답글 라벨 표시
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    // 4가지 버튼을 편하게 만들기 위한 함수
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    // 언급 사용자 누를때 사용자 프로필로 이동
    func configureMentionHandler() {
        captionLabel.handleMentionTap { [weak self] username in
            print("사용자의 프로필로 이동 \(username)")
            self?.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
}
