import SwiftUI

struct TransactionReceiptView: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    struct Transaction {
        let id: String
        let cryptoType: SendView.CryptoType
        let amount: Double
        let recipientAddress: String
        let timestamp: Date
        let status: TransactionStatus
        
        enum TransactionStatus {
            case inProgress
            case completed
            case failed
            
            var color: Color {
                switch self {
                case .inProgress: return .orange
                case .completed: return .green
                case .failed: return .red
                }
            }
            
            var icon: String {
                switch self {
                case .inProgress: return "clock.fill"
                case .completed: return "checkmark.circle.fill"
                case .failed: return "xmark.circle.fill"
                }
            }
            
            var text: String {
                switch self {
                case .inProgress: return "Transaction in Progress"
                case .completed: return "Transaction Completed"
                case .failed: return "Transaction Failed"
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Status Card
                        statusCard
                        
                        // Transaction Details
                        transactionDetailsCard
                        
                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Transaction Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            Image(systemName: transaction.status.icon)
                .font(.system(size: 48))
                .foregroundColor(transaction.status.color)
            
            Text(transaction.status.text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(transaction.status.color)
            
            if transaction.status == .inProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: transaction.status.color))
                    .scaleEffect(1.2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: transaction.status.color.opacity(0.1), radius: 5)
        )
    }
    
    private var transactionDetailsCard: some View {
        VStack(spacing: 20) {
            // Transaction ID
            detailRow(title: "Transaction ID", value: transaction.id)
            
            Divider()
            
            // Amount
            detailRow(
                title: "Amount",
                value: String(format: "%.8f \(transaction.cryptoType.symbol)", transaction.amount)
            )
            
            Divider()
            
            // Recipient
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipient Address")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
                
                Text(transaction.recipientAddress)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color.theme.accent)
            }
            
            Divider()
            
            // Timestamp
            detailRow(
                title: "Date & Time",
                value: transaction.timestamp.formatted(date: .abbreviated, time: .shortened)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.theme.accent)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Share transaction details
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Receipt")
                }
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.theme.accent, lineWidth: 1)
                )
            }
            
            Button(action: {
                // View on blockchain explorer
            }) {
                HStack {
                    Image(systemName: "link")
                    Text("View on Explorer")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.accent)
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    TransactionReceiptView(transaction: TransactionReceiptView.Transaction(
        id: "0x1234...5678",
        cryptoType: .btc,
        amount: 0.1234,
        recipientAddress: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
        timestamp: Date(),
        status: .inProgress
    ))
} 