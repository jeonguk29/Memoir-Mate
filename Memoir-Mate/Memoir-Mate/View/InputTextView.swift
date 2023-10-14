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
        //label.font = UIFont.systemFont(ofSize: 16)
        label.font = UIFont(name: "NanumMuGungHwa", size: 25)
        label.textColor = .darkGray
        label.text = "오늘의 일기를 적어주세요"
        return label
    }()
    
    // 추가: 키보드 내리기 버튼
    let dismissKeyboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        


        backgroundColor = .white
        //font = UIFont.systemFont(ofSize: 16)
        font = UIFont(name: "NanumMuGungHwa", size: 25)
        isScrollEnabled = true
        //heightAnchor.constraint(equalToConstant: 600).isActive = true
        //heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            
            //placeholderLabel.anchor(top:topAnchor, left: leftAnchor, paddingTop:8, paddingLeft:4)
        ])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        

        // 키보드 내리기 버튼 액션 설정
           dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        
        let doneButton = UIBarButtonItem.init(customView: dismissKeyboardButton)
        toolBar.items = [doneButton]
        self.inputAccessoryView = toolBar
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
        
        // 텍스트의 위치에 레이블을 따라 움직이도록 코드를 추가
        // 이동 레이블 (placeholderLabel)을 입력한 텍스트의 위치에 맞게 조정
        let topOffset: CGFloat = text.isEmpty ? 8 : 0
        let leadingOffset: CGFloat = text.isEmpty ? 4 : 0
        
        UIView.animate(withDuration: 0.2) {
            self.placeholderLabel.transform = CGAffineTransform(translationX: leadingOffset, y: topOffset)
        }
        
    }
    
    
    // 추가: 키보드 내리기 액션
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}




