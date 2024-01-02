import SwiftUI

struct LandingPageCell: View {
    @AppStorage("userLandingPageCheck") var userLandingPageCheck: Bool = false
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    var landingImage: String
    
    init(landingImage: String) {
        self.landingImage = landingImage
    }
    
    @State private var showAlert = false
    
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
                                    showAlert = true
                                }) {
                                    Text("Memoir Mate 시작하기")
                                }
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .offset(y: 300) // 이미지를 기준으로 버튼의 위치를 조정
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("앱 사용 동의"),
                                        message: Text("""
                                                        불쾌한 콘텐츠 금지:
                                                        - 앱 내에서 불법적이거나 윤리적으로 문제가 있는 콘텐츠 생성, 공유, 또는 전송을 금지합니다.
                                                                                   
                                                        남용 사용자에 대한 금지:
                                                        - 다른 사용자에 대한 모욕, 협박, 성희롱 또는 기타 불쾌한 행동을 금지합니다. 적발 시 처벌 될 수 있음을 명시합니다.
                                                                                   
                                                        Memoir Mate의 조치에 동의:
                                                        - Memoir Mate는 불쾌한 콘텐츠 발견 시 또는 남용 사용자 식별 시 적절한 조치를 취할 수 있습니다.
                                                                                   
                                                        약관 및 정책 업데이트 확인:
                                                        - 앱 이용 시 정기적으로 Memoir Mate의 약관 및 정책을 확인하여 최신 정보에 따라야 합니다.
                                                                                   
                                                        [동의] 버튼을 클릭하여 위 내용에 동의합니다.
                                                        [거부] 버튼을 클릭 시 앱 이용이 제한됩니다.
                                                        """),
                                        primaryButton: .default(Text("동의")) {
                                            userLandingPageCheck = true
                                            presentationMode.wrappedValue.dismiss()
                                        },
                                        secondaryButton: .cancel(Text("거부")) {
                                            exit(0) // 앱을 종료합니다.
                                        }
                                    )
                                }
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
