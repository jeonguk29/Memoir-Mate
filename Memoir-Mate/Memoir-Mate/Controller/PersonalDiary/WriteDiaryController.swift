//
//  WriteDiaryController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//

import UIKit
import SDWebImage

enum DiaryType: String { // 어떤 종류의 알림인지 숫자로 파악하기 위함
    case Write
    case Update
}

protocol WriteDiaryControllerDelegate: class {
    func didTaphandleCancel()
    func didTaphandleUpdate()
}

class WriteDiaryController: UIViewController{
    
    private var user: User{ // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            print("\(user.email)")
        }
    }
    private let config: UploadDiaryConfiguration
    private var userSelectDate: String
    private var userSelectstate: DiaryType
    private var userSelectDiary: Diary?
    
    weak var delegate: WriteDiaryControllerDelegate?
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainColor
        if userSelectstate == .Write {
            button.setTitle("작성", for: .normal)
        }else{
            button.setTitle("수정", for: .normal)
        }
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        //addTarget을 설정할 경우 lazy var로 만들어야함
        if userSelectstate == .Write {
            button.addTarget(self, action: #selector(handleUploadDiary), for: .touchUpInside)
        }else{
            button.addTarget(self, action: #selector(handleUpdateDiary), for: .touchUpInside)
        }
      
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "delete.backward"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()

    
    private lazy var dleleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.tintColor = .gray
        //button.backgroundColor = .red
//        button.setTitle("삭제", for: .normal)
//        button.titleLabel?.textAlignment = .center
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //button.setTitleColor(.white, for: .normal)
        
//        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
//        button.layer.cornerRadius = 32 / 2
        
        //addTarget을 설정할 경우 lazy var로 만들어야함
        if userSelectstate == .Write {
            button.isHidden = true
        }else{
            button.addTarget(self, action: #selector(handleDeleteDiary), for: .touchUpInside)
        }
      
        return button
    }()
    
    
    
    private lazy var captionTextView: InputTextView = {
        let textView = InputTextView()
        textView.textType = .personal
           return textView
       }()
    
    // MARK: - Lifecycle
    
    init(user: User, userSelectDate: String, config: UploadDiaryConfiguration, userSelectstate : DiaryType, userSelectDiary: Diary?) {
        self.user = user
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
        
        // 키보드 표시 및 숨김 관찰자 등록
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    // MARK: - Selectors
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
        if userSelectstate == .Update {
            delegate?.didTaphandleCancel()
        }
    }
    
    @objc func handleUploadDiary() {
        guard let caption = captionTextView.text else { return }
        
        // 메인 스레드에서 실행되도록 DispatchQueue를 사용
        DispatchQueue.main.async {
            DiaryService.shared.uploadDiary(userSelectDate: self.userSelectDate, caption: caption, type: self.config) { (error, ref) in
                if let error = error {
                    print("DEBUG: 일기 업로드에 실패했습니다. error \(error.localizedDescription)")
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleDeleteDiary() {
        let alertController = UIAlertController(title: "일기 삭제", message: "정말로 이 일기를 삭제하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            // 사용자가 확인을 선택한 경우에만 다이어리 삭제
            DispatchQueue.main.async {
                DiaryService.shared.deleteDiary(diary: self.userSelectDiary) { (error, ref) in
                    if let error = error {
                        print("DEBUG: 일기 삭제에 실패했습니다. error \(error.localizedDescription)")
                        return
                    }
                    
                    self.delegate?.didTaphandleUpdate()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }

    

    @objc func handleUpdateDiary() {
        guard let caption = captionTextView.text else { return }
        
        // 메인 스레드에서 실행되도록 DispatchQueue를 사용
        DispatchQueue.main.async {
            DiaryService.shared.updateDiary(diary: self.userSelectDiary, userSelectDate: self.userSelectDate, caption: caption) { (error, ref) in
                if let error = error {
                    print("DEBUG: 일기 업데이트에 실패했습니다. error \(error.localizedDescription)")
                    return
                }
                self.delegate?.didTaphandleUpdate()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    
    // MARK: - API
    
    
    
    // MARK: - Helpers
    
    func configureUI() {
        if userSelectstate == .Update {
            if let userSelectDiary = userSelectDiary { // 수정 모드에서 텍스트 불러오기
                captionTextView.text = userSelectDiary.caption
                captionTextView.handleTextInputChange() // 수동으로 텍스트 뷰 업데이트
            }
        }
        
        view.backgroundColor = .white
        configureNavigationBar()
        
        view.addSubview(captionTextView)
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // captionTextView 화면에 꽉 채우기
        NSLayoutConstraint.activate([
            captionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            captionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            captionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        
      
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: cancelButton)]
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        // 네비게이션 바 오른쪽에 추가 버튼 (actionButton)과 (dleleteButton) 추가
        let customButton2 =  UIBarButtonItem(customView: dleleteButton)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: actionButton), customButton2]
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // 키보드 높이 가져오기
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 텍스트 뷰의 스크롤을 키보드 높이만큼 조절
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            captionTextView.contentInset = contentInset
            captionTextView.scrollIndicatorInsets = contentInset
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // 키보드 숨김 시 텍스트 뷰의 스크롤을 초기화
        let contentInset = UIEdgeInsets.zero
        captionTextView.contentInset = contentInset
        captionTextView.scrollIndicatorInsets = contentInset
    }
}

