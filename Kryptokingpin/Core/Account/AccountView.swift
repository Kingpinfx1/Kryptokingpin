import SwiftUI

struct AccountView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var showingEditProfile = false
    @State private var showingChangePassword = false
    @State private var showingNotifications = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    // Placeholder user data - replace with actual user data model later
    private let userName = "Mobile App Developer"
    private let userEmail = "kingpinfx1@gmail.com"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Section
                        profileSection
                        
                        // Settings Section
                        settingsSection
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            logoutButton
                            deleteAccountButton
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(themeManager.colorScheme)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showingNotifications) {
                // Placeholder for Notifications View
                Text("Notifications View")
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    // Handle logout action
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle delete account action
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile Image
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color.theme.accent)
                .background(
                    Circle()
                        .fill(Color.theme.background)
                        .shadow(color: Color.theme.accent.opacity(0.2), radius: 10)
                )
            
            // User Info
            VStack(spacing: 8) {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.accent)
                
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
            }
            
            // Edit Profile Button
            Button(action: { showingEditProfile = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.accent)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
        )
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            // Settings Header
            HStack {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Spacer()
            }
            .padding(.bottom, 10)
            
            // Settings Buttons
            VStack(spacing: 0) {
                settingsButton(
                    title: "Change Password",
                    icon: "lock.fill",
                    action: { showingChangePassword = true }
                )
                
                Divider()
                    .padding(.leading)
                
                settingsButton(
                    title: "Notifications",
                    icon: "bell.fill",
                    action: { showingNotifications = true }
                )
                
                Divider()
                    .padding(.leading)
                
                // Theme Toggle
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(Color.theme.accent)
                        .frame(width: 25)
                    
                    Text("Dark Mode")
                        .foregroundColor(Color.theme.accent)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { themeManager.colorScheme == .dark },
                        set: { _ in themeManager.toggleTheme() }
                    ))
                    .labelsHidden()
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.theme.background)
                    .shadow(color: Color.theme.accent.opacity(0.1), radius: 5)
            )
        }
    }
    
    private func settingsButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.theme.accent)
                    .frame(width: 25)
                
                Text(title)
                    .foregroundColor(Color.theme.accent)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
        }
    }
    
    private var logoutButton: some View {
        Button(action: { showingLogoutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Logout")
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.1))
            )
        }
    }
    
    private var deleteAccountButton: some View {
        Button(action: { showingDeleteAccountAlert = true }) {
            HStack {
                Image(systemName: "person.crop.circle.badge.minus")
                Text("Delete Account")
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    AccountView()
} 