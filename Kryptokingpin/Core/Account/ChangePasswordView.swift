import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isChanging = false
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case current, new, confirm
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Password Requirements
                        passwordRequirements
                        
                        // Password Form
                        passwordForm
                    }
                    .padding()
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        changePassword()
                    }
                    .disabled(isChanging)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Password Change", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if !alertMessage.contains("Error") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password Requirements")
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            
            VStack(alignment: .leading, spacing: 8) {
                requirementRow("At least 8 characters", isValid: newPassword.count >= 8)
                requirementRow("One uppercase letter", isValid: newPassword.contains(where: { $0.isUppercase }))
                requirementRow("One lowercase letter", isValid: newPassword.contains(where: { $0.isLowercase }))
                requirementRow("One number", isValid: newPassword.contains(where: { $0.isNumber }))
                requirementRow("One special character", isValid: newPassword.contains(where: { !$0.isLetter && !$0.isNumber }))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func requirementRow(_ text: String, isValid: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : Color.theme.secondaryText)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
        }
    }
    
    private var passwordForm: some View {
        VStack(spacing: 20) {
            // Current Password
            passwordField(
                title: "Current Password",
                text: $currentPassword,
                isSecure: !showCurrentPassword,
                focusedField: .current,
                showPassword: $showCurrentPassword
            )
            
            // New Password
            passwordField(
                title: "New Password",
                text: $newPassword,
                isSecure: !showNewPassword,
                focusedField: .new,
                showPassword: $showNewPassword
            )
            
            // Confirm Password
            passwordField(
                title: "Confirm New Password",
                text: $confirmPassword,
                isSecure: !showConfirmPassword,
                focusedField: .confirm,
                showPassword: $showConfirmPassword
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func passwordField(
        title: String,
        text: Binding<String>,
        isSecure: Bool,
        focusedField: Field,
        showPassword: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            
            HStack {
                if isSecure {
                    SecureField("Enter password", text: text)
                } else {
                    TextField("Enter password", text: text)
                }
                
                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($focusedField, equals: focusedField)
            .submitLabel(focusedField == .confirm ? .done : .next)
            .onSubmit {
                switch focusedField {
                case .current:
                    self.focusedField = .new
                case .new:
                    self.focusedField = .confirm
                case .confirm:
                    self.focusedField = nil
                }
            }
        }
    }
    
    private func changePassword() {
        focusedField = nil
        isChanging = true
        
        // Validate inputs
        guard !currentPassword.isEmpty else {
            alertMessage = "Error: Please enter your current password"
            showingAlert = true
            isChanging = false
            return
        }
        
        guard isValidPassword(newPassword) else {
            alertMessage = "Error: New password does not meet requirements"
            showingAlert = true
            isChanging = false
            return
        }
        
        guard newPassword == confirmPassword else {
            alertMessage = "Error: New passwords do not match"
            showingAlert = true
            isChanging = false
            return
        }
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // In a real app, you would:
            // 1. Verify current password with backend
            // 2. Update password in backend
            // 3. Update local authentication
            alertMessage = "Password changed successfully"
            showingAlert = true
            isChanging = false
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$&*])(?=.*[a-z]).{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}

#Preview {
    ChangePasswordView()
} 