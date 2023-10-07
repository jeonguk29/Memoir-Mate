//
//  DiaryCommunityFeedViewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/13.
//


import UIKit
import FSCalendar

private let reuseIdentifier = "CommunityCell"

class DiaryCommunityFeedViewController: UICollectionViewController{
    // MARK: - Properties
    
    var user: User?
    { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            self.configureLeftBarButton() // 해당 함수가 호출 될때는 사용자가 존재한다는 것을 알수 있음
        }
    }
    
  
    private var diarys = [Diary]() {
        didSet {collectionView.reloadData()}
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
    

    
   
    
    
    private lazy var actionButton: UIButton = {
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
        
        // UIScrollView의 delegate 설정
        //ScrollView.delegate = self // 여기서 "yourScrollView"는 스크롤뷰의 변수명입니다. 스토리보드에서 스크롤 뷰와 연결해야 합니다.
        
        // 프로필 사진 표시
        
        
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
       
        // titleLabel Auto Layout Constraints
       
        
        // UIScrollView의 delegate를 설정합니다.
        collectionView.delegate = self
       
        collectionView.alwaysBounceVertical = true // 이 부분을 추가하면 스크롤이 항상 가능하게 됩니다. (cell 하나만 있어도 스크롤이 가능하게)
        
        setupFSCalendar()
        setupAutoLayout()
        
        let currentDate = Date()  // 현재 날짜 가져오기
        formatter.dateFormat = "yyyy-MM-dd"
        selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
        
        fetchDiarys()
        
        collectionView.register(CommunityCell.self, forCellWithReuseIdentifier:CommunityCell.reuseIdentifier) // DiaryCell 클래스와 식별자를 등록합니다.
        
        
    }
    
    
    
    // MARK: - Helpers
    private func setupFSCalendar(){
        
        calendarView.backgroundColor = .white // 배경색
        // calendar locale > 한국으로 설정
        calendarView.locale = Locale(identifier: "ko_KR")
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
        let backgroundImage = UIImage(named: "backcomm8")
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
        actionButton.layer.cornerRadius = 56/2 // 높이 나누기 2 하면 원형 모양이 됨
            
    
        
    }
    
    // 네비게이션바 버튼
    func configureLeftBarButton(){
        //guard let user = user else {return}
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user!.profileImageUrl , completed: nil)
        
          
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        

    }
    
  
    
    
    // MARK: - API
    func fetchDiarys() {
        DiaryService.shared.communityFatchDiarys { diarys in
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


}
    


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

extension DiaryCommunityFeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diarys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommunityCell
        
  
        
        cell.delegate = self
        cell.diary = diarys[indexPath.row]
        cell.backgroundBorderView.backgroundColor = .commColor
       
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
        let controller = CommunityDiarySelectController(user: user!,
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
extension DiaryCommunityFeedViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let diary = diarys[indexPath.row]
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 170) // height + 72 이유 : 캡션과 아래 4가지 버튼들 사이 여백을 주기 위함
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
extension DiaryCommunityFeedViewController: CommunityCellDelegate {
    func handleFetchUser(withUsername username: String) {
        print("")
    }
    
    func handelProfileImageTapped(_ cell: CommunityCell) {
        print("")
    }
    
    func handleReplyTapped(_ cell: CommunityCell) {
        print("")
    }
    
    func handleLikeTapped(_ cell: CommunityCell) {
        print("")
    }
    
}


// MARK: - CommunityDiarySelectControllerDelegate

extension DiaryCommunityFeedViewController: CommunityDiarySelectControllerDelegate {
    func didTaphandleCancel() {
        print("")
    }
    
    
  
}


// MARK: - 스크롤 애니메이션 부분
// 스크롤 애니메이션 부분 수정
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


