import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case fullName, email, phone
    }
    
    // Dummy initial data - replace with actual user data
    init() {
        _fullName = State(initialValue: "Mobile App Developer")
        _email = State(initialValue: "kingpinfx1@gmail.com")
        _phoneNumber = State(initialValue: "+234 123 456 7890")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Image Section
                        profileImageSection
                        
                        // Form Fields
                        formFields
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .alert("Profile Update", isPresented: $showingAlert) {
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
    
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            Button(action: { showingImagePicker = true }) {
                ZStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color.theme.accent)
                    }
                    
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        )
                }
            }
            
            Text("Tap to change photo")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
        }
    }
    
    private var formFields: some View {
        VStack(spacing: 20) {
            // Full Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                TextField("Enter your full name", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .fullName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
            }
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .phone
                    }
            }
            
            // Phone Number
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                TextField("Enter your phone number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phone)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private func saveProfile() {
        focusedField = nil
        isSaving = true
        
        // Validate inputs
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Error: Please enter your full name"
            showingAlert = true
            isSaving = false
            return
        }
        
        guard isValidEmail(email) else {
            alertMessage = "Error: Please enter a valid email address"
            showingAlert = true
            isSaving = false
            return
        }
        
        guard isValidPhoneNumber(phoneNumber) else {
            alertMessage = "Error: Please enter a valid phone number"
            showingAlert = true
            isSaving = false
            return
        }
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // In a real app, you would:
            // 1. Upload profile image if changed
            // 2. Update user profile in backend
            // 3. Update local user data
            alertMessage = "Profile updated successfully"
            showingAlert = true
            isSaving = false
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegEx = "^[+]?[0-9]{10,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone.replacingOccurrences(of: " ", with: ""))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    EditProfileView()
} 