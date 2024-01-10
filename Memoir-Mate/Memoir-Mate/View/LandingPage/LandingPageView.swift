//
//  LandingPageView.swift
//  Memoir-Mate
//
//  Created by 정정욱 on 12/9/23.
//

import SwiftUI

struct LandingPageView: View {
    
    // App Storage 을 사용하면 앱을 다시 열때 자동으로 키에서 이름을 가져옵니다
    
    @State var initPageNumber: Int = 0
    var body: some View {
        TabView(selection: $initPageNumber) {
            LandingPageCell(landingImage: "Landing1")
                .tabItem {
                    Image(systemName: "smallcircle.filled.circle")
                }
                .tag(0) // 0번 화면
            
            LandingPageCell(landingImage: "Landing2")
                .tabItem {
                    Image(systemName: "smallcircle.filled.circle")
              
                }
                .tag(1)// 1번 화면
            
            LandingPageCell(landingImage: "Landing3")
                .tabItem {
                    Image(systemName: "smallcircle.filled.circle")
                 
                }
                .tag(2)// 2번 화면
            
            LandingPageCell(landingImage: "Landing4")
                .tabItem {
                    Image(systemName: "smallcircle.filled.circle")
           
                }
                .tag(3)// 2번 화면
            
            TermsOfAgreementView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
            
                }
                .tag(4)// 2번 화면
        }
        .padding()
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    LandingPageView()
}
