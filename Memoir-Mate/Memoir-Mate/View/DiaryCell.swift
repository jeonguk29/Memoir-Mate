//
//  DiaryCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/18.
//

import UIKit
import ActiveLabel

// 프로토콜을 만들어서 현제 내 트윗셀을 내 컨트롤러로 전달할 것임
protocol DiaryCellDelegate: class {
    func handelProfileImageTapped(_ cell: DiaryCell) // 컨트롤러에게 위임할 작업을 명시
    func handleReplyTapped(_ cell: DiaryCell)
    func handleLikeTapped(_ cell: DiaryCell) // 트윗 좋아요 동작처리를 위임할 메서드
    func handleFetchUser(withUsername username: String) // 사용자 이름에 대하여 uid를 가져오는 메서드
}



class DiaryCell:UICollectionViewCell {
    
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DiaryCell" // 재사용 식별자 정의
    

    // 데이터를 가져오기 전일수도 있기때문에 옵셔널로 선언
    var diary: Diary? {
        didSet { configure() }
    }
    
    weak var delegate: DiaryCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 34, height: 34)
        iv.layer.cornerRadius = 34/2
        iv.backgroundColor = .mainColor

        // 버튼이 아닌 view 객체를 탭 이벤트 처리하는 방법 : 사용자 프로필 작업하기
        // lazy var로 profileImageView를 수정해야함 아래 함수가 만들어지기 전에 인스턴스를 찍을 수 있어서
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true

        // 프로필 이미지의 Auto Layout 설정
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 34).isActive = true // 너비 제약 조건 추가
        iv.heightAnchor.constraint(equalToConstant: 34).isActive = true // 높이 제약 조건 추가

        return iv
    }()
    
    // 누구에게 답글 남기는지 표시하기 위한 라벨
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .mainColor
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont(name: "NanumMuGungHwa", size: 25)
        label.numberOfLines = 0 // 여러줄 표시 가능 하게
        label.text = "Test caption"
        label.mentionColor = .mainColor
        label.hashtagColor = .mainColor
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
    private lazy var backgroundContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor // 원하는 배경색상으로 변경
        view.layer.cornerRadius = 20 // 원하는 값을 지정하여 둥글게 만듭니다.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()

    // 백그라운드 뷰
    private lazy var backgroundContentView2: UIView = {
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

        // 삭제 버튼을 셀에 추가하고 Auto Layout을 설정
//        addSubview(deleteButton)
//        NSLayoutConstraint.activate([
//            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor), // 세로 중앙 정렬
//            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8), // 오른쪽으로 여백을 줌
//            deleteButton.widthAnchor.constraint(equalToConstant: 30),
//            deleteButton.heightAnchor.constraint(equalToConstant: 30)
//        ])
//        
        addSubview(backgroundContentView) // 백그라운드 뷰를 가장 처음에 추가
        backgroundContentView.translatesAutoresizingMaskIntoConstraints = false
           
        backgroundContentView.addSubview(backgroundContentView2)
        backgroundContentView2.translatesAutoresizingMaskIntoConstraints = false
           
        
        NSLayoutConstraint.activate([
            backgroundContentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
             backgroundContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
             backgroundContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
             backgroundContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
          
            backgroundContentView2.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 6),
          backgroundContentView2.leadingAnchor.constraint(equalTo: backgroundContentView.leadingAnchor, constant: 6),
          backgroundContentView2.trailingAnchor.constraint(equalTo: backgroundContentView.trailingAnchor, constant: -6),
          backgroundContentView2.bottomAnchor.constraint(equalTo: backgroundContentView.bottomAnchor, constant: -6),
        ])
         
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, infoLabel, replyLabel])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.distribution = .fillProportionally
        //imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .center
        
        let separatorView = UIView()
        separatorView.backgroundColor = .mainColor // 구분선의 색상 설정
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true // 구분선의 높이 설정

        let stack = UIStackView(arrangedSubviews: [imageCaptionStack, separatorView, captionLabel]) // 구분선을 stack에 추가
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
      
//
//       let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
//       stack.axis = .vertical
//       stack.distribution = .fillProportionally
//       stack.spacing = 8
       
       stack.translatesAutoresizingMaskIntoConstraints = false
        
    backgroundContentView.addSubview(stack) // 다른 요소들을 백그라운드 뷰 위에 추가
        

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(equalTo: backgroundContentView2.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: backgroundContentView2.bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            //세로크기를 100

        ])

        
       infoLabel.font = UIFont.systemFont(ofSize: 14)
    
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
    
//    @objc func deleteButtonTapped() {
//        // 삭제 버튼 클릭 시 호출되는 메서드
//        // 이 부분에서 해당 일기를 삭제하는 코드를 작성하세요.
//        // indexPath를 사용하여 어떤 일기를 삭제할지 결정할 수 있습니다.
//        // 삭제가 완료되면 데이터를 업데이트하고 컬렉션 뷰를 새로고침해야 합니다.
//    }
    
 
    
    
    
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
        
//        // 여기에서 deleteButton의 가시성을 설정하거나 숨깁니다.
//        if viewModel.shouldShowDeleteButton {
//            showDeleteButton()
//        } else {
//            hideDeleteButton()
//        }
    }
    
//    // 삭제 버튼을 표시하는 메서드
//    func showDeleteButton() {
//        backgroundContentView2.addSubview(deleteButton)
//        deleteButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            deleteButton.topAnchor.constraint(equalTo: backgroundContentView2.topAnchor, constant: 6),
//            deleteButton.trailingAnchor.constraint(equalTo: backgroundContentView2.trailingAnchor, constant: -6),
//            deleteButton.widthAnchor.constraint(equalToConstant: 20),
//            deleteButton.heightAnchor.constraint(equalToConstant: 20),
//        ])
//    }
//    
//    // 삭제 버튼을 숨기는 메서드
//    func hideDeleteButton() {
//        // 삭제 버튼이 이미 표시되어 있다면 제거합니다.
//        deleteButton.removeFromSuperview()
//    }
//    
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

