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
            NavigationStack {
                HStack {
                    Spacer()
                    VStack (alignment: .leading, spacing: 36) {
                        NavigationLink("How to use", destination: HowToUseView())
                        NavigationLink("About John Cage", destination: AboutJohnCageView())
                        NavigationLink("About *4\'33\"*", destination: About433View())
                        NavigationLink("Credits", destination: CreditsView())
                        Spacer()
                    }.font(.title2)
                        .padding([.top], 40)
                    Spacer()
                }.font(.body)
            }
        }
    }
}
