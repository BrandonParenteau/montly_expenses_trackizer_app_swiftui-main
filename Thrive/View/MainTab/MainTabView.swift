//
//  MainTabView.swift
//  Trackizer
//
//  Created by CodeForAny on 12/07/23.
//

import SwiftUI

struct MainTabView: View {
    
    @State var selectTab: Int = 0
    @StateObject var uiState = UIStateModel()
    
    
    var body: some View {
        NavigationView {
            ZStack{
                
                if(selectTab == 0) {
                    HomeView()
                        .frame(width: .screenWidth, height: .screenHeight)
                }
                
                if(selectTab == 1) {
                    BudgetsView()
                        .frame(width: .screenWidth, height: .screenHeight)
                }
                
                if(selectTab == 2) {
                    CalendarView()
                        .frame(width: .screenWidth, height: .screenHeight)
                }
                
                if(selectTab == 3) {
                    ToolsView()
                        .frame(width: .screenWidth, height: .screenHeight)
                }
                
                VStack{
                    Spacer()
                    
                    ZStack(alignment: .bottom){
                        
                        
                        
                        ZStack(alignment: .center) {
                            Image("bottom_bar_bg")
                                .resizable()
                                .scaledToFit()
                            
                            HStack(alignment: .center, spacing: 0){
                                
                                Spacer()
                                Button {
                                    selectTab = 0
                                } label: {
                                    Image("home")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                }
                                .foregroundColor( selectTab == 0 ? .secondaryC : .gray30 )
                                
                                Spacer()
                                Button {
                                    selectTab = 1
                                } label: {
                                    Image("budgets")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                }
                                .foregroundColor( selectTab == 1 ? .secondaryC : .gray30 )
                                
                                
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: 80, height: 0)
                                
                                Button {
                                    selectTab = 2
                                } label: {
                                    Image("calendar")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                }
                                .foregroundColor( selectTab == 2 ? .secondaryC : .gray30 )
                                
                                Spacer()
                                Button {
                                    selectTab = 3
                                } label: {
                                    Image(systemName: "briefcase")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                }
                                .foregroundColor( selectTab == 3 ? .secondaryC : .gray30 )
                                Spacer()
                            }
                        }
                        NavigationLink(destination: AIAssistantView()) {
                            Image("center_btn")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                        .padding(.bottom, 6)
                        .shadow(color: .secondaryC.opacity(0.5), radius: 6,y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom , .bottomInsets)
                
            }
            .background(Color.grayC)
            .ignoresSafeArea()
            
        }
    }
    
    struct MainTabView_Previews: PreviewProvider {
        static var previews: some View {
            MainTabView()
                .environmentObject(WeekStore())
        }
    }
}

#Preview {
    MainTabView()
}
