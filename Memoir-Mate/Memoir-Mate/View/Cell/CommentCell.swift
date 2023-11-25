//
//  commentCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/10/14.
//

import UIKit
import ActiveLabel

// 프로토콜을 만들어서 현제 내 트윗셀을 내 컨트롤러로 전달할 것임
protocol commentCellDelegate: class {
    func handelProfileImageTapped(_ cell: CommentCell) // 컨트롤러에게 위임할 작업을 명시
    func handleReplyTapped(_ cell: CommentCell)
    func handleLikeTapped(_ cell: CommentCell) // 트윗 좋아요 동작처리를 위임할 메서드
    func handleFetchUser(withUsername username: String) // 사용자 이름에 대하여 uid를 가져오는 메서드
}

class CommentCell:UICollectionViewCell {
    
    
    // MARK: - Properties
    
    // 데이터를 가져오기 전일수도 있기때문에 옵셔널로 선언
    var comment: Diary? {
        didSet { configure() }
    }
    
    weak var delegate: commentCellDelegate?
    
    static let reuseIdentifier = "CommentCell" // 재사용 식별자 정의
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 32, height: 32)
        iv.layer.cornerRadius = 32/2
        iv.backgroundColor = .commColor
        
        // 버튼이 아닌 view 객체를 탭 이벤트 처리하는 방법 : 사용자 프로필 작업하기
        // lazy var로 profileImageView를 수정해야함 아래 함수가 만들어지기 전에 인스턴스를 찍을 수 있어서
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0 // 여러줄 표시 가능 하게
        label.text = "Test caption"
        label.mentionColor = .commColor
        label.hashtagColor = .commColor
        return label
    }()
    
    private let userNickNameLabel = UILabel()
    
    
    private lazy var backgroundContentView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white.withAlphaComponent(0.7) // 투명도를 조절하여 원하는 값으로 설정
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let declarationButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray5
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.addTarget(self, action: #selector(declarationButtonTapped), for: .touchUpInside)
        return button
    }()
    

     
     // MARK: - Lifecycle
     override init(frame:CGRect) {
         super.init(frame: frame)
         
         addSubview(backgroundContentView) // 백그라운드 뷰를 가장 처음에 추가
         backgroundContentView.translatesAutoresizingMaskIntoConstraints = false
         
         
         
         NSLayoutConstraint.activate([
             backgroundContentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
             backgroundContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
             backgroundContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
             backgroundContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
             
         ])
         
         profileImageView.translatesAutoresizingMaskIntoConstraints = false
         userNickNameLabel.translatesAutoresizingMaskIntoConstraints = false
         //replyLabel.translatesAutoresizingMaskIntoConstraints = false
         captionLabel.translatesAutoresizingMaskIntoConstraints = false
         
         
         let profileStack = UIStackView(arrangedSubviews: [profileImageView, userNickNameLabel, replyLabel])
         profileStack.distribution = .fillProportionally
         //imageCaptionStack.distribution = .fillProportionally
         profileStack.spacing = 12
         profileStack.alignment = .center
         profileStack.translatesAutoresizingMaskIntoConstraints = false
         
    
         
         let stack = UIStackView(arrangedSubviews: [profileStack, captionLabel]) // 구분선을 stack에 추가
         stack.axis = .vertical
         stack.distribution = .fillProportionally
         stack.spacing = 1
         
         backgroundContentView.addSubview(stack) // 다른 요소들을 백그라운드 뷰 위에 추가
         stack.translatesAutoresizingMaskIntoConstraints = false
      
         backgroundContentView.addSubview(declarationButton)
         declarationButton.translatesAutoresizingMaskIntoConstraints = false
         
         
         NSLayoutConstraint.activate([
            
            stack.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 1),
            stack.leadingAnchor.constraint(equalTo: backgroundContentView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: backgroundContentView.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: backgroundContentView.bottomAnchor, constant: -10),
            
      
            declarationButton.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 18),
            declarationButton.trailingAnchor.constraint(equalTo: backgroundContentView.trailingAnchor, constant: -20),
            
         ])
         
         
        userNickNameLabel.font = UIFont.systemFont(ofSize: 14)
   
         // 사용자 프로필 이동
         configureMentionHandler()
         
         
         
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
    
    @objc func declarationButtonTapped() {
        
    }
    
    
    // MARK: - Helpers
    
    func configure() {
        // print("DEBUG: Did set tweet in cell..")
        guard let comment = comment else {return}
        let viewModel = DiaryViewModel(diary: comment)
        
        
        captionLabel.text = comment.caption
        //print("DEBUG: Tweet user is \(tweet.user.username)")// 해당 트윗을 남긴 사용자의 이름 출력
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        //userNickNameLabel.text = viewModel.user.userNickName
        userNickNameLabel.attributedText = viewModel.userInfoText
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
