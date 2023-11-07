//
//  ActionSheetLauncher.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/7/23.

import UIKit

private let reuseIdentifier = "ActionSheetCell"

// 옵션 선택시 실제 동작 처리를 위한 프로토콜 생성
protocol ActionSheetLauncherDelegate: class {
    func didSelect(option: ActionSheetOptions)
}


class ActionSheetLauncher: NSObject { //NSObject 이유
    
    // MARK: - Properties
    
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    private lazy var viewModel = ActionSheetViewModel(user: user) // user 값이 들어온 다음 만들어야 함으로 lazy var
    
    weak var delegate: ActionSheetLauncherDelegate?
    private var tableViewheight: CGFloat?
    
    private lazy var blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    // 취소 버튼 만들고 뷰에 올리기
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGroupedBackground
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12)
        cancelButton.centerY(inView: view)
        cancelButton.layer.cornerRadius = 50 / 2
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
        configureTableView()
    }
    
    // MARK: - Selectors
    // 블랙부분 누르면 다시 원상태로 돌아오는 애니메이션을 적용
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
    
    // MARK: - Helpers
    
    func showTableView(_ shouldShow: Bool) {
          guard let window = window else { return }
          guard let height = tableViewheight else { return }

          let y = shouldShow ? window.frame.height - height : window.frame.height
          tableView.frame.origin.y = y
      }
    
    func show() {
        //print("DEBUG: Show action sheet for user \(user.username)")
        
        // SceneDelegate 에서 사용한적 있었음
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        self.window = window
        
        window.addSubview(blackView) // 이렇게 하면 UI 창의 전체 화면에 검은색 뷰를 추가할 수 있습니다.
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        
        let height = CGFloat(viewModel.options.count * 60) + 100
        tableViewheight = height// 우리는 높이를 +100으로 했습니다. 바닥과 상단에 약간의 공간을 원하기 때문
        
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
        
        // 블랙 뷰를 서서히 적용 하는 애니메이션
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.tableView.frame.origin.y -= height
        }
    }
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDelegate
extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
}

// MARK: - UITableViewDataSource
extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
        // 뷰 모델이 필요한 옵션수를 반환함
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ActionSheetCell
        
        cell.option = viewModel.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        print("DEBUG: Selected option is \(option.description)")
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.showTableView(false)
        }) { _ in
            self.delegate?.didSelect(option: option)
        }
   
    }
}
