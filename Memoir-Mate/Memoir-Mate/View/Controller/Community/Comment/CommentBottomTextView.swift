import UIKit

class CommentBottomTextView: UITextView {
    
    // MARK: - Properties
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        //label.font = UIFont(name: "NanumMuGungHwa", size: 25)
        label.textColor = .darkGray
        label.text = "댓글을 적어주세요"
        return label
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
      
            
            
            self.backgroundColor = .white
            font = UIFont.systemFont(ofSize: 16)
            //self.font = UIFont(name: "NanumMuGungHwa", size: 25)
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
    
   
    
}




