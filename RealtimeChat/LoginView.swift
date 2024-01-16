//
//  ContentView.swift
//  RealtimeChat
//
//  Created by Alonso Alas on 8/19/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    let didCompleteLoginProccess: () -> ()
    
    @State var isLogginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var emailIsValid = true
    
    @State var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLogginMode, label: Text("Picker Here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    if !isLogginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .scaledToFill()
                                        .cornerRadius(50)
                                }else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.black)
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
                            
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)

                            .onChange(of: email) { newValue in

                                if(newValue.range(of:"^\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$", options: .regularExpression) != nil) {

                                    self.emailIsValid = true

                                    print("valid")

                                } else {

                                    self.emailIsValid = false

                                    print("invalid")

                                }

                            }

                            .foregroundColor(emailIsValid ? Color.green : Color.red)
                        
                        Divider()
                            .padding(.top, -15)
                        
                        SecureField("Password", text: $password)
                    } //end of group
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.top, 20)
                    .font(.system(size: 18, weight: .bold))
                    
                    Divider()
                    Button {
                        handleAction()
                    } label: {
                        HStack {
//                            Spacer()
                            SocialLoginButton(image: Image(uiImage: #imageLiteral(resourceName: "google")), text: Text(!isLogginMode ? "Create account" : "Log In"))
                        }
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                    
                } //End of VSTACK
                .padding()
//                .background(Color("Bg2"))
                .cornerRadius(25)
            } //end of scroll view
            .navigationTitle(!isLogginMode ? "Create Account" : "Log In")
            .background(Color("Bg2"))
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLogginMode {
            loginUser()
        } else {
            createNewUser()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewUser() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            
            if let err = err {
                print("Failed to create user: ", err)
                self.loginStatusMessage = "Failed to create user: \(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.persistImageToStorage()
            
        }
    } // end of register
    
    private func persistImageToStorage() {
        //        let filename = UUID().uuidString
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        
        FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData, metadata: nil) {metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL{ url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve dowloadURL: \(err)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                
                guard let url = url else {return}
                self.storeUserInformation(imageProfileUrl: url)
            }
            
        }
    }
    
    
    private func storeUserInformation(imageProfileUrl: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
            
            print("success")
            self.didCompleteLoginProccess()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login with user: ", err)
                self.loginStatusMessage = "Failed to login with user: \(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Successfully login with user: \(result?.user.uid ?? "")"
            print("Successfully with user: \(result?.user.uid ?? "")")
            
            self.didCompleteLoginProccess()
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProccess: {

        })
    }
}
