//
//  CreateNewMessageView.swift
//  RealtimeChat
//
//  Created by Alonso Alas on 11/15/23.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUser()
    }
    
    private func fetchAllUser() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(.init(data: data))
                }
            })
            
            
            //            self.errorMessage = "Fetched users succesfully"
        }
    }
    
}

struct CreateNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                messagesView
            }
            .navigationBarTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            Text(vm.errorMessage)
            
            ForEach(vm.users) { user in
                
                Button{
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    
                    HStack(spacing: 16) {
                        
                        WebImage(url: URL(string: user.profileImageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                            .shadow(radius: 5)
                        
                        VStack(alignment: .leading) {
                            Text("\(user.email)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(.label))
                        }
                        Spacer()
                        
                    }//end of main hstack
                    .padding(.horizontal)
                }
                Divider()
                    .padding(.vertical, 8)
            } // end of foreach
            
            
        } //end of ScrollView
        
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //        CreateNewMessageView()
        MainMessageView()
    }
}
