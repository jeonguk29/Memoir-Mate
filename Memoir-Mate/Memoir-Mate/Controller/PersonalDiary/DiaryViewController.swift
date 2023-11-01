//
//  DiaryVIewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//

import UIKit
import FSCalendar
import AVKit



private let reuseIdentifier = "DiaryCell"

class DiaryViewController: UICollectionViewController{
    
    
    // MARK: - Properties
    
    
    var user: User?
    { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            configureLeftBarButton() // 해당 함수가 호출 될때는 사용자가 존재한다는 것을 알수 있음
            print("DiaryViewController : \(user?.email)")
        }
    }
    
    private var diarys = [Diary]() {
        didSet {collectionView.reloadData()}
    }
    
    private var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.scrollDirection = .horizontal
        //calendarView.appearance.selectionColor = .clear
        return calendarView
    }()
    
    let formatter = DateFormatter()
    var selectDate: String = "" // didset 사용해서 화면 새로고침해서 일기 목록 뿌려주기
    
    // 날짜를 키로 하고 다이어리 항목이 있는지 여부를 값으로 하는 딕셔너리를 저장할 변수
    private var diaryData: [String: Bool] = [:]
    
    var isNavigationBarHidden = false
    var calendarHidden = false
    

    private lazy var writeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        //button.backgroundColor = .mainColor
        //button.setTitle("일기쓰기", for: .normal)

//        button.titleLabel?.textAlignment = .center
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        button.setTitleColor(.white, for: .normal)
//        
//        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
//        button.layer.cornerRadius = 32 / 2

        button.addTarget(self, action: #selector(handleWriteTapped), for: .touchUpInside)
    
      
        return button
    }()
    
   
    
