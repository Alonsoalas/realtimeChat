//
//  AuthView.swift
//  RealtimeChat
//
//  Created by Alonso Alas on 10/31/23.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
       SocialLoginButton(image: Image(uiImage: #imageLiteral(resourceName: "google")), text: Text("Hello"))
    }
}



struct SocialLoginButton: View {
    var image: Image
    var text: Text
    
    var body: some View {
        HStack {
            image
                .padding(.horizontal)
            Spacer()
            text
                .font(.title2)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(50.0)
        .shadow(color: Color.black.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
    }
}
