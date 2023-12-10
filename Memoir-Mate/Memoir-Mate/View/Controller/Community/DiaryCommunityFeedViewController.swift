//
//  DiaryCommunityFeedViewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//


import UIKit
import FSCalendar
import AVFoundation
import MessageUI
import SwiftUI

private let reuseIdentifier = "CommunityCell"

@available(iOS 16.0, *)
class DiaryCommunityFeedViewController: UICollectionViewController{
    // MARK: - Properties
    
    var user: User?
    { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            self.configureLeftBarButton() // 해당 함수가 호출 될때는 사용자가 존재한다는 것을 알수 있음
            print("DiaryCommunityFeedViewController \(user?.email)")
        }
    }
    
  
    private var diarys = [Diary]() 
    {
        //diarys 배열이 변경되어 collectionView.reloadData()가 호출될 때 깜빡임 없이 자연스럽게 화면 갱신
        didSet {
             UIView.transition(with: collectionView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                 self.collectionView.reloadData()
             }, completion: nil)
         }
    }
    
    
    
    private var calendarView: FSCalendar = {
        let calendarView = FSCalendar(frame: .zero)
        calendarView.scrollDirection = .horizontal
        //calendarView.scope = .week // 주간 달력 설정
        //calendarView.appearance.selectionColor = .clear
        return calendarView
    }()
    
    let formatter = DateFormatter()
    var selectDate: String = "" // didset 사용해서 화면 새로고침해서 일기 목록 뿌려주기
    
    // 날짜를 키로 하고 다이어리 항목이 있는지 여부를 값으로 하는 딕셔너리를 저장할 변수
    private var diaryData: [String: Bool] = [:]
    
    var isNavigationBarHidden = false
    var calendarHidden = false
    

    
    private lazy var NotificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        
        button.addTarget(self, action: #selector(handleNotificationTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    private lazy var calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar.circle"), for: .normal)
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(closeCalendarTapped), for: .touchUpInside)
        
          
        return button
    }()


    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
     
        
        
        // 즉, 사용자가 화면을 아래로 스크롤하면 (스와이프하면) 네비게이션 바가 자동으로 사라지고, 다시 위로 스크롤하면 (스와이프하면) 네비게이션 바가 다시 나타납니다.
        navigationController?.hidesBarsOnSwipe = true
        
        
        // 처음 화면 보일때
        fetchDiarys()
        
        
        // UIScrollView의 delegate 설정
        //ScrollView.delegate = self // 여기서 "yourScrollView"는 스크롤뷰의 변수명입니다. 스토리보드에서 스크롤 뷰와 연결해야 합니다.
        
        // 프로필 사진 표시
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
       
        // calendarView 둥글게
        calendarView.layer.masksToBounds = true
        calendarView.layer.cornerRadius = 20 // 원하는 라운드 값으로 설정
        calendarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        calendarView.isHidden = true
        
        // calendarView 보더라인 주기
        //calendarView.layer.borderWidth = 3.0

        // mainColor를 CGColor로 변환
        // mainColor를 UIColor로 정의
        let mainColor = UIColor.rgb(red: 71, green: 115, blue: 181)
        let mainCGColor = mainColor.cgColor
        // calendarView에 보더 라인 색상 설정
        //calendarView.layer.borderColor = mainCGColor
       
        // titleLabel Auto Layout Constraints
       
        
        // UIScrollView의 delegate를 설정합니다.
        collectionView.delegate = self
       
        collectionView.alwaysBounceVertical = true // 이 부분을 추가하면 스크롤이 항상 가능하게 됩니다. (cell 하나만 있어도 스크롤이 가능하게)
        
        setupFSCalendar()
        setupAutoLayout()
        
        let currentDate = Date()  // 현재 날짜 가져오기
        formatter.dateFormat = "yyyy-MM-dd"
        selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
        
        
        collectionView.register(CommunityCell.self, forCellWithReuseIdentifier:CommunityCell.reuseIdentifier) // DiaryCell 클래스와 식별자를 등록합니다.
        
        // 피드 새로고침 가능하게 새로고침시 트윗 다시 보여주기 : 팔로우 취소한 사람 트윗에 대하여, 팔로우 했을때는 새 노드가 추가될 때마다 감시 대기하는 데이터베이스 구조에 수신기가 있기 때문에 바로바로 적용 됨 피드에
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
     
    }
    
    // MARK: - Selectors
     @objc func handleRefresh() {
         fetchDiarys()
     }
    
