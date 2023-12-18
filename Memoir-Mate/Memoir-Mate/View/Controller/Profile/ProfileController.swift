//
//  ProfileController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/1/23.
//


import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import AVFoundation

private let reuseIdentifier = "DiaryCell"
private let headerIdentifier = "ProfileHeader"



class ProfileController: UICollectionViewController{
    
    
    // MARK: - properties
    
    private var user: User

   
    
    // 기본값을 .tweets로 지정해서 프로필 클릭시 Tweets이 첫화면임
    private var selectedFilter: ProfileFilterOptions = .diarys {
          didSet { collectionView.reloadData() }
    }
    
    private var diarys = [Diary]()
    private var replies = [Diary]()
    private var likedTweets = [Diary]()

    // 프로필 화면에서 필터에따른 트윗을 보여주기 위해
    private var currentDataSource: [Diary] {
        switch selectedFilter {
        case .diarys: return diarys
        case .likes: return likedTweets
        }
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        //그리고 여기에서 Super.init를 호출할 때 이것은 컬렉션이기 때문에 이해하는 것이 매우 중요합니다.
        //컬렉션 뷰 컨트롤러도 초기화해야 합니다.
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        
//        // 비디오 파일 경로를 가져옵니다.
//        if let videoPath = Bundle.main.path(forResource: "tab2", ofType: "mp4") {
//            // AVPlayer 인스턴스를 생성합니다.
//            let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
//            
//            // AVPlayerLayer 인스턴스를 생성하고 AVPlayer를 할당합니다.
//            let playerLayer = AVPlayerLayer(player: player)
//            playerLayer.frame = view.bounds
//            playerLayer.videoGravity = .resizeAspectFill
//            
//            // 비디오를 보여줄 뷰를 생성합니다.
//            let videoView = UIView(frame: view.bounds)
//            videoView.layer.addSublayer(playerLayer)
//            
//            // 비디오를 반복 재생합니다.
//            player.actionAtItemEnd = .none
//            
//            // 비디오가 끝났을 때 호출되는 옵저버를 등록합니다.
//            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { [weak player] _ in
//                player?.seek(to: CMTime.zero) // 비디오를 처음으로 되감습니다.
//                player?.play() // 비디오를 재생합니다.
//            }
//            
//            
//            player.isMuted = true // 소리 끄기
//            // 비디오 재생을 시작합니다.
//            player.play()
//            
//            // collectionView의 배경으로 비디오 뷰를 설정합니다.
//            collectionView.backgroundView = videoView
//        }
        
        configureCollectionView()
        fetchDiarys()
        print("DEBUG: User is \(user.username)")
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchLikedTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true //네비게이션 바 숨기고 커스텀으로 만들기 위해
    }
    
    
    
    // MARK: - API
    func fetchDiarys() {
        // FeedController에서 선택한 트윗셀의 user 정보를 전달 받기 때문에 바로 넘길 수 있음
        
        // 프로필 누른 사용자 정보와 현제 로그인한 사용자 정보가 같을때 공유하지 않은 일기까지 보여주고
        //프로필 누른 사용자 정보와 현제 로그인한 사용자 정보가 다를때 공유한 일기만 보여주기
        
        //문제 내꺼의 공유 된거만 표시됨 다른사람거 일기 안보임
        DiaryService.shared.fatchDiarys(forUser: user) { diarys in
            var Mydiarys = [Diary]()
            
            print("프로필 선택 유져\(self.user.uid) 로그인한 유져\(Auth.auth().currentUser?.uid)" )
            if self.user.uid != Auth.auth().currentUser?.uid {
                for Sharediary in diarys {
                    if Sharediary.isShare == true {
    
                        Mydiarys.append(Sharediary)
                    }
                }
                self.diarys = Mydiarys
                self.collectionView.reloadData()
            }
            else if self.user.uid == Auth.auth().currentUser?.uid {
                for alldiary in diarys {
                    if alldiary.isShare == true || alldiary.isShare == false{
                      
                        Mydiarys.append(alldiary)
                    }
                }
                self.diarys = Mydiarys
                self.collectionView.reloadData()
            }
      
        }
    }
    
    // 좋아요 누른 트윗 가져오가
    func fetchLikedTweets() {
           DiaryService.shared.fetchLikes(forUser: user) { diarys in
               self.likedTweets = diarys
               // selectedFilter 의 Didset 작동해서 화면 리로드 가능함
           }
    }
    
    
    func checkIfUserIsFollowed(){
        UserService.shared.checkIfUserIsFollowd(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }

    // 사용자 followers, following 값 표시
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            //print("DEBUG: User has \(stats.followers) followers")
            //print("DEBUG: User is following \(stats.following) people")
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemGray6
        collectionView.contentInsetAdjustmentBehavior = .never // 상태 표시줄 지우기
        
        collectionView.register(DiaryCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //헤더 등록
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        
        
        // 헤더에서 보여지는 트윗 많을때 스크롤 가능하게 높이를 조정
        guard let tabHeight = tabBarController?.tabBar.frame.height else {return}
        collectionView.contentInset.bottom = tabHeight
    }
}



// MARK: - UICollectionViewDataSource

extension ProfileController {
    //  프로필 헤더 대리자에는 어떤 필터가 선택되었는지 알려주는 함수가 필요합니다.
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DiaryCell
        
