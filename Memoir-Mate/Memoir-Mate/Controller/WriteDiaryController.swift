//
//  WriteDiaryController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//

import UIKit
import SDWebImage

class WriteDiaryController: UIViewController{
    
    private var user: User{ // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            print("\(user.email)")
        }
    }
    private let config: UploadDiaryConfiguration
    
    private var userSelectDate: String
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainColor
        button.setTitle("작성", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        //addTarget을 설정할 경우 lazy var로 만들어야함
        button.addTarget(self, action: #selector(handleUploadDiary), for: .touchUpInside)
        return button
    }()
    
    
    private let captionTextView = InputTextView() // 하위 클래스를 만들어 코드를 분리 시켰음
    
    // MARK: - Lifecycle
    
    init(user: User, userSelectDate: String, config: UploadDiaryConfiguration) {
        self.user = user
        self.userSelectDate = userSelectDate
        self.config = config
        print("WriteDiaryController : \(self.user.email)")
        print("WriteDiaryController : \(self.userSelectDate)")
        
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
    }
    
    @objc func handleUploadDiary() {
        //print("업로드 트윗")
        guard let caption = captionTextView.text else {return}
        DiaryService.shared.uploadDiary(userSelectDate: userSelectDate, caption: caption, type: config) { (error, ref)in
                       if let error = error {
                           print("DEBUG: 일기 업로드에 실패했습니다. error\(error.localizedDescription)")
                           return
                       }
        
                       self.dismiss(animated: true, completion: nil)
                   }
    }
    
    
    // MARK: - API
    
    
    
    // MARK: - Helpers
    
    func configureUI(){
        view.backgroundColor = .white
        configureNavigationBar()
        
        
        //           view.addSubview(ProfileImageView)
        //           ProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(captionTextView)
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            captionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            captionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            
        ])
        
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        
    }
}

