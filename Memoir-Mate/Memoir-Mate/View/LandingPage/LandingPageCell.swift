//
//  LandingPageCell.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 12/9/23.
//

import SwiftUI

struct LandingPageCell: View {
    @AppStorage("userLandingPageCheck") var userLandingPageCheck: Bool = false
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    var landingImage: String
    
    init(landingImage: String) {
        self.landingImage = landingImage
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                Image(landingImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.80) // 이미지의 너비를 화면 너비의 80%로 설정
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    .overlay(
                        VStack {
                            if landingImage == "Landing5" {
                                Button(action: {
                                    userLandingPageCheck = true
                                    presentationMode.wrappedValue.dismiss() // 버튼을 누르면 현재 화면을 닫음
                                }) {
                                    Text("Memoir Mate 시작하기")
                                }
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .offset(y: 300) // 이미지를 기준으로 버튼의 위치를 조정
                            }
                        }
                    )
            }
        }
    }


}

struct LandingPageCell_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageCell(landingImage: "Landing5")
    }
}
