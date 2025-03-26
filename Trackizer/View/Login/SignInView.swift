//
//  SignInView.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI

struct SignInView: View {
    @State var txtLogin: String = ""
    @State var txtPassword: String = ""
    @State var isRemember: Bool = false
    @State var showSignUp: Bool = false
    @State var errorMessage: String? = nil
    @State var isLoggedIn: Bool = false
    @EnvironmentObject  var appController: AppController
    @StateObject private var googleSignInVM = SignIn_withGoogle_VM()
    
    var body: some View {
        ZStack{
            
            VStack{
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .widthPer(per: 0.5) )
                    .padding(.top, .topInsets + 8)
                
                
                Spacer()
                
                RoundTextField(title: "Login", text: $txtLogin, keyboardType: .emailAddress)
                
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                
                
                
                RoundTextField(title: "Password", text: $txtPassword, isPassword: true)
                
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                if let errorMessage = errorMessage {
                                   Text(errorMessage)
                                       .foregroundColor(.red)
                                       .font(.customfont(.regular, fontSize: 14))
                                       .padding(.bottom, 15)
                                       .padding(.horizontal, 20)
                               }
                
                
                HStack{
                    Button {
                        isRemember = !isRemember
                    } label: {
                        
                        HStack{
                            
                            Image(systemName: isRemember ? "checkmark.square" : "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("Forgot Password")
                                .multilineTextAlignment(.center)
                                .font(.customfont(.regular, fontSize: 14))
                        }
                        
                        
                        
                    }
                    .foregroundColor(.gray50)
                    
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Forgot Password")
                            .multilineTextAlignment(.center)
                            .font(.customfont(.regular, fontSize: 14))
                        
                    }
                    .foregroundColor(.gray50)
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                PrimaryButton(title: "Sign In", onPressed: {
                    
                    Task {
                        do {
                            try await appController.signIn()
                            isLoggedIn = true
                        } catch {
                            errorMessage = "Failed to sign in: \(error.localizedDescription)"
                        }
                    }
                })
                
                Spacer()
                
                PrimaryButton(title: "Sign in with Google") {
                    Task {
                        do {
                            try await googleSignInVM.signInWithGoogle()
                            isLoggedIn = true
                        } catch {
                            errorMessage = "Google Sign In Failed: \(error.localizedDescription)"
                        }
                    }
                }
                
                Spacer()
                
                Text("if you don't have an account yet?")
                    .multilineTextAlignment(.center)
                    .font(.customfont(.regular, fontSize: 14))
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                SecondaryButton(title: "Sign Up", onPressed: {
                    showSignUp.toggle()
                })
                .background( NavigationLink(destination: SignUpView(), isActive: $showSignUp, label: {
                    EmptyView()
                }) )
                .padding(.bottom, .bottomInsets + 8)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .background(Color.grayC)
        .hideKeyboardWhenTappedAround()
    }
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
