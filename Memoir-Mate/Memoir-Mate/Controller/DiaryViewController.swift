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
    
    let scrollView: UIScrollView = {
      let scrollView = UIScrollView()
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      return scrollView
    }()
    
    private var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.scrollDirection = .horizontal
        return calendarView
    }()
    
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

        navigationController?.hidesBarsOnSwipe = true
//        view.backgroundColor = .red
        
        // UIScrollView의 delegate 설정
        //ScrollView.delegate = self // 여기서 "yourScrollView"는 스크롤뷰의 변수명입니다. 스토리보드에서 스크롤 뷰와 연결해야 합니다.
        
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        setupFSCalendar()
        setupAutoLayout()
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
        let controller = WriteDiaryController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    private func setupAutoLayout() {
        
//        view.addSubview(scrollView)
//
//        scrollView.addSubview(calendarView)
//
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
            
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
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
}
