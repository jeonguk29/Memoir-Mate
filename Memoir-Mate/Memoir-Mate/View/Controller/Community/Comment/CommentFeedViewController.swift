//
//  CommentFeedViewController.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/10/14.
//


import UIKit
import FSCalendar
import AVKit
import Foundation


private let reuseIdentifier = "CommentCell"

class CommentFeedViewController: UICollectionViewController{
    
    
    // MARK: - Properties
    
    
    var user: User?
    { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            profileImageView.sd_setImage(with: user!.photoURLString , completed: nil)
        }
    }
    
    var selectDiary: Diary? {
        didSet {
            fetchDiarys()
            collectionView.reloadData()
        }
    }
    
    var comments = [Diary?]() {
        didSet {
            print("comments값 받음")
            collectionView.reloadData()
        }
    }
    
    let customView = CommentBottomTextView()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 32, height: 32)
        iv.layer.cornerRadius = 32/2
        iv.backgroundColor = .commColor
        
        // 버튼이 아닌 view 객체를 탭 이벤트 처리하는 방법 : 사용자 프로필 작업하기
        // lazy var로 profileImageView를 수정해야함 아래 함수가 만들어지기 전에 인스턴스를 찍을 수 있어서
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        //        iv.addGestureRecognizer(tap)
        //        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.bubble"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        
        return button
    }()
    
    
    private lazy var comentView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    var saveComentViewFrame: Double = 0.0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIScrollView의 delegate를 설정합니다.
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true // 이 부분을 추가하면 스크롤이 항상 가능하게 됩니다. (cell 하나만 있어도 스크롤이 가능하게)
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier:CommentCell.reuseIdentifier)
        
        configureCommentView()
        
        configureLeftBarButton()
        
        
        
        // 키보드 올라올 때의 Notification을 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 키보드 내려갈 때의 Notification을 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Selectors
    @objc func handlePost(){
        
        guard let caption = customView.text else { return }
        
        // 메인 스레드에서 실행되도록 DispatchQueue를 사용
        DispatchQueue.main.async {
            DiaryService.shared.diaryComment(diary: self.selectDiary, caption: caption){ (error, ref) in
                if let error = error {
                    print("DEBUG: 댓글 업로드에 실패했습니다. error \(error.localizedDescription)")
                    return
                }
            }
        }
        
        self.customView.text = ""
        self.customView.placeholderLabel.isHidden = false
        
        comentView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = 50
            }
        }


        // 업데이트된 제약을 적용
        view.layoutIfNeeded()
        
        // 현제 일기, 접속중인 사용자 값 전달하기
        
        // 댓글 작성후 전달 버튼 누를때
        // 공유중인 현제 일기 밑에 댓글 id 순서대로 달기
        // 그리고 컬랙션뷰 리로드
        fetchDiarys()
    }
    
    
    
    // MARK: - Helpers
    // 'comentView' UI 구성
    func configureCommentView() {
    
        collectionView.backgroundColor = .systemGray6
        
        comentView.backgroundColor = .white
        comentView.layer.cornerRadius = 20
        comentView.layer.shadowColor = UIColor.black.cgColor
        comentView.layer.shadowOpacity = 0.2
        comentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        comentView.layer.shadowRadius = 4
        view.addSubview(comentView)
        
        comentView.translatesAutoresizingMaskIntoConstraints = false
        comentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        comentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        comentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        //comentView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // 댓글 입력 필드 추가
        //        let commentField = UITextField()
        //        commentField.placeholder = "댓글 추가..."
        //        commentField.backgroundColor = .clear
        //        commentField.borderStyle = .none
        
        // 텍스트 필드
        customView.delegate = self // custom view의 delegate를 self로 설정
        
        // 텍스트 필드
        comentView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.leadingAnchor.constraint(equalTo: comentView.leadingAnchor, constant: 50).isActive = true
        customView.trailingAnchor.constraint(equalTo: comentView.trailingAnchor, constant: -28).isActive = true
        customView.topAnchor.constraint(equalTo: comentView.topAnchor, constant: 5).isActive = true
        customView.bottomAnchor.constraint(equalTo: comentView.bottomAnchor, constant: -5).isActive = true
        
        comentView.addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.centerYAnchor.constraint(equalTo: comentView.centerYAnchor).isActive = true // 버튼을 custom view의 세로 중앙에 배치합니다.
        postButton.trailingAnchor.constraint(equalTo: comentView.trailingAnchor, constant: -10).isActive = true // 버튼을 custom view의 오른쪽에 배치합니다.
        postButton.isHidden = true
        
        
        comentView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.bottomAnchor.constraint(equalTo: comentView.bottomAnchor, constant: -8).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: comentView.leadingAnchor, constant: 11).isActive = true
    }
    
    
    
    // 키보드가 올라올 때
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.2) {
                self.comentView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - 30))
            }
        }
    }
    
    // 키보드가 내려갈 때
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.comentView.transform = .identity
        }
    }
    
    // 스크롤뷰를 스크롤할 때 호출되는 메서드
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 키보드가 올라와 있는 경우에만 키보드 내림
        // 이것은 어떤 응답과 관계없이 모든 키보드를 닫을 때 유용합니다.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 네비게이션바 버튼
    func configureLeftBarButton(){
        //guard let user = user else {return}
        // 네비게이션 바를 생성하고 설정합니다.
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .white // 원하는 배경색으로 설정하세요
        
        // 네비게이션 아이템 생성
        let navigationItem = UINavigationItem(title: "댓글")
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleClose))
        navigationItem.rightBarButtonItem = closeButton
        
        // 네비게이션 바에 아이템 설정
        navigationBar.items = [navigationItem]
        
        // 뷰에 네비게이션 바 추가
        view.addSubview(navigationBar)
        
        
        
    }
    
    @objc func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - API
    func fetchDiarys() {
        print("fetchDiaryComment 호출")
        DiaryService.shared.fetchDiaryComment(with: selectDiary?.diaryID ?? ""){ diarys in
            var selectdiarys = [Diary]() // 선택된 날짜의 일기를 담을 배열 생성
            
            // 최신 댓글이 가장 아래로 내려가도록 정렬
            self.comments = diarys.sorted(by: { $0.timestamp > $1.timestamp })
            // 업데이트된 데이터를 반영하기 위해 collectionView를 업데이트
            print(self.comments)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
}




// MARK: - UICollectionViewDelegate/DataSource

extension CommentFeedViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.delegate = self
        cell.comment = comments[indexPath.row]
        
        
        //            // 셀에 대한 초기 설정
        //            // 애니메이션 적용
        //            cell.alpha = 0.0
        //            UIView.animate(withDuration: 0.5) {
        //                cell.alpha = 1.0
        //            }
        
        return cell
    }
    
    
}

