//
//  InfoView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI


struct InfoView: View {
    
    var body: some View {
        VStack {
            Text("Information")
                .font(.title2)
                .padding([.bottom], 40)
        }
        NavigationView {
            HStack {
                Spacer()
                VStack (alignment: .leading, spacing: 36) {
                    NavigationLink("How to use", destination: HowToUseView())
                        .font(.title3)
                    NavigationLink("About John Cage", destination: AboutJohnCageView())
                        .font(.title3)
                    NavigationLink("About 4'33\"", destination: About433View())
                        .font(.title3)
                    NavigationLink("Credits", destination: About433View())
                        .font(.title3)
                    Spacer()
                }
                Spacer()
            }.font(.body)
        }
    }
}


#Preview {
    InfoView()
}
