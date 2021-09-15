//
//  AccountsList.swift
//  google-oauth-example
//
//  Created by Koen Vendrik on 2021-09-15.
//

import SwiftUI

struct GoogleProfileCard: View {
    let profile: GoogleProfile
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            AsyncImage(url: URL(string: profile.picture)!) {
                image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {Color.black}

            VStack(alignment: .leading, spacing: 0) {
                Text(profile.given_name+" "+profile.family_name)
                Text(profile.email)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(red: 18 / 255, green: 18 / 255, blue: 18 / 255))
        .cornerRadius(5)
    }
}

struct GoogleAccountsList: View {
    @ObservedObject var googleAuth = GoogleAuth.shared
    
    var body: some View {
        if googleAuth.profiles.count > 0 {
            List {
                ForEach(googleAuth.profiles, id: \.self.email) {
                    profile in
                    GoogleProfileCard(profile: profile)
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation(.easeInOut(duration: 1)) {
                                    GoogleAuth.shared.logOut(profile.sub)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }

        Button("Sign in using Google") {
            googleAuth.signIn() {
                success in
                print(success ? "signed in" : "sign in failed")
            }
        }
    }
}
