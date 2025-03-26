//
//  WelcomView.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI

struct WelcomView: View {
    
    @State var showSignIn: Bool = false
    @State var showSignUp: Bool = false
    @EnvironmentObject  var appController: AppController

    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("welcome_screen")
                    .resizable()
                    .scaledToFill()
                    .frame(width: .screenWidth, height: .screenHeight)
                
                VStack {
                    Image("FortifyLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: .widthPer(per: 0.5))
                        .padding(.top, .topInsets + 8)
                    
                    Spacer()
                    
                    Text("Strengthen Your Financial Future")
                        .multilineTextAlignment(.center)
                        .font(.customfont(.regular, fontSize: 14))
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    
                    // Direct NavigationLink for "Get Started"
                    NavigationLink(destination: SocialSignupView(), isActive: $showSignUp) {
                        PrimaryButton(title: "Get Started", onPressed: {
                            showSignUp.toggle()
                        })
                    }
                    .padding(.bottom, 15)
                    
                    // Direct NavigationLink for "I have an account"
                    NavigationLink(destination: SignInView(), isActive: $showSignIn) {
                        SecondaryButton(title: "I have an account", onPressed: {
                            showSignIn.toggle()
                        })
                    }
                    .padding(.bottom, .bottomInsets)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        }
    }
}

struct WelcomView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomView()
    }
}
