import SwiftUI

struct SendView: View {
    @State private var selectedCrypto: CryptoType = .btc
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var showingConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingTransactionReceipt = false
    @State private var currentTransaction: TransactionReceiptView.Transaction?
    @FocusState private var focusedField: Field?
    
    enum Field {
        case recipient, amount
    }
    
    // Dummy data - replace with actual wallet data
    private let walletBalances: [CryptoType: (balance: Double, value: Double)] = [
        .btc: (0.5, 25000),
        .eth: (2.5, 5000),
        .usdt: (1000, 1000)
    ]
    
    enum CryptoType: String, CaseIterable {
        case btc = "Bitcoin"
        case eth = "Ethereum"
        case usdt = "Tether"
        
        var symbol: String {
            switch self {
            case .btc: return "BTC"
            case .eth: return "ETH"
            case .usdt: return "USDT"
            }
        }
        
        var icon: String {
            switch self {
            case .btc: return "bitcoin"
            case .eth: return "ethereum"
            case .usdt: return "tether"
            }
        }
        
        var imageURL: URL? {
            switch self {
            case .btc: return URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")
            case .eth: return URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png")
            case .usdt: return URL(string: "https://assets.coingecko.com/coins/images/325/large/tether.png")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Crypto Selection
                        cryptoSelectionSection
                        
                        // Balance Card
                        balanceCard
                        
                        // Send Form
                        sendForm
                    }
                    .padding()
                }
            }
            .navigationTitle("Send")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Confirm Transaction", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Send", role: .none) {
                    handleSendTransaction()
                }
            } message: {
                VStack {
                    Text("Are you sure you want to send:")
                    Text("\(amount) \(selectedCrypto.symbol)")
                        .fontWeight(.bold)
                    Text("to address:")
                    Text(recipientAddress)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                }
            }
            .sheet(isPresented: $showingTransactionReceipt) {
                if let transaction = currentTransaction {
                    TransactionReceiptView(transaction: transaction)
                }
            }
        }
    }
    
    private var cryptoSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Cryptocurrency")
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CryptoType.allCases, id: \.self) { crypto in
                        cryptoButton(for: crypto)
                    }
                }
            }
        }
    }
    
    private func cryptoButton(for crypto: CryptoType) -> some View {
        Button(action: { selectedCrypto = crypto }) {
            HStack(spacing: 8) {
                AsyncImage(url: crypto.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(crypto.icon)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 24, height: 24)
                
                Text(crypto.symbol)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedCrypto == crypto ? Color.theme.accent : Color.theme.background)
                    .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
            )
            .foregroundColor(selectedCrypto == crypto ? .white : Color.theme.accent)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedCrypto == crypto ? Color.theme.accent : Color.theme.accent.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var balanceCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Available Balance")
                    .foregroundColor(Color.theme.secondaryText)
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(walletBalances[selectedCrypto]?.balance ?? 0, specifier: "%.4f")")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.accent)
                
                Text(selectedCrypto.symbol)
                    .font(.title3)
                    .foregroundColor(Color.theme.secondaryText)
                
                Spacer()
                
                Text("≈ $\(walletBalances[selectedCrypto]?.value ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private var sendForm: some View {
        VStack(spacing: 20) {
            // Recipient Address
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipient Address")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                TextField("Enter \(selectedCrypto.symbol) address", text: $recipientAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .recipient)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .amount
                    }
            }
            
            // Amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                HStack {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .amount)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                    
                    Text(selectedCrypto.symbol)
                        .foregroundColor(Color.theme.secondaryText)
                }
                
                HStack {
                    Text("Available: \(walletBalances[selectedCrypto]?.balance ?? 0, specifier: "%.4f") \(selectedCrypto.symbol)")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                    
                    Spacer()
                    
                    Button("MAX") {
                        amount = String(format: "%.4f", walletBalances[selectedCrypto]?.balance ?? 0)
                        focusedField = nil
                    }
                    .foregroundColor(Color.theme.accent)
                }
            }
            
            // Send Button
            Button(action: {
                focusedField = nil
                validateAndShowConfirmation()
            }) {
                Text("Send \(selectedCrypto.symbol)")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme.accent)
                    .cornerRadius(12)
            }
            .disabled(amount.isEmpty || recipientAddress.isEmpty)
            .opacity(amount.isEmpty || recipientAddress.isEmpty ? 0.6 : 1)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func validateAndShowConfirmation() {
        // Basic validation
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            errorMessage = "Please enter a valid amount"
            showingError = true
            return
        }
        
        guard amountDouble <= (walletBalances[selectedCrypto]?.balance ?? 0) else {
            errorMessage = "Insufficient balance"
            showingError = true
            return
        }
        
        // Basic address validation (very basic, should be more robust)
        guard recipientAddress.count >= 26 else {
            errorMessage = "Invalid recipient address"
            showingError = true
            return
        }
        
        showingConfirmation = true
    }
    
    private func handleSendTransaction() {
        focusedField = nil
        guard let amountDouble = Double(amount) else { return }
        
        // Generate a random transaction ID (in real app, this would come from the blockchain)
        let transactionId = "0x" + String(format: "%016x", Int.random(in: 0...Int.max))
        
        // Create transaction object
        let transaction = TransactionReceiptView.Transaction(
            id: transactionId,
            cryptoType: selectedCrypto,
            amount: amountDouble,
            recipientAddress: recipientAddress,
            timestamp: Date(),
            status: .inProgress
        )
        
        // Update current transaction and show receipt
        currentTransaction = transaction
        showingTransactionReceipt = true
        
        // In a real app, you would:
        // 1. Send the transaction to the blockchain
        // 2. Update the transaction status based on blockchain response
        // 3. Update the wallet balance
        // 4. Show appropriate success/error messages
    }
}

#Preview {
    SendView()
} 