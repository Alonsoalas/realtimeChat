//
//  ContentView.swift
//  RealtimeChat
//
//  Created by Alonso Alas on 8/19/23.
//

import SwiftUI
import Firebase

class FirebaseManager: NSObject {
    let auth: Auth
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        
        super.init()
    }
}

struct LoginView: View {
    
    @State var isLogginMode = false
    @State private var email = ""
    @State private var password = ""

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
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    } //end of group
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(!isLogginMode ? "Create account" : "Log In")
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .font(.system(size: 17,weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                    
                    
                } //End of VSTACK
                .padding()
            } //end of scroll view
            .navigationTitle(!isLogginMode ? "Create Account" : "Log In")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleAction() {
        if isLogginMode {
            loginUser()
        } else {
            createNewUser()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewUser() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            
            if let err = err {
                print("Failed to create user: ", err)
                self.loginStatusMessage = "Failed to create user: \(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            print("Successfully created user: \(result?.user.uid ?? "")")
        }
    } // end of register
    
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
                
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
