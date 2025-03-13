//
//  About433View.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI

struct About433View: View {
    var body: some View {
        VStack {
            HStack {
                Text("4'33\" (1952)")
                    .font(.title2)
            }
            ScrollView {
                VStack(spacing: 16) {
                    Text("*4′33″* is a 3-movement composition by John Cage in which the performer makes no intentional sounds for the duration of the piece – four minutes and thirty-three seconds. Its first performance was given by David Tudor at the Maverick Concert Hall in Woodstock, N.Y., on August 29, 1952.")
                    Text("Cage described *4’33”* as not actually silent, but")
                    Text("“…full of sound, sounds I did not think of beforehand, which I hear for the first time the same time others hear. What we hear is determined by our emptiness, our own receptivity; we receive to the extent we are empty to do so. If one is full or in the course of its performance becomes full of an idea, for example, that this piece is a trick for shock and bewilderment, then it is just that. However, nothing is single or uni-dimensional. This is an action among the ten thousand: it moves it all directions and will be received in unpredictable ways. These will vary from shock and bewilderment to quietness of mind and enlightenment….If one imagines that I have intended any one of these responses he will have to imagine that I have intended all of them. Something like faith must take over in order that we live affirmatively in the totality we live in.”\n\n(John Cage to Helen Wolff, April 1954)")
                        .padding(.horizontal, 24)
                        .font(.system(size: 16))
                 }
                .padding(.horizontal, 24)
            }
        }
        .font(.system(size: 18))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    About433View()
}
