//
//  TermsOfAgreementView.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 1/2/24.
//

import SwiftUI

struct TermsOfAgreementView: View {
    
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    
    @State private var isCheckboxSelected1 = false
    @State private var isCheckboxSelected2 = false
    @State private var isCheckboxSelected3 = false
    @State private var isCheckboxSelected4 = false
    @State private var isCheckboxSelected5 = false
    
    @State private var bounce = false
    
    var body: some View {
        VStack {
            HStack{
                Text("Memoir Mate 이용 약관 동의")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 30)
                Spacer()
            }
            // 체크박스 아이콘 이미지들
            VStack(spacing: 20){
                
                HStack(spacing: 20){
                    CheckboxIcon(isSelected: $isCheckboxSelected1)
                    Text("개인정보 수집 및 이용 동의: 앱을 사용하기 위해 이메일 및 이름 정보 수집을 동의합니다.")
                        .font(.subheadline)
                    Spacer()
                }
                HStack(spacing: 20){
                    CheckboxIcon(isSelected: $isCheckboxSelected2)
                    Text("남용 사용자에 대한 금지: 다른 사용자에 대한 모욕, 협박, 성희롱 또는 기타 불쾌한 행동을 금지합니다. 적발 시 처벌 될 수 있습니다.")
                        .font(.subheadline)
                    Spacer()
                }
                HStack(spacing: 20){
                    CheckboxIcon(isSelected: $isCheckboxSelected3)
                    Text("불쾌한 콘텐츠 금지: 앱 내에서 불법적이거나 윤리적으로 문제가 있는 콘텐츠 생성, 공유, 또는 전송을 금지합니다.")
                        .font(.subheadline)
                    Spacer()
                }
                HStack(spacing: 20){
                    CheckboxIcon(isSelected: $isCheckboxSelected4)
                    Text("약관 및 정책 업데이트 확인: 정기적으로 Memoir Mate의 약관 및 정책을 확인하여 최신 정보에 따라야 합니다.")
                        .font(.subheadline)
                    Spacer()
                }
                
                Button(action: {
                    if isCheckboxSelected1 && isCheckboxSelected2 && isCheckboxSelected3 && isCheckboxSelected4 {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        // 어떤 조건이든 충족되지 않으면 사용자에게 메시지를 표시하거나 추가 동작을 수행
                        
                        // Haptic Feedback (진동)
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        
                        // 흔들기 애니메이션
                        // 통통 튀는 애니메이션
                        withAnimation(Animation.interpolatingSpring(stiffness: 200, damping: 10).repeatCount(1)) {
                            bounce.toggle()
                        }
                    }
                }) {
                    Text("Memoir Mate 시작하기")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .scaleEffect(bounce ? 1.1 : 1)
                }
                .padding(.top)
                
            }
        }
        .padding()
        
        
    }
}



struct CheckboxIcon: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(isSelected ? .blue : .gray) // isSelected에 따라 색상 변경
            .onTapGesture {
                isSelected.toggle()
            }
    }
}



#Preview {
    TermsOfAgreementView()
}
