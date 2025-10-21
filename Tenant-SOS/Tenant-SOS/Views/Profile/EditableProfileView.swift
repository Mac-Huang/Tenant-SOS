import SwiftUI
import PhotosUI

struct EditableProfileView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss

    @State private var homeState: String = ""
    @State private var frequentStates: String = ""
    @State private var housingStatus: String = ""
    @State private var hasDriversLicense: Bool = false
    @State private var employmentType: String = ""
    @State private var notificationPreference: String = ""
    @State private var showingSaveAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false

    let states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]

    let housingOptions = ["Renter", "Owner", "Temporary", "Other"]
    let employmentOptions = ["Full-time", "Part-time", "Self-employed", "Student", "Retired", "Other"]
    let notificationOptions = ["immediate", "daily", "weekly", "off"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                            }

                            PhotosPicker(selection: $selectedPhotoItem,
                                       matching: .images,
                                       photoLibrary: .shared()) {
                                Text("Change Photo")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                guard let newItem else {
                                    profileImage = nil
                                    return
                                }

                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        profileImage = image
                                        saveImageToUserDefaults(image)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }

                Section("Location Information") {
                    Picker("Home State", selection: $homeState) {
                        Text("Select State").tag("")
                        ForEach(states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Frequent States")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., NY, CA, TX (comma separated)", text: $frequentStates)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                    }
                }

                Section("Personal Information") {
                    Picker("Housing Status", selection: $housingStatus) {
                        Text("Select Status").tag("")
                        ForEach(housingOptions, id: \.self) { option in
                            Text(option).tag(option.lowercased())
                        }
                    }

                    Toggle("Driver's License", isOn: $hasDriversLicense)

                    Picker("Employment Type", selection: $employmentType) {
                        Text("Select Type").tag("")
                        ForEach(employmentOptions, id: \.self) { option in
                            Text(option).tag(option.lowercased())
                        }
                    }
                }

                Section("Notification Preferences") {
                    Picker("Notification Frequency", selection: $notificationPreference) {
                        ForEach(notificationOptions, id: \.self) { option in
                            Text(option.capitalized).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been successfully updated.")
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }

    private func loadCurrentProfile() {
        homeState = userProfileManager.homeState
        frequentStates = userProfileManager.frequentStates.joined(separator: ", ")
        housingStatus = userProfileManager.housingStatus
        hasDriversLicense = userProfileManager.hasDriversLicense
        employmentType = userProfileManager.employmentType
        notificationPreference = userProfileManager.notificationPreference

        // Load saved profile image
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }

    private func saveImageToUserDefaults(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "profileImage")
        }
    }

    private func saveProfile() {
        userProfileManager.homeState = homeState
        userProfileManager.frequentStates = frequentStates
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        userProfileManager.housingStatus = housingStatus
        userProfileManager.hasDriversLicense = hasDriversLicense
        userProfileManager.employmentType = employmentType
        userProfileManager.notificationPreference = notificationPreference

        userProfileManager.saveProfile()
        showingSaveAlert = true
    }
}
