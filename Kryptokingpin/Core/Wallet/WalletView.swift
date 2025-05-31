import SwiftUI

struct WalletView: View {
    // Dummy data for wallets
    private let wallets = [
        CryptoWallet(
            name: "Bitcoin",
            symbol: "BTC",
            balance: 0.5,
            value: 25000.0,
            change24h: 2.5,
            icon: "bitcoin",
            walletAddress: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
        ),
        CryptoWallet(
            name: "Ethereum",
            symbol: "ETH",
            balance: 2.5,
            value: 5000.0,
            change24h: -1.2,
            icon: "ethereum",
            walletAddress: "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
        ),
        CryptoWallet(
            name: "Tether",
            symbol: "USDT",
            balance: 1000.0,
            value: 1000.0,
            change24h: 0.0,
            icon: "tether",
            walletAddress: "TWd4WrZ9wn84f5x1hZhL8wXKUE2KqB8t9"
        )
    ]
    
    // Calculate total balance in USD and BTC
    private var totalBalanceUSD: Double {
        wallets.reduce(0) { $0 + $1.value }
    }
    
    private var totalBalanceBTC: Double {
        // Assuming 1 BTC = $50,000 for this example
        // In a real app, you would fetch the current BTC price
        let btcPrice = 50000.0
        return totalBalanceUSD / btcPrice
    }
    
    private var totalChange24h: Double {
        // Calculate weighted average of 24h changes
        let totalValue = totalBalanceUSD
        return wallets.reduce(0) { sum, wallet in
            sum + (wallet.change24h * (wallet.value / totalValue))
        }
    }
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Total Balance Card
                        VStack(spacing: 16) {
                            Text("Total Balance")
                                .font(.headline)
                                .foregroundColor(Color.theme.secondaryText)
                            
                            VStack(spacing: 8) {
                                Text("$\(totalBalanceUSD, specifier: "%.2f")")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color.theme.accent)
                                
                                Text("\(totalBalanceBTC, specifier: "%.8f") BTC")
                                    .font(.title3)
                                    .foregroundColor(Color.theme.secondaryText)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: totalChange24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text("\(abs(totalChange24h), specifier: "%.1f")%")
                            }
                            .font(.subheadline)
                            .foregroundColor(totalChange24h >= 0 ? .green : .red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.theme.background)
                                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
                        )
                        
                        // Deposit Tabs
                        depositTabs
                    }
                    .padding()
                }
            }
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var depositTabs: some View {
        VStack(spacing: 0) {
            // Tab Buttons
            HStack(spacing: 0) {
                ForEach(0..<wallets.count, id: \.self) { index in
                    tabButton(index: index)
                }
            }
            .background(Color.theme.background)
            .cornerRadius(10)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                ForEach(0..<wallets.count, id: \.self) { index in
                    depositView(wallet: wallets[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func tabButton(index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 8) {
                // Replace SF Symbol with actual crypto icon
                AsyncImage(url: URL(string: getCoinImageURL(for: wallets[index].symbol))) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color.theme.secondaryText)
                }
                .frame(width: 24, height: 24)
                
                Text(wallets[index].symbol)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                selectedTab == index ?
                Color.theme.accent.opacity(0.1) :
                Color.clear
            )
            .foregroundColor(
                selectedTab == index ?
                Color.theme.accent :
                Color.theme.secondaryText
            )
        }
    }
    
    // Helper function to get coin image URL
    private func getCoinImageURL(for symbol: String) -> String {
        switch symbol.lowercased() {
        case "btc":
            return "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579"
        case "eth":
            return "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880"
        case "usdt":
            return "https://assets.coingecko.com/coins/images/325/large/tether.png?1668148663"
        default:
            return ""
        }
    }
    
    private func depositView(wallet: CryptoWallet) -> some View {
        VStack(spacing: 20) {
            // QR Code
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(Color.theme.accent)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            
            // Wallet Address
            VStack(spacing: 8) {
                Text("\(wallet.name) Address")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                Text(wallet.walletAddress)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    UIPasteboard.general.string = wallet.walletAddress
                    // Add haptic feedback here if needed
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Address")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.theme.accent)
                    .cornerRadius(8)
                }
            }
            
            // Warning Text
            Text("Only send \(wallet.symbol) to this address")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// Model for cryptocurrency wallet
struct CryptoWallet: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let balance: Double
    let value: Double
    let change24h: Double
    let icon: String
    let walletAddress: String
}

#Preview {
    WalletView()
} 