//
//  DiaryVIewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//

import UIKit
import FSCalendar

class DiaryViewController: UIViewController{
    
    
    // MARK: - Properties
    
//    let scrollView: UIScrollView = {
//      let scrollView = UIScrollView()
//      scrollView.translatesAutoresizingMaskIntoConstraints = false
//      return scrollView
//    }()
    
    var user: User?
    { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            //configureLeftBarButton() // 해당 함수가 호출 될때는 사용자가 존재한다는 것을 알수 있음
            print("DiaryViewController : \(user?.email)")
        }
    }
    
    private var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.scrollDirection = .horizontal
        return calendarView
    }()
    
    let formatter = DateFormatter()
    var selectDate: String = "" // didset 사용해서 화면 새로고침해서 일기 목록 뿌려주기
    
    private lazy var writeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1 // 보더의 넓이 설정
        button.layer.borderColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 보더 컬러 설정
        button.setTitle("일기쓰기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleWriteTapped), for: .touchUpInside)
        return button
    }()



    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 즉, 사용자가 화면을 아래로 스크롤하면 (스와이프하면) 네비게이션 바가 자동으로 사라지고, 다시 위로 스크롤하면 (스와이프하면) 네비게이션 바가 다시 나타납니다.
        navigationController?.hidesBarsOnSwipe = true

        // UIScrollView의 delegate 설정
        //ScrollView.delegate = self // 여기서 "yourScrollView"는 스크롤뷰의 변수명입니다. 스토리보드에서 스크롤 뷰와 연결해야 합니다.
        
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        setupFSCalendar()
        setupAutoLayout()
        configureLeftBarButton()
        
        let currentDate = Date()  // 현재 날짜 가져오기
            formatter.dateFormat = "yyyy-MM-dd"
            selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
    }



    // MARK: - Helpers
    private func setupFSCalendar(){
        
        calendarView.backgroundColor = .white // 배경색
        // calendar locale > 한국으로 설정
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    
    @objc func handleWriteTapped(){
        print("handleWriteTapped")
        //guard let user = user else {return}
        let controller = WriteDiaryController(user: user!, userSelectDate: selectDate, config: .diary)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    private func setupAutoLayout() {
        
//        view.addSubview(scrollView)
//        scrollView.addSubview(calendarView)
//        let contentHeight = CGFloat(280) // Adjust this value as needed
//            let contentWidth = UIScreen.main.bounds.width // Use the width of the screen or adjust as needed
//        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        view.addSubview(calendarView)
        view.addSubview(writeButton)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        writeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Safe Area 제약 조건 설정
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            calendarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            //세로크기를 100
            calendarView.heightAnchor.constraint(equalToConstant: 380),
            
    
            writeButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 2),
            writeButton.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 2),
            writeButton.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -2),
            writeButton.heightAnchor.constraint(equalToConstant: 30),
            //writeButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 2),
            
    
        ])
        
    }
    
    func configureLeftBarButton(){
        //guard let user = user else {return}
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = .blue
        //profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        // 피드에서 자신의 프로파일 이미지 누를시 사용자 프로필로 이동
//        profileImageView.isUserInteractionEnabled = true // 이미지 뷰는 기본으로 false로 설정이라 해줘야함 터치 인식 가능하게
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
//                profileImageView.addGestureRecognizer(tap)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
}

extension DiaryViewController: UIScrollViewDelegate{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard velocity.y != 0 else { return }
            if velocity.y < 0 {
                let height = self?.tabBarController?.tabBar.frame.height ?? 0.0
                self?.tabBarController?.tabBar.alpha = 1.0
                self?.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - height)
            } else {
                self?.tabBarController?.tabBar.alpha = 0.0
                self?.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
            }
        }
    }
}

extension DiaryViewController: FSCalendarDelegate, FSCalendarDataSource {
    // 모든 날짜의 채워진 색상 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return UIColor.white
    }
    
    // 날짜 선택 시 콜백 메소드
       func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
           formatter.dateFormat = "yyyy-MM-dd"
           print(formatter.string(from: date) + " 선택됨")
           
           /* 유저가 날짜 선택시 날짜 정보에 따라서 현제 화면에 일기 트윗 보여줘야함
             일기 쓰기 클릭시 날짜와, 유저정보를 던지고 거기서 일기 처리 하기
             돌아오면 현제 날짜에 맞춰서 트윗 뿌리기
           */
           self.selectDate = formatter.string(from: date)
           
       }
}
