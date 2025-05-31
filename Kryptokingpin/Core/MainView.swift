import SwiftUI

struct MainView: View {
    
   
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var viewModel: AuthViewModel


    @State private var selectedTab: Int = 0
    
    var body: some View {
        
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                WalletView()
                    .tabItem {
                        Image(systemName: "wallet.pass.fill")
                        Text("Wallet")
                    }
                    .tag(1)
                
                SendView()
                    .tabItem {
                        Image(systemName: "arrow.up.right.circle.fill")
                        Text("Send")
                    }
                    .tag(2)
                
                AccountView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
                    .tag(3)
            }
            .tint(Color.theme.accent)
        
    }
}

#Preview {
    MainView()
        .environmentObject(DeveloperPreview.instance.homeVM)
}