//    // viewWillAppear에서 실행해 화면이 보여질때 새로고침 되는 것을 방지
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchDiarys()
//        //self.checkIfUserLikedDiarys() // 좋아요 상태 확인() // 화면이 나타나기 직전에 fetchDiarys()를 호출하여 데이터를 새로고침합니다.
//    }
    
    
    // MARK: - Helpers
    private func setupFSCalendar(){
        
        calendarView.backgroundColor = .white // 배경색
        // calendar locale > 한국으로 설정
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    @objc func handleNotificationTapped() {
        let controller = NotificationsController(user: user!)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleDismissNotifications))
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
    }
    
    @objc func handleDismissNotifications() {
        dismiss(animated: true, completion: nil)
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
    
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        
        let controller = ProfileController(user: user)
        controller.navigationItem.setHidesBackButton(true, animated: false) // "Back" 버튼 숨김
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen // 모달 스타일을 Full Screen으로 설정
        
        present(navigationController, animated: true, completion: nil)
    }
    
    
    private func setupAutoLayout() {
        
        // 비디오 파일 경로를 가져옵니다.
           if let videoPath = Bundle.main.path(forResource: "tab2-2", ofType: "mp4") {
               // AVPlayer 인스턴스를 생성합니다.
               let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
               
               // AVPlayerLayer 인스턴스를 생성하고 AVPlayer를 할당합니다.
               let playerLayer = AVPlayerLayer(player: player)
               playerLayer.frame = view.bounds
               playerLayer.videoGravity = .resizeAspectFill
               
               // 비디오를 보여줄 뷰를 생성합니다.
               let videoView = UIView(frame: view.bounds)
               videoView.layer.addSublayer(playerLayer)
               
               // 비디오를 반복 재생합니다.
               player.actionAtItemEnd = .none
               
               // 비디오가 끝났을 때 호출되는 옵저버를 등록합니다.
               NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { [weak player] _ in
                   player?.seek(to: CMTime.zero) // 비디오를 처음으로 되감습니다.
                   player?.play() // 비디오를 재생합니다.
               }
                      
               
               player.isMuted = true // 소리 끄기
               // 비디오 재생을 시작합니다.
               player.play()
               
               // collectionView의 배경으로 비디오 뷰를 설정합니다.
               collectionView.backgroundView = videoView
           }
       
        
//        // 배경 이미지 설정
//        let backgroundImage = UIImage(named: "backcomm8")
//        let backgroundImageView = UIImageView(image: backgroundImage)
//        backgroundImageView.contentMode = .scaleAspectFill
//        collectionView.backgroundView = backgroundImageView
        
        
        view.addSubview(calendarView)
     
           
        calendarView.translatesAutoresizingMaskIntoConstraints = false

            
            
        // Safe Area 제약 조건 설정
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            calendarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,constant: -370),
            //세로크기를 100
            
        
        ])
     
            
    
        
    }
    
    // 네비게이션바 버튼
    func configureLeftBarButton(){
        //guard let user = user else {return}
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user!.photoURLString , completed: nil)
        // 피드에서 자신의 프로파일 이미지 누를시 사용자 프로필로 이동
        profileImageView.isUserInteractionEnabled = true // 이미지 뷰는 기본으로 false로 설정이라 해줘야함 터치 인식 가능하게
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
          
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        let customButton =  UIBarButtonItem(customView: NotificationButton)
        let customButton2 =  UIBarButtonItem(customView: calendarButton)
        
        // 네비게이션 바 아이템 사이에 임의로 간격 설정하기
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 32 // 원하는 간격을 설정하세요

        navigationItem.rightBarButtonItems = [customButton, space, customButton2]
        
     
        navigationItem.rightBarButtonItem = customButton
        

    }
    
  
    
    func fetchDiarys() {
        collectionView.refreshControl?.beginRefreshing() // 새로고침 컨트롤러 추가

        DiaryService.shared.communityFatchDiarys { diarys in
            var communityDiarys = [Diary]() // 공유된 다이어리를 담을 배열 생성
            var selectDiarys = [Diary]() // 선택된 날짜의 다이어리를 담을 배열 생성
            
            for diary in diarys {
                if diary.isShare { // isShare가 true인 경우에만 추가
                    communityDiarys.append(diary)
                }
            }
            
            // 같은 날짜의 일기만 선택
            selectDiarys = communityDiarys.filter {
                $0.userSelectDate == self.selectDate
            }
            
            // 좋아요 상태 확인 및 적용
            self.checkIfUserLikedDiary(selectDiarys)
            
            // 날짜 순으로 정렬
            selectDiarys.sort(by: { $0.timestamp > $1.timestamp })
            
            self.diarys = selectDiarys
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    func checkIfUserLikedDiary(_ diarys: [Diary]) {
        diarys.forEach { diary in
            DiaryService.shared.checkIfUserLikedDiary(diary) { didLike in
                guard didLike == true else { return }
                if let index = self.diarys.firstIndex(where: { $0.diaryID == diary.diaryID }) {
                    self.diarys[index].didLike = true
                }
            }
        }
    }
    
    // 한번만    self.diarys = selectDiarys 변경될때 리로드 되도록 바꾸자 didSet 금지 시켜야 새로고침해야 값받을 수 있음

 
   

    
 


}
    

@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController: FSCalendarDelegate, FSCalendarDataSource {
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
    

}


// MARK: - UICollectionViewDelegate/DataSource

@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diarys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommunityCell
        
  
        
        cell.delegate = self
        cell.diary = diarys[indexPath.row]
        //cell.backgroundBorderView.backgroundColor = .commColor
       
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
        let controller = CommunityDiarySelectController(
            user: self.user!, userSelectDate: diarys[indexPath.row].userSelectDate,
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
@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let diary = diarys[indexPath.row]
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        // 최대 높이를 400으로 제한
        let cellHeight = max(min(height, 400), 230)
                  
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
@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController: CommunityCellDelegate, MFMailComposeViewControllerDelegate {
    
    enum ReportReason: String, CaseIterable {
        case inappropriateLanguage = "부적절한 언어 사용"
        case explicitContent = "성적인 콘텐츠"
        case harassment = "괴롭힘"
        case privacyInvasion = "개인정보 침해"
        case copyrightInfringement = "저작권 침해"
        case spamOrStalking = "스팸 또는 스토킹"
        // 추가적인 이유를 필요에 따라 열거형에 추가할 수 있습니다.
    }

    func handleDeclaration(_ cell: CommunityCell) {
        guard let userUid = cell.diary?.user.uid else { return }
        guard let userName = cell.diary?.user.userNickName else { return }
        guard let userCellID = cell.diary?.diaryID else { return }
        
        let alertController = UIAlertController(title: "신고 이유", message: nil, preferredStyle: .actionSheet)
        
        // Enum의 모든 케이스를 액션으로 추가
        for reason in ReportReason.allCases {
            let action = UIAlertAction(title: reason.rawValue, style: .default) { _ in
                // sendEmail 함수 호출
                self.sendEmail(reason: reason.rawValue, userUid: userUid, userName: userName, userCellID: userCellID)
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    
 
    
    func sendEmail(reason: String, userUid: String, userName: String, userCellID: String) {
        if MFMailComposeViewController.canSendMail() {
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            
            let bodyString = """
                신고 이유: \(reason)
                신고 사용자 UID: \(userUid)
                신고 사용자 이름: \(userName)
                신고 일기 ID: \(userCellID)
                해당 부분은 수정 하시면 안 됩니다.
                
                "허위 신고로 판명될 경우, 이러한 행위는 심각한 규칙 위반으로 간주됩니다. 이러한 행위는 계정 제한으로 이루어 질 수 있으며, 신고는 신중하게 검토되므로 다시 한번 정당한 이유 없이 허위 신고를 제출하지 않도록 유의해주시기 바랍니다. 감사합니다."
                
                앱에서 신고할 내용을 아래에 적어주세요.
                
                """
            
            // 받는 사람 이메일, 제목, 본문
            composeVC.setToRecipients(["jeonguk29@naver.com"])
            composeVC.setSubject("신고 사항")
            composeVC.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeVC, animated: true)
        } else {
            // 만약, 디바이스에 email 기능이 비활성화 일 때, 사용자에게 알림
            let alertController = UIAlertController(title: "메일 계정 활성화 필요",
                                                    message: "Mail 앱에서 사용자의 Email을 계정을 설정해 주세요.",
                                                    preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .default) { _ in
                guard let mailSettingsURL = URL(string: UIApplication.openSettingsURLString + "&&path=MAIL") else { return }
                
                if UIApplication.shared.canOpenURL(mailSettingsURL) {
                    UIApplication.shared.open(mailSettingsURL, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true)
        }
    }
    

    // MARK: - MFMailComposeViewControllerDelegate
    // 해당 코드가 있어야 메일 전송후 앱 화면으로 돌아 오게 가능함
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    
 
    func handleFetchUser(withUsername username: String) {
        print()
    }
    
    func handelProfileImageTapped(_ cell: CommunityCell) {
        guard let user = cell.diary?.user else { return }
        
        let controller = ProfileController(user: user)
        controller.navigationItem.setHidesBackButton(true, animated: false) // "Back" 버튼 숨김
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen // 모달 스타일을 Full Screen으로 설정
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func handleReplyTapped(_ cell: CommunityCell) {
        print()
    }


    func handleLikeTapped(_ cell: CommunityCell) {
         print("DEBUG: Handle like tapped..")
         
         guard var diary = cell.diary else { return }
 //        cell.tweet?.didLike.toggle()
 //        print("DEBUG: Tweet is liked is \(cell.tweet?.didLike)")
            DiaryService.shared.likeDiary(diary: diary) { (err, ref) in
             cell.diary?.didLike.toggle()
             // 셀에 있는 개체를 실제로 업데이트 하는 부분 API호출시 서버먼저 처리하고 여기서 화면 처리를 하는 것임
             let likes = diary.didLike ? diary.likes - 1 : diary.likes + 1
             cell.diary?.likes = likes // 이코드 실행시 Cell의 didSet이 수행됨
             //트윗을 설정하든, 트윗안에 사용자를 재설정하든, 트윗의 좋아요 수를 재설정하든, didSet이 호출되는 것임
             //그런다음 configure()이 호출 되고 뷰모델러 트윗을 넘겨준 다음 화면에 정상적인 값을 표시할 수 있음
             
             // 트윗이 좋아요인 경우에만 업로드 알림
             guard cell.diary?.didLike == true else { return }
             
             NotificationService.shared.uploadNotification(toUser: diary.user,type: .like, diaryID: diary.diaryID)
         }
         
     }
}



// MARK: - CommunityDiarySelectControllerDelegate

@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController: CommunityDiarySelectControllerDelegate {
    func didTaphandleCancel() {
        print("")
    }
    
    
  
}


// MARK: - 스크롤 애니메이션 부분
// 스크롤 애니메이션 부분 수정
@available(iOS 16.0, *)
extension DiaryCommunityFeedViewController {
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


