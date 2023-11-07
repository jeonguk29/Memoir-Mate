import UIKit
import ActiveLabel

// 프로토콜을 만들어서 현제 내 트윗셀을 내 컨트롤러로 전달할 것임
protocol DiaryCellDelegate: class {
    func handelProfileImageTapped(_ cell: DiaryCell) // 컨트롤러에게 위임할 작업을 명시
    func handleFetchUser(withUsername username: String) // 사용자 이름에 대하여 uid를 가져오는 메서드
    func handleLongPress(_ cell: DiaryCell) // 셀을 길게 눌렀을 때 호출될 메서드
}

class DiaryCell:UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "DiaryCell" // 재사용 식별자 정의
    
    // 데이터를 가져오기 전일수도 있기때문에 옵셔널로 선언
    var diary: Diary? {
        didSet { configure() }
    }
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    weak var delegate: DiaryCellDelegate?
    
    var originalFrame: CGRect? // 셀의 원래 프레임을 저장하기 위한 속성
    
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
    
    
    // 백그라운드 뷰
   lazy var backgroundBorderView: UIView = {
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
         
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [infoLabel, replyLabel])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.distribution = .fillProportionally
        //imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .center
        imageCaptionStack.heightAnchor.constraint(equalToConstant:35).isActive = true

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

            stack.topAnchor.constraint(equalTo: backgroundContentView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: backgroundContentView.bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            //세로크기를 100

        ])

        
       infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        
        // 셀 꾹 눌렸을때
        // 아래 코드를 추가하여 셀에 UILongPressGestureRecognizer를 추가합니다.
        // UILongPressGestureRecognizer를 추가하고 target을 self로 설정
           longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
           longPressGestureRecognizer.minimumPressDuration = 1.5 // 2초 동안 누를 때 동작
           addGestureRecognizer(longPressGestureRecognizer)
    
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped(){
        print("DEBUG: Profile Image Tapped in cell ..")
        delegate?.handelProfileImageTapped(self)
    }
    

    // 아래 메서드를 추가하여 UILongPressGestureRecognizer를 처리합니다.
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            delegate?.handleLongPress(self)
        }
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

