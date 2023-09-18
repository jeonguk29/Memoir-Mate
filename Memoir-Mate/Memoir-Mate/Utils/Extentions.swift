//
//  Extentions.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//

import UIKit

extension UIView {
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}

// MARK: - UIColor

extension UIColor {
    
    // 확장으로 간단하게 생상을 지정할 수 있는 함수를 구현/ 여러곳에서 사용할 트위터 블루 색상을 정의
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let mainColor = UIColor.rgb(red: 71, green: 115, blue: 181)
}
