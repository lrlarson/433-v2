//
//  AboutJohnCageView.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI

struct AboutJohnCageView: View {
    var body: some View {
        VStack {
            HStack {
                Text("About John Cage")
                    .font(.title2)
            }
            ScrollView {
                VStack(spacing: 16) {
                    Text("**John Cage** (1912-1992) was a singularly inventive and much beloved American composer, writer, philosopher, and visual artist. Beginning around 1950, he departed from the pragmatism of precise musical notation and circumscribed ways of performance. His principal contribution to the history of music is his systematic establishment of the principle of indeterminacy: by adapting Zen Buddhist practices to composition and performance, Cage succeeded in bringing both authentic spiritual ideas and a liberating attitude of play to the enterprise of Western art.")
                    Text("His most enduring work is his notoriously tacet *4′33\"* (1952). Encouraging the ultimate freedom in musical expression, the work’s three movements were indicated (in its premier performance) by the pianist’s closing and reopening of the piano key cover, during which no sounds are intentionally produced. It was first performed by Cage’s long-time friend and associate, David Tudor, at the Maverick Concert Hall in Woodstock, N.Y. on Aug. 29, 1952. A decade later, Cage would create a second \"silent\" piece, *0’00\"*, “to be played in any way by anyone,” which he dedicated to his friend Yoko Ono and presented for the first time in Tokyo on Oct. 24, 1962.")
                 }
                .padding(.horizontal, 24)
                .font(.system(size: 18))
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    About433View()
}