extension CommentFeedViewController : commentCellDelegate{
    func handelProfileImageTapped(_ cell: CommentCell) {
        print()
    }
    
    func handleReplyTapped(_ cell: CommentCell) {
        print()
    }
    
    func handleLikeTapped(_ cell: CommentCell) {
        print()
    }
    
    func handleFetchUser(withUsername username: String) {
        print()
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CommentFeedViewController: UICollectionViewDelegateFlowLayout {
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let diary = comments[indexPath.row] else { return CGSize(width: 0, height: 0) }
        let viewModel = DiaryViewModel(diary: diary)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        // 최대 높이를 400으로 제한
        let cellHeight = min(height + 80, 300)
        
        
//        print(" cell 테스트 \(indexPath.row)")
//        print(" cell 테스트 \(comments.count - 1)")
//        // 마지막 셀인 경우
//        if indexPath.row == comments.count - 1 {
//            let bottomSpacing: CGFloat = 50
//            let collectionViewHeight = collectionView.bounds.size.height
//            let contentHeight = collectionView.contentSize.height
//            let maxContentOffsetY = contentHeight - collectionViewHeight
//            
//     
//            return CGSize(width: view.frame.width, height: cellHeight + bottomSpacing)
//           
//        }
        
        return CGSize(width: view.frame.width, height: cellHeight)
    }
    

    // 섹션개념을 가지고 여백을 줘서 텍스트 박스 가려지지 않게 적용
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 { // 첫 번째 섹션인 경우
            return UIEdgeInsets(top: 55, left: 0, bottom: 80, right: 0)
        }
        
        return UIEdgeInsets.zero // 나머지 섹션은 여백 없음
    }
    
  
    
    
    
    
}

// MARK: - UITextFieldDelegate
extension CommentFeedViewController: UITextViewDelegate {
    
    // UITextViewDelegate 메서드
    func textViewDidChange(_ textView: UITextView) {
        
        //let maxHeight: CGFloat = 300 // 최대 높이 설정 (여기서는 300으로 가정합니다.)
        //let minHeight: CGFloat = 50 // 원래 높이 설정 (여기서는 50으로 가정합니다.)
        
        if textView.text.count > 20 {
            // customView의 높이를 최대 높이로 업데이트
            comentView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = 200
                }
            }
        } else {
            // customView의 높이를 원래 크기로 업데이트
            comentView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = 50
                }
            }
        }

        // 업데이트된 제약을 적용
        view.layoutIfNeeded()

        if customView.text.isEmpty {
            postButton.isHidden = true
            customView.placeholderLabel.isHidden = false
        } else {
            postButton.isHidden = false
            customView.placeholderLabel.isHidden = true
        }

        let currentHeight = textView.frame.height
        let contentHeight = textView.contentSize.height

        if currentHeight < contentHeight && contentHeight > 100 {
            textView.isScrollEnabled = true

            let range = NSMakeRange(textView.text.count - 1, 1)
            textView.scrollRangeToVisible(range)
        } else {
            textView.isScrollEnabled = false
        }
    }

    
}



//
//extension DiaryViewController: WriteDiaryControllerDelegate{
//    func didTaphandleCancel() {
//        collectionView.reloadData()
//    }
//
//    func didTaphandleUpdate() {
//        self.fetchDiarys()
//        self.fetchDiaryData()
//        collectionView.reloadData()
//    }
//}

