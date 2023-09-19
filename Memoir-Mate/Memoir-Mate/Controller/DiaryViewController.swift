//
//  DiaryVIewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//

import UIKit
import FSCalendar


private let reuseIdentifier = "DiaryCell"

class DiaryViewController: UICollectionViewController{
    
    
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
    
    private var diarys = [Diary]() {
        didSet {collectionView.reloadData()}
    }
    
    private var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.scrollDirection = .horizontal
        return calendarView
    }()
    
    let formatter = DateFormatter()
    var selectDate: String = "" // didset 사용해서 화면 새로고침해서 일기 목록 뿌려주기
    
    var isNavigationBarHidden = false
    
    
    private lazy var writeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1 // 보더의 넓이 설정
        button.layer.borderColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 보더 컬러 설정
        button.setTitle("일기쓰기", for: .normal)
        
        if let roseOfSharonFont = UIFont(name: "Rose-of-Sharon", size: 16) {
            button.titleLabel?.font = roseOfSharonFont
        } else {
            print("폰트 적용 안됨")
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
        button.setTitleColor(.black, for: .normal)
        
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
        
        // UIScrollView의 delegate를 설정합니다.
        collectionView.delegate = self
        
        setupFSCalendar()
        setupAutoLayout()
        configureLeftBarButton()
        
        let currentDate = Date()  // 현재 날짜 가져오기
        formatter.dateFormat = "yyyy-MM-dd"
        selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
        
        fetchDiarys()
        
        collectionView.register(DiaryCell.self, forCellWithReuseIdentifier:DiaryCell.reuseIdentifier) // DiaryCell 클래스와 식별자를 등록합니다.
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
        
        // 배경 이미지 설정
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundImageView
        
        
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
    
    
    
    
    // MARK: - API
    func fetchDiarys(){
        collectionView.refreshControl?.beginRefreshing() // 새로고침 컨트롤러 추가
        DiaryService.shared.fatchDiarys{ diarys in
            self.diarys = diarys
            
            
            // 날짜 순으로 트윗 정렬
            self.diarys = diarys.sorted(by: { $0.timestamp > $1.timestamp })

            self.collectionView.refreshControl?.endRefreshing()
            
            for diary in diarys {
                print(diary.caption)
                print(diary.timestamp)
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


// MARK: - UICollectionViewDelegate/DataSource

extension DiaryViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("DEBUG: Tweet count at time of collectionView function call is \(tweets.count)")
        /*
         private var tweets = [Tweet]() 으로만 코드 작성을 했을때
         현제 0이 출력되는데 뷰가 로드되지마자 이함수가 호출 되기 때문임 뷰가 로드 될때는 tweets 배열이 빈 배열임
         따라서 이 데이터 가져오기를 완료하고 결과로 이 트윗 배열을 실제로 설정하는 데 시간이 걸립니다.
         그래서 화면에 보이는게 없지만 데이터를 가져와서 didSet을 통해 변경사항이 있을경우 리로드를하면 정상적으로 출력이 가능함
         리로드시 확장으로 구현한 함수들은 다시 한번씩 호출 됨
         +
         이제 우리의 트윗 수는 2개가 될 것입니다.
         따라서 두 개의 셀로 컬렉션 뷰를 다시 로드할 것입니다.
         */
        return diarys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DiaryCell
        
        //print("DEBUGP: indexPath is \(indexPath.row)")
        
        cell.delegate = self
        cell.diary = diarys[indexPath.row]
        
        return cell
    }
    
//    // 셀하나 선택시 일어나는 작업을 설정하는 메서드
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = TweetController(tweet: tweets[indexPath.row])
//        navigationController?.pushViewController(controller, animated: true)
//    }
//
    
    
}
// MARK: - UICollectionViewDelegateFlowLayout
extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let diary = diarys[indexPath.row]
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72) // height + 72 이유 : 캡션과 아래 4가지 버튼들 사이 여백을 주기 위함
    }
    
    // 각 섹션의 여백을 지정 (달력 때문에 일기 안보임 현상을 방지)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 { // 첫 번째 섹션인 경우에만 Safe Area 상단에 여백 추가
            return UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets.zero // 나머지 섹션은 여백 없음
        }
    }
}


// MARK: - TweetCellDelegate
extension DiaryViewController: DiaryCellDelegate {
    func handelProfileImageTapped(_ cell: DiaryCell) {
        print("")
    }
    
    func handleReplyTapped(_ cell: DiaryCell) {
        print("")
    }
    
    func handleFetchUser(withUsername username: String) {
        //        UserService.shared.fetchUser(WithUsername: username) { user in
        //            print(user.username)
        //            let controller = ProfileController(user: user)
        //            self.navigationController?.pushViewController(controller, animated: true)
        //        }
    }
    
    func handleLikeTapped(_ cell: DiaryCell) {
        print("DEBUG: Handle like tapped..")
        //
        //        guard var tweet = cell.tweet else { return }
        ////        cell.tweet?.didLike.toggle()
        ////        print("DEBUG: Tweet is liked is \(cell.tweet?.didLike)")
        //        TweetService.shared.likeTweet(tweet: tweet) { (err, ref) in
        //            cell.tweet?.didLike.toggle()
        //            // 셀에 있는 개체를 실제로 업데이트 하는 부분 API호출시 서버먼저 처리하고 여기서 화면 처리를 하는 것임
        //            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        //            cell.tweet?.likes = likes // 이코드 실행시 Cell의 didSet이 수행됨
        //            //트윗을 설정하든, 트윗안에 사용자를 재설정하든, 트윗의 좋아요 수를 재설정하든, didSet이 호출되는 것임
        //            //그런다음 configure()이 호출 되고 뷰모델러 트윗을 넘겨준 다음 화면에 정상적인 값을 표시할 수 있음
        //
        //            // 트윗이 좋아요인 경우에만 업로드 알림
        //            guard cell.tweet?.didLike == true else { return }
        //
        //            NotificationService.shared.uploadNotification(toUser: tweet.user,
        //                                                                      type: .like,
        //                                                                      tweetID: tweet.tweetID)
        //        }
        //
        //    }
        
        
//        func handleReplyTapped(_ cell: DiaryCell) {
//            //        guard let tweet = cell.tweet else { return }
//            //
//            //        // 이미지 표시 등을 위해 유저 정보를 전달, .reply 인것을 알려주기
//            //        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
//            //        let nav = UINavigationController(rootViewController: controller)
//            //        nav.modalPresentationStyle = .fullScreen
//            //        present(nav, animated: true, completion: nil)
//        }
//
//        func handelProfileImageTapped(_ cell: DiaryCell) {
//            //        guard let user = cell.tweet?.user else { return }
//            //        let controller = ProfileController(user: user)
//            //        navigationController?.pushViewController(controller, animated: true)
//        }// 해당 출력이 나온다면 트윗 셀에서 컨트롤러로 작업을 성공적으로 위임한것임
        
    }
    
}



// MARK: - 스크롤 애니메이션 부분
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
                      self.calendarView.alpha = 0.0
                      self.writeButton.alpha = 0.0
                  }
              }
          } else {
              // 위로 스크롤하는 중
              if isNavigationBarHidden {
                  isNavigationBarHidden = false
                  UIView.animate(withDuration: 0.3) {
                      self.navigationController?.setNavigationBarHidden(false, animated: true)
                      self.calendarView.alpha = 1.0
                      self.writeButton.alpha = 1.0
                  }
              }
          }
      }
}
