//
//  InfoView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI


struct TableItem: Identifiable {
    let id = UUID()
    let title: String
    let action: String
}

struct InfoView: View {
    
    var body: some View {
        VStack {
            Text("Information")
                .font(.title2)
                .padding([.bottom], 40)
        }
        HStack {
            Spacer()
            VStack (alignment: .leading, spacing: 36) {
                Button(action: {
                    print("Button pressed")
                }) {
                    Text("How to use")
                }.buttonStyle(.borderless)
                
                Button(action: {
                    print("Button pressed")
                }) {
                    Text("About John Cage")
                }.buttonStyle(.borderless)
                
                Button(action: {
                    print("Button pressed")
                }) {
                    Text("About 4'33\"")
                }.buttonStyle(.borderless)
                
                Button(action: {
                    print("Button pressed")
                }) {
                    Text("Credits")
                }.buttonStyle(.borderless)
                Spacer()
            }
            Spacer()
        }.font(.title3)
    }
}


#Preview {
    InfoView()
}
