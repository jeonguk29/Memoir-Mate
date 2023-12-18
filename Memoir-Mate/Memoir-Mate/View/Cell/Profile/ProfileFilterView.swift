//
//  ProfileFilterView.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 11/1/23.
//

import UIKit


private let reuseIdentifier = "ProfileFilterCell"

protocol ProfileFilterViewDelegate: class {
    func filterView(_ view: ProfileFilterView, didSelect indexPath: Int)
}

class ProfileFilterView: UIView {


    // MARK: - Properties

    weak var delegate: ProfileFilterViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        return view
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("DEBUG: Did init..")
        print("DEBUG: Frame in init is \(frame.width)")
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left)
        
        addSubview(collectionView)
        collectionView.addConstraintsToFillView(self)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive
//        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive
//        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive
//        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive
    }
    
    
    override func layoutSubviews() {
        print("DEBUG: Did layout subViews..")
        print("DEBUG: Frame in init is \(frame.width)")
           addSubview(underlineView)
                // 3등분으로 나눠 각 필터 선택시 크기가 맞게 설정
                underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, width: frame.width / 3, height: 2)
//        underlineView.translatesAutoresizingMaskIntoConstraints = false
//        underlineView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive
//        underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive
//        underlineView.widthAnchor.constraint(equalToConstant: frame.width / 3).isActive = true
//        underlineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
       }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: - UICollectionViewDataSource

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileFilterOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileFilterCell
        
        let option = ProfileFilterOptions(rawValue: indexPath.row)
        //print("DEBUG: Option is \(option?.description)")
        cell.option = option
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension ProfileFilterView: UICollectionViewDelegate {
    
    // 각 아이템을 선택할때마다 호출 되는 함수임
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let cell = collectionView.cellForItem(at: indexPath)
        
        // 해당 셀의 x 위치를 가져온 다음 밑줄이 그어진 보기를 해당 x 위치로 애니메이션화하는 것입니다.
        let xPosition = cell?.frame.origin.x ?? 0
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
        
        print("DEBUG: Delegate action to profile header from filter bar..")
        delegate?.filterView(self, didSelect: indexPath.row) // 이제 우리는 이 프로토콜을 준수해야 하며 프로필 헤더 내부에서 그렇게 할 것임
        
    }
    
}



// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    
    // 각각의 셀 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = CGFloat(ProfileFilterOptions.allCases.count)
        
        //frame의 너비를 3등분한 너비
        return CGSize(width: frame.width / count, height: frame.height)
    }
    
    // 섹션과 섹션사이의 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
