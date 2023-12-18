//
//  ExploreController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "UserCell"

enum SearchControllerConfiguration {
    case messages // 메세지를 보낼때
    case userSearch // 사용자를 검색할때 구분하기 위함 ExploreController를 재사용하기 때문임
}

class SearchController: UITableViewController{
    // MARK: - Properties
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet{
            //print("프로필 이미지 호출후 실행되었습니다")
            // 이미지 캐시 제거
            tableView.reloadData()
        }
    }
    
    //var loginUser: User?
    
    private var fileteredUsers = [User]() {// 사용자가 서치바에 검색하면 필터링된 유저들을 담을 배열임
        didSet { tableView.reloadData() }
    } // 검색 기반으로 이 배열을 채워야함
    
    private var inSearchMode: Bool { // 검색모드인지 여부를 판단
        return searchController.isActive &&
            !searchController.searchBar.text!.isEmpty
        // 검색컨트롤러가 활성화 되어있고 텍스트가 비어있지 않은경우 => 검색 모드
    }
    
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        // ProfileHeader 에서 뒤로가기할때 navigationController 데리자가 수행하는데 그때
        // 프로필보기 쪽에서 헤더를 보이지 않게 만들어서 돌아올때 설정 값이 남아있을수 있음 그래서 해당 속성을 추가
    }
    
    
    
    // MARK: - API
    
    func fetchUsers() {
        
        UserService.shared.fetchUsers{ users in
            self.users = users
            print("검색 창에서 이미지 편집후 바뀌는걸 보고 싶음 test \(users)")
        }
    }
    
    
    // MARK: - Selectors
       @objc func handleDismissal() {
           dismiss(animated: true, completion: nil)
       }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = config == .messages ? "New Message" : "사용자 찾기"
        
        //  재사용 셀에 재사용 식별자 등록
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none // 셀 사이에 구분선이 보이지 않게 설정
        
        if config == .messages { //messages일때 cancel버튼 활성화
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        }
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "사용자 아이디를 입력해 주세요"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}


// MARK: - UITableViewDelegate/DataSource

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? fileteredUsers.count : 0
        // 검색모드면 필터링된 사용자의 계수에 따라 셀을 보여줌 , 그게 아니면 아무도 보여주지 않기(정보 보호)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!
        UserCell
        
        let user = inSearchMode ? fileteredUsers[indexPath.row] : users[indexPath.row]
        //검색모드이면 검색모드배열에 담은 유저를 한명씩 셀에 전달, 그게 아니면 전체 사용자들을 한명씩 셀에 전달
        
        cell.user = user
        return cell
        
        /*
         테이블 뷰던, 컬렉션 뷰던 UI셋팅한뷰에 실제 사용자를 뿌려줄때 프로세스
         0. UITableViewController 같이 일단 컨트롤러 구현, 셀 구현 => test로 빈 데모 구현
         1. 필요한 API 함수 구현(어떤 데이터를 가져와 컨트롤러에 담을지)
         2.셀에 표시할 정보를 담을 속성을 만들기 ex user 💁 didSet을 활용해 UI에 실제 사용자 정보 대입
         3.컨트롤러로 돌아와서 셀 만들때 user를 넘겨주기    cell.user = users[indexPath.row] 해당 부분
            4.이전에 API 부분에서 fetchUsers를 구현해 users 배열에 사용자들을 담고 있는 상태여야함
         */
    }
    
    // 사용자 선택시 프로필 보이게 하기
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? fileteredUsers[indexPath.row] : users[indexPath.row]
        
        // 선택할때도 모드에 따라서 선택되게 해야함 안그럼 검색모드에서 나오는 사용자를 선택했을때 검색모드가 아닌 전체 사용자의 첫번째 셀이 선택됨
        if user.uid == Auth.auth().currentUser?.uid {
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            UserService.shared.fetchUser(uid: uid) { user in
                //self.user = user
                let controller = ProfileController(user: user)
                //controller.LoginUser = self.loginUser
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        }
        else
        {
            let controller = ProfileController(user: user)
            //controller.LoginUser = self.loginUser
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}




// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.description else {return}
        //print("DEBUG: Search text is \(searchText)")
        
        fileteredUsers = users.filter({ $0.userID.contains(searchText) })
  
        
    }
    
}