//    private lazy var closeCalendarButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.backgroundColor = .white
//        button.layer.cornerRadius = 5
//        button.layer.borderWidth = 1 // 보더의 넓이 설정
//        button.layer.borderColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 보더 컬러 설정
//        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
//
//        if let roseOfSharonFont = UIFont(name: "Rose-of-Sharon", size: 16) {
//            button.titleLabel?.font = roseOfSharonFont
//        } else {
//            print("폰트 적용 안됨")
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        }
//        button.setTitleColor(.black, for: .normal)
//
//        button.addTarget(self, action: #selector(closeCalendarTapped), for: .touchUpInside)
//        return button
//    }()
    
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar.circle"), for: .normal)
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(closeCalendarTapped), for: .touchUpInside)
        
          
        return button
    }()

    
    private var selectedCell: DiaryCell? // 선택된 셀을 추적하기 위한 속성 추가
    private var isCellCentered = false // 셀이 화면 중앙에 있는지 여부를 추적하기 위한 속성 추가
    // 새로운 인스턴스 변수 overlayView를 추가
    private var overlayView: UIView?
    var originalCellFrame: CGRect?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 즉, 사용자가 화면을 아래로 스크롤하면 (스와이프하면) 네비게이션 바가 자동으로 사라지고, 다시 위로 스크롤하면 (스와이프하면) 네비게이션 바가 다시 나타납니다.
        navigationController?.hidesBarsOnSwipe = true
        
        // UIScrollView의 delegate 설정
        //ScrollView.delegate = self // 여기서 "yourScrollView"는 스크롤뷰의 변수명입니다. 스토리보드에서 스크롤 뷰와 연결해야 합니다.
        
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
       
        // calendarView 둥글게
        calendarView.layer.masksToBounds = true
        calendarView.layer.cornerRadius = 20 // 원하는 라운드 값으로 설정
        calendarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // calendarView 보더라인 주기
        //calendarView.layer.borderWidth = 3.0

        // mainColor를 CGColor로 변환
        // mainColor를 UIColor로 정의
        let mainColor = UIColor.rgb(red: 71, green: 115, blue: 181)
        let mainCGColor = mainColor.cgColor
        // calendarView에 보더 라인 색상 설정
        //calendarView.layer.borderColor = mainCGColor
       
        
        // UIScrollView의 delegate를 설정합니다.
        collectionView.delegate = self
       
        collectionView.alwaysBounceVertical = true // 이 부분을 추가하면 스크롤이 항상 가능하게 됩니다. (cell 하나만 있어도 스크롤이 가능하게)
        
        setupFSCalendar()
        setupAutoLayout()
        //configureLeftBarButton()
        
        let currentDate = Date()  // 현재 날짜 가져오기
        formatter.dateFormat = "yyyy-MM-dd"
        selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
        
        fetchDiarys()
        fetchDiaryData()
        
        collectionView.register(DiaryCell.self, forCellWithReuseIdentifier:DiaryCell.reuseIdentifier) // DiaryCell 클래스와 식별자를 등록합니다.
        
        
    }
    
    
    
    // MARK: - Helpers
    private func setupFSCalendar(){
        
        calendarView.backgroundColor = .white // 배경색
        // calendar locale > 한국으로 설정
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    
    @objc func handleWriteTapped(){

        //guard let user = user else {return}
        print("DiaryViewController \(selectDate)")
        let controller = WriteDiaryController(user: user!, userSelectDate: selectDate, config: .diary, userSelectstate: .Write, userSelectDiary: nil)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    @objc func closeCalendarTapped(){
        if self.calendarHidden == true {
            calendarHidden = false
            calendarView.isHidden = true
         
        }
        else{
            calendarHidden = true
            calendarView.isHidden = false
           
        }
        
        // calendarHidden 상태가 변경될 때마다 셀을 다시 로드
        collectionView.performBatchUpdates(nil, completion: nil) // 달력 첫번째 셀의 위치를 조절 하기 위해
    }
    
    
    private func setupAutoLayout() {
        

        
        // 배경 이미지 설정
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundImageView
        
        
        view.addSubview(calendarView)
        view.addSubview(actionButton)
           
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
            
            
        // Safe Area 제약 조건 설정
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            calendarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,constant: -370),
            //세로크기를 100
            
            
        
            
            // ⭐️ 해당 한줄의 코드가 위 코드를 대체함
            // safeAreaLayoutGuide는 safeArea를 말함
            
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
            actionButton.widthAnchor.constraint(equalToConstant: 56),
            actionButton.heightAnchor.constraint(equalToConstant: 56),
                        
        ])
        //actionButton.layer.cornerRadius = 56/2 // 높이 나누기 2 하면 원형 모양이 됨
            
    
        
    }
    
    // 네비게이션바 버튼
    func configureLeftBarButton(){
        //guard let user = user else {return}
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user!.profileImageUrl, completed: nil)
        
        // 피드에서 자신의 프로파일 이미지 누를시 사용자 프로필로 이동
        //        profileImageView.isUserInteractionEnabled = true // 이미지 뷰는 기본으로 false로 설정이라 해줘야함 터치 인식 가능하게
        //
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        //                profileImageView.addGestureRecognizer(tap)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        // "일기쓰기" 버튼을 customButton으로 감싼 다음, 이 버튼을 네비게이션 바의 오른쪽 버튼으로 설정
        let customButton =  UIBarButtonItem(customView: writeButton)
        navigationItem.rightBarButtonItem = customButton

    }
    
  
    
    
    // MARK: - API
    func fetchDiarys() {
        DiaryService.shared.fatchDiarys { diarys in
            var selectdiarys = [Diary]() // 선택된 날짜의 일기를 담을 배열 생성
            
            for selectdiary in diarys {
                if selectdiary.userSelectDate == self.selectDate { // 오늘 날짜와 선택된 날짜가 같은 경우에만 추가
                    selectdiarys.append(selectdiary)
                }
            }
            
            // 날짜 순으로 트윗 정렬
            self.diarys = selectdiarys.sorted(by: { $0.timestamp > $1.timestamp })
            
            // 업데이트된 데이터를 반영하기 위해 collectionView를 업데이트
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // 다이어리 데이터를 가져와서 diaryData 딕셔너리를 채우는 함수
    private func fetchDiaryData() {
        DiaryService.shared.fatchDiarys { diarys in
            for selectdiary in diarys {
                // 해당 날짜에 다이어리 항목이 있는 경우 딕셔너리에 값을 true로 설정합니다.
                self.diaryData[selectdiary.userSelectDate] = true
            }
            // 업데이트된 데이터를 반영하기 위해 달력을 다시 로드합니다.
            DispatchQueue.main.async {
                self.calendarView.reloadData()
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
           fetchDiarys()
           
       }

    // 달력에서 날짜에 '*'를 추가할지 여부를 결정하는 함수
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let dateString = formatter.string(from: date)
        if let hasDiaryEntry = diaryData[dateString], hasDiaryEntry {
            return "*"
        }
        return nil
    }
}


// MARK: - UICollectionViewDelegate/DataSource

extension DiaryViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diarys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DiaryCell
        
  
        
        cell.delegate = self
        cell.diary = diarys[indexPath.row]
        
        
        // 셀에 대한 초기 설정
        // 애니메이션 적용
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
        }
        
        return cell
    }
    

  
    // 셀하나 선택시 일어나는 작업을 설정하는 메서드
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = WriteDiaryController(user: user!,
                                              userSelectDate: diarys[indexPath.row].userSelectDate,
                                              config: .diary,
                                              userSelectstate:.Update,
                                              userSelectDiary: diarys[indexPath.row])
        controller.delegate = self
        //navigationController?.pushViewController(controller, animated: true)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
        
    }

    
    
}
// MARK: - UICollectionViewDelegateFlowLayout
extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let diary = diarys[indexPath.row]
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        // 최대 높이를 400으로 제한
        let cellHeight = min(height + 170, 400)
           
        return CGSize(width: view.frame.width, height: cellHeight)
    }
    
    // 각 섹션의 여백을 지정 (달력 때문에 일기 안보임 현상을 방지)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 { // 첫 번째 섹션인 경우
            if self.calendarView.isHidden == true {
                // calendarHidden이 true인 경우 공백 제거
                return UIEdgeInsets.zero
            } else {
                // calendarHidden이 false인 경우 공백 추가
                return UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
            }
        } else {
            return UIEdgeInsets.zero // 나머지 섹션은 여백 없음
        }
    }
    
    
}


