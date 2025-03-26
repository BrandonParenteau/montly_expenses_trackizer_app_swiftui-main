//
//  SignUpView.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI


struct SignUpView: View {
    
    @State var txtEmail: String = ""
    @State var txtPassword: String = ""
    @State var showSignIn: Bool = false
    @State private var isSignUp: Bool = true
    @EnvironmentObject  var appController: AppController
    
    var body: some View {
        ZStack{
        
            VStack{
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .widthPer(per: 0.5) )
                    .padding(.top, .topInsets + 8)
                
                
                Spacer()
                
                RoundTextField(title: "Email", text: $appController.email)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                
                        
                
                
                RoundTextField(title: "Password", text: $appController.password, isPassword: true)
                
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                HStack {
                    
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                        .padding(.horizontal, 1)
                    
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                        .padding(.horizontal, 1)
                    
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                        .padding(.horizontal, 1)
                    
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                        .padding(.horizontal, 1)
                    
                }
                .padding(.horizontal, 20)
                .foregroundColor(.gray70)
                .padding(.bottom, 20)
                
                Text("Use 8 or more characters with a mix of letters,\nnumbers & symbols.")
                    .multilineTextAlignment(.leading)
                    .font(.customfont(.regular, fontSize: 14))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .foregroundColor(.gray50)
                    .padding(.bottom, 20)
                
                PrimaryButton(title: "Get Started, it's free!", onPressed: {
                    signUp()
    
                    
                })
                
                Spacer()
                
                Text("Do you have already an account?")
                    .multilineTextAlignment(.center)
                    .font(.customfont(.regular, fontSize: 14))
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                SecondaryButton(title: "Sign In", onPressed: {
                    showSignIn.toggle()
                })
                .padding(.bottom, 16) // Adjust padding to match `.bottomInsets + 8`
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(edges: .all)
            .background(Color.grayC)
            // Navigation destination to handle showing the SignInView
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            
        }
        .hideKeyboardWhenTappedAround()
    }
    func authenticate() {
        isSignUp ? signUp() : signIn()
    }
    
    func signUp() {
        Task {
            do {
                try await appController.signUp()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await appController.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    struct SignUpView_Previews: PreviewProvider {
        static var previews: some View {
            SignUpView()
                .environmentObject(AppController())
        }
    }
}
