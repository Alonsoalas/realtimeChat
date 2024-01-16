//
//  MainMessageView.swift
//  RealtimeChat
//
//  Created by Alonso Alas on 11/12/23.
//

import SwiftUI
import SDWebImageSwiftUI


// class for fetch real data on firebase -- -- 12 nov 23

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
    
        fetchCurrentuser()
    }
    
    func fetchCurrentuser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
            
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user: ", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "Could not find data"
                return
                
            }
//            self.errorMessage = "\(data.description)"
            
            self.chatUser = .init(data: data)
            
//            self.errorMessage = chatUser.profileImageUrl
            
        }
        
    }
    
//    function to handle sig out users
    
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    
}

struct MainMessageView: View {
    @ObservedObject public var vm = MainMessagesViewModel()
    
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        NavigationView{
            
            VStack {
                // custom nav bar
                customNavBar
                
                messagesView
                
            }
            
        } //End of navigation view
        .overlay(
            newMessageButton(), alignment: .bottom)
        .navigationBarHidden(true)
    }
    
    private var customNavBar: some View {
            HStack(spacing: 16) {
                
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(.label), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                
                VStack(alignment: .leading, spacing: 4) {
                    let email = "\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")"
                    Text(email)
                        .font(.system(size: 24, weight: .bold))
                    
                    HStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 14, height: 14)
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.lightGray))
                    }
                }
                
                Spacer()
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.label))
                }
            }
            .padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("Handle Sign Out")
                        
                        vm.handleSignOut()
                    }),
                    //                        .default(Text("DEFAULT BUTTON")),
                    .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(didCompleteLoginProccess: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentuser()
                })
            }
    }
    
    private var messagesView: some View {
            ScrollView {
                
                ForEach(0..<10, id:\.self) { num in
                    
                    VStack {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    } //end of main vstack
                    Divider()
                        .padding(.vertical, 8)
                } // end of foreach
                .padding(.horizontal)
                
            } //end of ScrollView
            .padding(.bottom, 50)

    }
    
}



struct newMessageButton: View {
    @State var shouldShowNewMessageScreen = false
    @ObservedObject public var vm = MainMessagesViewModel()
    
    var body: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView()
        }
    }
}


struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
            .preferredColorScheme(.dark)
        MainMessageView()
    }
}