// MARK: - TweetCellDelegate
extension DiaryViewController: DiaryCellDelegate {
    
    // DiaryCellDelegate 메서드를 추가하여 셀을 길게 누를 때 호출됩니다.
    // 이 메서드에서 centerSelectedCell 메서드를 호출합니다.
    func handleLongPress(_ cell: DiaryCell) {
        print("셀 2초 눌림 ")
        selectedCell = cell
        centerSelectedCell()
        
        // 진동을 주는 코드
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
    }
    
    func centerSelectedCell() {
           guard let cell = selectedCell else { return }

           if !isCellCentered {
               let overlayView = UIView(frame: self.view.bounds)
               overlayView.alpha = 0.0
               self.view.addSubview(overlayView)
               
               // 기존 셀의 CGRect 값을 저장
                originalCellFrame = cell.frame


               // 비디오 파일 경로를 가져옵니다.
               if let videoPath = Bundle.main.path(forResource: "back3", ofType: "mp4") {
                   // AVPlayer 인스턴스를 생성합니다.
                   let player = AVPlayer(url: URL(fileURLWithPath: videoPath))

                   // AVPlayerViewController 인스턴스를 생성하고 AVPlayer를 할당합니다.
                   let playerController = AVPlayerViewController()
                   playerController.player = player

                   // AVPlayerViewController를 현재 뷰 컨트롤러에 추가합니다.
                   self.addChild(playerController)
                   playerController.view.frame = overlayView.bounds
                   overlayView.addSubview(playerController.view)
                   playerController.didMove(toParent: self)

                   // 비디오를 반복 재생합니다.
                   player.actionAtItemEnd = .none
                   NotificationCenter.default.addObserver(self, selector: #selector(playerDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

                   // 비디오 재생을 시작합니다.
                   player.play()
               }

               // 투명한 뷰를 생성하여 overlayView 위에 추가합니다.
               let transparentView = UIView(frame: overlayView.bounds)
               transparentView.backgroundColor = .clear
               overlayView.addSubview(transparentView)

               let closeButton = UIButton(type: .custom)
               closeButton.frame = overlayView.bounds
               closeButton.addTarget(self, action: #selector(closeOverlayView), for: .touchUpInside)
               overlayView.addSubview(closeButton)

               // 선택한 셀을 화면 중앙으로 이동시킵니다.
               cell.center = overlayView.center
               overlayView.addSubview(cell)
                
               
               
               // 공유 버튼
               // squareButton 크기 및 색상 수정
               lazy var squareButton: UIButton = {
                   let button = UIButton(type: .system)
                   let iconImage = UIImage(systemName: "square.and.arrow.up.fill")?.withRenderingMode(.alwaysTemplate)
                   button.setImage(iconImage, for: .normal)
                   
                   // 버튼 액션 추가
                   button.addTarget(self, action: #selector(squareButtonTapped(sharedCell:)), for: .touchUpInside)
                   
                   // 크기 및 색상 설정
                   button.backgroundColor = .mainColor // 빨간색 배경
                   button.tintColor = .white // 아이콘 색상
                   
                   // 아이콘 크기 조정 (예시로 30으로 설정)
                   let iconSize = CGSize(width: 50, height: 50)
                   button.imageEdgeInsets = UIEdgeInsets(top: (button.frame.height - iconSize.height) / 2,
                                                         left: (button.frame.width - iconSize.width) / 2,
                                                         bottom: (button.frame.height - iconSize.height) / 2,
                                                         right:(button.frame.width - iconSize.width) / 2)

                   
                   button.layer.cornerRadius = 25 // 반원 모양으로 보이도록 설정 (크기의 절반)

                   
                  return button
               }()

               overlayView.addSubview(squareButton)
               squareButton.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   squareButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                   squareButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -120),
                   squareButton.heightAnchor.constraint(equalToConstant: 50), // 세로 크기 100으로 설정
                   squareButton.widthAnchor.constraint(equalToConstant: 50),  // 가로 크기 100으로 설정
               ])

               
               UIView.animate(withDuration: 0.3) {
                   overlayView.alpha = 1.0
               }

               isCellCentered = true
               self.overlayView = overlayView
           }
       }
    
