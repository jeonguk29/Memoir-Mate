//
//  InputTextView.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//


import UIKit

class InputTextView: UITextView {

    // MARK: - Properties
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "오늘의 일기를 적어주세요"
        return label
    }()
    
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = true
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
    
        NSLayoutConstraint.activate([
         placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
         placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
        
        //placeholderLabel.anchor(top:topAnchor, left: leftAnchor, paddingTop:8, paddingLeft:4)
        ])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty

//        아래 코드를 위 한줄로 표현 가능
//        if text.isEmpty{
//            placeholderLabel.isHidden = false
//        } else {
//            placeholderLabel.isHidden = true
//        }
    }
}




