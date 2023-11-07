//
//  InputTextView.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 2023/09/15.
//


import UIKit

enum textViewType { // 트윗인지, 답글인지 구분하기 위한 enum 타입
    case ready
    case personal
    case community
}


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
    
    var textType : textViewType = .ready {
        didSet { configure() }
    }
    
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
        
            configure()
            
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        DispatchQueue.main.async { [self] in
            
            
            if self.textType == .personal {
                self.backgroundColor = .white
                //font = UIFont.systemFont(ofSize: 16)
                self.font = UIFont(name: "NanumMuGungHwa", size: 25)
                self.isScrollEnabled = true
                //heightAnchor.constraint(equalToConstant: 600).isActive = true
                //heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
                
                self.addSubview(self.placeholderLabel)
                self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                
                
                NSLayoutConstraint.activate([
                    self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                    self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
                    
                    //placeholderLabel.anchor(top:topAnchor, left: leftAnchor, paddingTop:8, paddingLeft:4)
                ])
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
                
                
                // 키보드 내리기 버튼 액션 설정
                let customToolbar = UIToolbar()
                customToolbar.sizeToFit()
                dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
//                dismissKeyboardButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
//                dismissKeyboardButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
                
    
                let doneButton = UIBarButtonItem(customView: dismissKeyboardButton)

                customToolbar.setItems([doneButton], animated: false)

                // ToolBar 대신 customToolbar로 설정
                self.inputAccessoryView = customToolbar

                
                
            }
            
                
        
            if self.textType == .community {
                self.backgroundColor = .white
                self.font = UIFont(name: "NanumMuGungHwa", size: 25)
                self.isScrollEnabled = true
                self.isEditable = false // 편집 불가능하도록 설정
        
                self.addSubview(self.placeholderLabel)
                self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                
                
                NSLayoutConstraint.activate([
                    self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                    self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
                    
                ])
                
                
            }
        }
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
        print("키보드 내리기")
        self.endEditing(true)
    }
    
    
}




