//
//  CommunityCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/10/05.
//

import UIKit
import ActiveLabel

// 프로토콜을 만들어서 현제 내 트윗셀을 내 컨트롤러로 전달할 것임
protocol CommunityCellDelegate: class {
    func handelProfileImageTapped(_ cell: CommunityCell) // 컨트롤러에게 위임할 작업을 명시
    func handleReplyTapped(_ cell: CommunityCell)
    func handleLikeTapped(_ cell: CommunityCell) // 트윗 좋아요 동작처리를 위임할 메서드
    func handleFetchUser(withUsername username: String) // 사용자 이름에 대하여 uid를 가져오는 메서드
}

class CommunityCell:UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "CommunityCell" // 재사용 식별자 정의
    
    // 데이터를 가져오기 전일수도 있기때문에 옵셔널로 선언
    var diary: Diary? {
        didSet { configure() }
    }
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    weak var delegate: CommunityCellDelegate?
    
    var originalFrame: CGRect? // 셀의 원래 프레임을 저장하기 위한 속성
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 28, height: 28)
        iv.layer.cornerRadius = 28/2
        iv.backgroundColor = .commColor
        
        // 버튼이 아닌 view 객체를 탭 이벤트 처리하는 방법 : 사용자 프로필 작업하기
        // lazy var로 profileImageView를 수정해야함 아래 함수가 만들어지기 전에 인스턴스를 찍을 수 있어서
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true

        // 프로필 이미지뷰의 Auto Layout 설정
        iv.translatesAutoresizingMaskIntoConstraints = false
        // 비율 제약 조건 추가
        iv.widthAnchor.constraint(equalTo: iv.heightAnchor).isActive = true
        return iv
    }()
    
    
    // 누구에게 답글 남기는지 표시하기 위한 라벨
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .commColor
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont(name: "NanumMuGungHwa", size: 25)
        label.numberOfLines = 0 // 여러줄 표시 가능 하게
        label.text = "Test caption"
        label.mentionColor = .commColor
        label.hashtagColor = .commColor
        return label
    }()
    
    private let infoLabel = UILabel()
    
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
    
    // 백그라운드 뷰
    lazy var backgroundBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .commColor // 원하는 배경색상으로 변경
        view.layer.cornerRadius = 20 // 원하는 값을 지정하여 둥글게 만듭니다.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()
    
    // 백그라운드 뷰
    private lazy var backgroundContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // 원하는 배경색상으로 변경
        view.layer.cornerRadius = 15 // 원하는 값을 지정하여 둥글게 만듭니다.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()
    
    
    //    // 추가: 삭제 버튼을 나타내는 UIButton
    //    private let deleteButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setImage(UIImage(systemName: "trash"), for: .normal)
    //        button.tintColor = .red
    //        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    //        return button
    //    }()
    
    
    // MARK: - Lifecycle
    override init(frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(backgroundBorderView) // 백그라운드 뷰를 가장 처음에 추가
        backgroundBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundBorderView.addSubview(backgroundContentView)
        backgroundContentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            backgroundBorderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            backgroundBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            backgroundBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            backgroundBorderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            
            backgroundContentView.topAnchor.constraint(equalTo: backgroundBorderView.topAnchor, constant: 6),
            backgroundContentView.leadingAnchor.constraint(equalTo: backgroundBorderView.leadingAnchor, constant: 6),
            backgroundContentView.trailingAnchor.constraint(equalTo: backgroundBorderView.trailingAnchor, constant: -6),
            backgroundContentView.bottomAnchor.constraint(equalTo: backgroundBorderView.bottomAnchor, constant: -6),
        ])
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [infoLabel, replyLabel])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.distribution = .fillProportionally
        //imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .center
        imageCaptionStack.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        separatorView.backgroundColor = .commColor // 구분선의 색상 설정
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true // 구분선의 높이 설정
        
        
        
        let stack = UIStackView(arrangedSubviews: [separatorView, captionLabel]) // 구분선을 stack에 추가
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        
        //
        //       let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        //       stack.axis = .vertical
        //       stack.distribution = .fillProportionally
        //       stack.spacing = 8
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundContentView.addSubview(imageCaptionStack)
        backgroundContentView.addSubview(stack) // 다른 요소들을 백그라운드 뷰 위에 추가
        backgroundContentView.addSubview(profileImageView) // 다른 요소들을 백그라운드 뷰 위에 추가
        
        
        
        // 버튼과의 구분선
        let separatorView2 = UIView()
        separatorView2.backgroundColor = .commColor // 구분선의 색상 설정
        separatorView2.heightAnchor.constraint(equalToConstant: 1).isActive = true // 구분선의 높이
        separatorView2.translatesAutoresizingMaskIntoConstraints = false
        backgroundContentView.addSubview(separatorView2)
        
        NSLayoutConstraint.activate([
            // 스택뷰에 감쌓은 요소 하나를 우측으로 밀어, 빈 공간에 프로필 사진 넣어서 오토레이아웃 충돌 문제를 해결

            imageCaptionStack.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 7),
            imageCaptionStack.leadingAnchor.constraint(equalTo: backgroundContentView.leadingAnchor, constant: 43),
            // imageCaptionStack의 높이 제약 조건 추가
            imageCaptionStack.heightAnchor.constraint(equalToConstant: 40),

            
            
            profileImageView.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 13),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            
            
            stack.topAnchor.constraint(equalTo: imageCaptionStack.bottomAnchor, constant: 3),
            stack.bottomAnchor.constraint(equalTo: backgroundContentView.bottomAnchor, constant: -35),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            //세로크기를 100
            
//            separatorView2.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 3), // stack 바로 아래에 위치하도록 설정
//            separatorView2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
//            separatorView2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
//          
        ])
        
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
    
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.spacing = 72
        
        backgroundContentView.addSubview(actionStack)
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        backgroundContentView.addSubview(underlineView)
        
        // 사용자 프로필 이동
        configureMentionHandler()
        
        NSLayoutConstraint.activate([
            
            actionStack.centerXAnchor.constraint(equalTo: backgroundContentView.centerXAnchor),
            actionStack.bottomAnchor.constraint(equalTo: backgroundContentView.bottomAnchor, constant: -10), // 원하는 간격 설정
            
            
            
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped(){
        print("DEBUG: Profile Image Tapped in cell ..")
        delegate?.handelProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped(){
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleRetweetTapped(){
        
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped(){
        
    }
    
    
    
    
    
    // MARK: - Helpers
    
    func configure() {
        // print("DEBUG: Did set tweet in cell..")
        guard let diary = diary else {return}
        let viewModel = DiaryViewModel(diary: diary)
        
        
        captionLabel.text = diary.caption
        //print("DEBUG: Tweet user is \(tweet.user.username)")// 해당 트윗을 남긴 사용자의 이름 출력
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
    }
    
    
    // 모든 버튼의 설정값이 동일하기 때문에 코드를 줄이기 위한 리팩토링 작업을 할 것임
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { [weak self] username in
            print("사용자의 프로필로 이동 \(username)")
            self?.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
}

