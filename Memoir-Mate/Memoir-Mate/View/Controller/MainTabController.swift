//  MainTabController.swift



import UIKit
import FirebaseAuth

class MainTabController: UITabBarController {

    
    // MARK: - Properties
    
    var user: User? { // 변경이 일어나면 아래 메세지를 출력
        didSet {
            print("DEBUG: Did set user in main tab..")
            guard let nav = viewControllers?[0] as? UINavigationController else {return}
            guard let diary = nav.viewControllers.first as? DiaryViewController else {return}
            diary.user = user
            
            /* 아래서 뷰컨들을 설정해줬음
             // UITabBarController 에서 제공하는 속성임 안에 배열 형태로 뷰를 넣어주면 됨
             viewControllers = [nav1, nav2, nav3, nav4] 0,1,2,3
             0번째 FeedController 위에 네비게이션 컨트롤러를 올렸었음
             그 네비게이션의 첫번째 내장 컨틀로러가 FeedController임
             */
            
            guard let nav = viewControllers?[1] as? UINavigationController else {return}
            guard let diarycommunity = nav.viewControllers.first as? DiaryCommunityFeedViewController else {return}
            diarycommunity.user = user
            
            
            guard let search = nav.viewControllers.last as? SearchController else {return}
            //search.loginUser = user
        }
    }
    
//    let AdminUser: User = {
//        var admindictionary: [String: AnyObject] = ["email": "admin@example.com" as AnyObject, "username": "관리자" as AnyObject]
//        let formatter = DateFormatter()
//        
//        let currentDate = Date()  // 현재 날짜 가져오기
//        formatter.dateFormat = "yyyy-MM-dd"
//        let selectDate = formatter.string(from: currentDate)  // selectDate에 현재 날짜 저장
//        let adminUser = User(uid: "admin", dictionary: admindictionary)
//        
//        return adminUser
//    }()
    

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        tabBar.backgroundColor = .systemGray5
        authenticateUserAndConfigureUI()
        //logUserOut()
      
    }
    

    
    // MARK: - Helpers
    
    func configureViewControllers() {
        
        
        
        let diary = DiaryViewController(collectionViewLayout: UICollectionViewFlowLayout())
        // UINavigationController 가져와서 그안에 feed 를 붙여줌
        let nav1 = templeteNavigationController(image: UIImage(systemName: "note.text.badge.plus"), rootViewController: diary)
        
        // 일기 커뮤니티 피드
        let diarycommunity = DiaryCommunityFeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav2 = templeteNavigationController(image: UIImage(systemName: "person.icloud"), rootViewController: diarycommunity)
        
        
        
        
        // 알림
 
        
        let explore = SearchController(config: .userSearch)
        let nav3 = templeteNavigationController(image: UIImage(systemName: "magnifyingglass.circle"), rootViewController: explore)
        
        
        
        
        // UITabBarController 에서 제공하는 속성임 안에 배열 형태로 뷰를 넣어주면 됨
        viewControllers = [nav1, nav2, nav3]
        
        // 탭바 아이콘, 텍스트 색상 설정
        //tabBar.tintColor = .mainColor  // 원하는 색상으로 변경
    }
    
    
    // MARK: - 네비게이션 설정 
    func templeteNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        return nav
    }
    
    // 현제 탭바안에 각 뷰컨트롤러들을 연결 하였고 각 뷰컨트롤러마다 네비게이션컨틀롤러를
    // 연결하고 설정을 해주었음 네비게이션을 만들때마다 코드를 반복하지 않기 위해 함수를 만들어줌
    
    
    
    
    
    // MARK: - API : 로그인
       func authenticateUserAndConfigureUI() {
           if Auth.auth().currentUser == nil {
               //print("DEBUG: 사용자가 로그인 하지 않았습니다.")
               DispatchQueue.main.async {
                   let nav = UINavigationController(rootViewController: LoginViewController())
                   nav.modalPresentationStyle = .fullScreen
                   self.present(nav, animated: true, completion: nil)
               }
           }else {
               //print("DEBUG: 사용자가 로그인 했습니다.")
               configureViewControllers() // 로그인 했으면 탭바 보여주기
               //configureUI()
               fetchUser()
           }
       }
    
    // MARK: - API
    func fetchUser(){
        // 파이어베이스에서 사용자 데이터 가져오기
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    
    func logUserOut(){ // 로그인 확인을 하기 위한 임시 함수 아직 버튼을 구현하지 않아서 빠르 로그아웃 시키고 확인하기 위함
            do {
                try Auth.auth().signOut()
                print("DEBUG: 유저가 로그아웃 했습니다.")
            }catch let error {
                print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            }
        }
    
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
