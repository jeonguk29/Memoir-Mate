//
//  CommunityDiarySelectController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/10/06.
//

//
//  WriteDiaryController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//

import UIKit
import SDWebImage



protocol CommunityDiarySelectControllerDelegate: class {
    func didTaphandleCancel()
}

class CommunityDiarySelectController: UIViewController{
    
    private var user: User 
    private let config: UploadDiaryConfiguration
    private var userSelectDate: String
    private var userSelectstate: DiaryType
    private var userSelectDiary: Diary?
    
    weak var delegate: CommunityDiarySelectControllerDelegate?
    
    // 1. CommentFeedViewController의 인스턴스 생성
    var commentFeedVC = CommentFeedViewController(collectionViewLayout: UICollectionViewFlowLayout())


    

    private lazy var captionTextView: InputTextView = {
        let textView = InputTextView()
           textView.textType = .community
           return textView
       }()
    
    
    
    private let scrollView: UIScrollView = {
          let scrollView = UIScrollView()
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          return scrollView
      }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "delete.backward"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()

    
    
    
    private lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .darkGray
        button.backgroundColor = .white
        button.setDimensions(width: 42, height: 42)
        button.layer.cornerRadius = 42 / 2
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 1
        button.clipsToBounds = false
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
  
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()

    
    
    
    // MARK: - Lifecycle
    
    init(user: User, userSelectDate: String, config: UploadDiaryConfiguration, userSelectstate : DiaryType, userSelectDiary: Diary?) {
        self.user = user
        self.commentFeedVC.user = user // commentFeedVC의 user 프로퍼티에 값을 할당
        self.userSelectDate = userSelectDate
        self.config = config
        self.userSelectstate = userSelectstate
        self.userSelectDiary = userSelectDiary
    
        super.init(nibName: nil, bundle: nil)
    }   // 사용자 이미지를 가져오기 위해 불필요한 API 요청 할필요가 없음 이전화면에서 이미 사용자 데이터를 호출해 불러왔으니까 받기만 하면 되는 것임
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    
    // MARK: - Selectors
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
        if userSelectstate == .Update {
            delegate?.didTaphandleCancel()
        }
    }
    
    @objc func handleProfileImageTapped(){
        print("DEBUG: Profile Image Tapped in cell ..")
       
    }
    
    @objc func handleCommentTapped(){
        
    
        // 2. 모달로 화면 표시
        commentFeedVC.modalPresentationStyle = .pageSheet // 원하는 스타일로 설정하세요
            present(commentFeedVC, animated: true, completion: nil)
        
        commentFeedVC.selectDiary = userSelectDiary
     
    }
    
    @objc func handleRetweetTapped(){
        print()
    }
    
    @objc func handleLikeTapped(){
        print()
    }
    
    @objc func handleShareTapped(){
        print()
    }

    

    
    // MARK: - API
    
    
    
    // MARK: - Helpers
    
    func configureUI(){
        
        view.backgroundColor = .white

//        view.addSubview(scrollView)
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
        
        
        if userSelectstate == .Update {
             if let userSelectDiary {
                 DispatchQueue.main.async {
                     self.captionTextView.text = userSelectDiary.caption
                     self.captionTextView.placeholderLabel.isHidden = true
                 }
             }
         }
        
        
        // Scroll View의 ContentView 설정
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // ContentView의 높이를 지정 (여기에서는 임의의 값으로 설정하고 필요에 따라 조절)
        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        
        
        //scrollView.addSubview(contentView)
        // 나머지 UI 요소들을 ContentView에 추가
        
        contentView.addSubview(captionTextView)
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        configureNavigationBar()
        
        contentView.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        
        
       
       
        // 삭제 예정 11월 25일
        // 액션 버튼과의 구분선
//        let separatorView = UIView()
//        separatorView.backgroundColor = .gray // 구분선의 색상 설정
//        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true // 구분선의 높이
//        separatorView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(separatorView)
        
        
 
        NSLayoutConstraint.activate([
            
            captionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            captionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            captionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            commentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            commentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
            
            // 삭제 예정 11월 25일
//            separatorView.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 1),
//            separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
//        ])
        

//        let actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
//        actionStack.translatesAutoresizingMaskIntoConstraints = false
//        actionStack.axis = .horizontal
//        actionStack.spacing = 72
//        contentView.addSubview(actionStack)
//
//        NSLayoutConstraint.activate([
//            actionStack.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
//            actionStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            actionStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//
//            
//        ])
    }
    
    func configureNavigationBar(){
        //        navigationController?.navigationBar.barTintColor = .white // Navigation bar의 배경색을 흰색으로 지정하는 코드입니다.
        //        navigationController?.navigationBar.isTranslucent = false // Navigation Bar를 투명하지 않게 만드는 코드입니다.
        //
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
          navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: cancelButton)]
          
        
        
        

    }
    
    // 모든 버튼의 설정값이 동일하기 때문에 코드를 줄이기 위한 리팩토링 작업을 할 것임
      func createButton(withImageName imageName: String) -> UIButton {
          let button = UIButton(type: .system)
          button.setImage(UIImage(named: imageName), for: .normal)
          button.tintColor = .darkGray
          //button.setDimensions(width: 20, height: 20)
          button.imageView?.contentMode = .scaleAspectFit // 이미지 뷰의 contentMode 설정
          return button
      }
  }