        cell.diary = currentDataSource[indexPath.row]
        return cell
    }
}


// MARK: - UICollectionViewDelegate

//재사용 가능한 헤더 추가
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.user = user
        header.delegate = self // 델리게이트 설정
        
        return header
    }
    
    // 프로필에서 셀 누를때 메인과 동일하게 트윗으로 이동
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diary = currentDataSource[indexPath.row]
        
        if selectedFilter == .diarys && diary.user.uid == Auth.auth().currentUser?.uid {
           //print("선택 일기 \(diary.user.uid) 지금 사용자 \(self.user.uid)")
            let controller = WriteDiaryController(user: user, userSelectDate: "", config: .diary, userSelectstate: .Update, userSelectDiary: diary)
           controller.delegate = self
       
           let nav = UINavigationController(rootViewController: controller)
           nav.modalPresentationStyle = .fullScreen
           present(nav, animated: true, completion: nil)
  
        }
        else {
          
            let controller = CommunityDiarySelectController(user: user, userSelectDate: "", config: .diary, userSelectstate: .Update, userSelectDiary: diary)
            
            controller.delegate = self
            //navigationController?.pushViewController(controller, animated: true)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    
    
        
        // CommunityDiarySelectController
        
     }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    //컬렉션 뷰의 헤더 만들기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 300.0 // 기본 높이
        
        if (user.bio ?? "") != "" { // 소개 글이 있을때 높이를 설정
            height = 350.0
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let diary = currentDataSource[indexPath.row]
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        // 최대 높이를 400으로 제한
        let cellHeight = max(min(height, 400), 200)
                  
        return CGSize(width: view.frame.width, height: cellHeight)
    }
}


// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        //print("DEBUG: Did select filter \(filter.description) in profile controller..")
        self.selectedFilter = filter
    }
    
    
    // 커스텀 델리게이트로 팔로우 처리해주기
    func handleEditProfileFollow(_ header: ProfileHeader) {

        //print("DEBUG: User is followed is \(user.isFollowed) before button tap ")
        
        if user.isCurrentUser {
            // 팔로우 못하게

             let controller = EditProfileController(user: user)
            controller.delegate = self
            
            let nav = UINavigationController(rootViewController: controller)

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .mainColor
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
            nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                //print("언팔로우 처리가 끝난후 돌아오는 곳 ")
                self.user.isFollowed = false
                print("DEBUG: User is followed is \(self.user.isFollowed) after button tap ")
                
                // UI 변경 팔로우에 따른 : API 호출 후에만 변경 됨
               // header.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.collectionView.reloadData()
            }
        } else {
            // 처음에 눌렀을때는 팔로우 하지 않은 false 상황이니까  여기가 눌릴것임
            UserService.shared.followUser(uid: user.uid) { (ref, err) in
                //print("팔로우 처리가 끝난후 돌아오는 곳 ")
                self.user.isFollowed = true
                print("DEBUG: User is followed is \(self.user.isFollowed) after button tap ")
                
                // UI 변경 팔로우에 따른
                //header.editProfileFollowButton.setTitle("Following", for: .normal)
                self.collectionView.reloadData()
                
                // 누군가를 팔로우하기 시작하면 알림을 보내야 합니다.
                NotificationService.shared.uploadNotification(toUser: self.user,
                                                              type: .follow)
                 
            }
        }

    }
 
    
    func handleDismissal() {
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
        
        dismiss(animated: true, completion: nil)
    }

}


extension ProfileController: CommunityDiarySelectControllerDelegate {
    func didTaphandleCancel() {
        collectionView.reloadData()
    }
}

extension ProfileController: WriteDiaryControllerDelegate{
    
    func didTaphandleUpdate() {
        self.fetchDiarys()
   
    }
}




// MARK: - EditProfileControllerDelegate
@available(iOS 16.0, *)
extension ProfileController: EditProfileControllerDelegate {
    
    func handleLogout() {// 로그인 처리를 위임받아 처리
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                
                
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            } catch let error {
                print("Couldn't make logout with error \(error.localizedDescription)")
            }
        }
    
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        
        // 변경후 메인에 전달해서 사용자 정보 모든 탭에 재전달 후 리로드
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                          let tab = window.rootViewController as? MainTabController else { return }
                    //print("RegistrationController 에서 이미지 등록후 \(user.photoURLString)")
                    tab.user = user
        

        self.collectionView.reloadData() // 사용자 정보를 업데이트후 리로드
    }
}