    @objc func squareButtonTapped(sharedCell:DiaryCell){
        
        guard let cell = selectedCell else { return }
        let alertController = UIAlertController(title: "일기 공유", message: "해당 일기를 공유하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        
        let shareAction = UIAlertAction(title: "공유", style: .cancel) { _ in
            DispatchQueue.main.async {
                DiaryService.shared.shareDiary(diary: cell.diary) { (error, ref) in
                    if let error = error {
                        print("DEBUG: 일기 공유에 실패했습니다. error \(error.localizedDescription)")
                        return
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    self.closeOverlayView()
                }
            }
        }
        
        // "취소" 버튼의 텍스트 색상을 빨간색으로 설정
//        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        // "공유" 버튼의 텍스트 색상을 파란색으로 설정
//        shareAction.setValue(UIColor.blue, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(shareAction)
        
        present(alertController, animated: true, completion: nil)
    }


    @objc func playerDidReachEnd(_ notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }

    // closeOverlayView 함수 수정
    @objc func closeOverlayView() {
        guard let overlayView = self.overlayView else { return }

        // AVPlayer 재생 중지
        for subview in overlayView.subviews {
            if let playerControllerView = subview as? AVPlayerViewController {
                playerControllerView.player?.pause()
                playerControllerView.view.removeFromSuperview()
            }
        }

        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0.0
        }) { _ in
            overlayView.removeFromSuperview()

            // 이미 화면 중앙에 있는 경우, 원래 위치로 이동
            if let cell = self.selectedCell, let originalFrame = self.originalCellFrame {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.frame = originalFrame
                }) { _ in
                    self.isCellCentered = false
                    self.collectionView.reloadData()
                }
            }
        }
    }

    
    func handelProfileImageTapped(_ cell: DiaryCell) {
        print("")
    }
    

    func handleFetchUser(withUsername username: String) {
      
    }
    
}



// MARK: - 스크롤 애니메이션 부분
// 스크롤 애니메이션 부분 수정
extension DiaryViewController {
    // scrollViewDidScroll(_:) 메서드를 구현하여 스크롤 이벤트를 처리합니다.
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y

        if yOffset > 0 {
            // 아래로 스크롤하는 중
            if !isNavigationBarHidden {
                isNavigationBarHidden = true
                UIView.animate(withDuration: 0.3) {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                    self.animateCalendarAndWriteButton(alpha: 0.0) // calendarView와 writeButton을 투명하게 처리
                }
            }
        } else {
            // 위로 스크롤하는 중
            if isNavigationBarHidden {
                isNavigationBarHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.animateCalendarAndWriteButton(alpha: 1.0) // calendarView와 writeButton을 나타나게 처리
                }
            }
        }
    }

    // calendarView와 writeButton의 alpha 값을 변경하는 메서드
    private func animateCalendarAndWriteButton(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.calendarView.alpha = alpha
        }
    }
}


extension DiaryViewController: WriteDiaryControllerDelegate{
    func didTaphandleCancel() {
        collectionView.reloadData()
    }
    
    func didTaphandleUpdate() {
        self.fetchDiarys()
        self.fetchDiaryData()
        collectionView.reloadData()
    }
}

