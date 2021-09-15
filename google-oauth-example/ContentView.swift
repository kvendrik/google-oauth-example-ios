//
//  ContentView.swift
//  google-oauth-example
//
//  Created by Koen Vendrik on 2021-09-15.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var googleAuth = GoogleAuth.shared
    @State var ready = false

    var body: some View {
        Group {
            if ready {
                GoogleAccountsList()
            } else {
                ProgressView()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: handleAppear)
    }
    
    private func handleAppear() {
        GoogleAuth.shared.loadSavedAuthorizations() {
            withAnimation(.easeInOut(duration: 1)) {
                self.ready = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
