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
                Text("About 4'33\"")
                    .font(.title2)
            }
            ScrollView {
                VStack(spacing: 16) {
                    Text("*4′33″* is a 3-movement composition by John Cage in which the performer makes no intentional sounds for the duration of the piece – four minutes and thirty-three seconds. Its first performance was given by David Tudor at the Maverick Concert Hall in Woodstock, N.Y., on August 29, 1952.")
                        .font(.system(size: 18))
                    Text("Cage described *4’33”* as not actually silent, but “…full of sound, sounds I did not think of beforehand, which I hear for the first time the same time others hear. What we hear is determined by our emptiness, our own receptivity; we receive to the extent we are empty to do so. If one is full or in the course of its performance becomes full of an idea, for example, that this piece is a trick for shock and bewilderment, then it is just that. However, nothing is single or uni-dimensional. This is an action among the ten thousand: it moves it all directions and will be received in unpredictable ways. These will vary from shock and bewilderment to quietness of mind and enlightenment….If one imagines that I have intended any one of these responses he will have to imagine that I have intended all of them. Something like faith must take over in order that we live affirmatively in the totality we live in.” (John Cage to Helen Wolff, April 1954)")
                        .font(.system(size: 18))
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

/*
 <html>
 <head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
   <meta http-equiv="Content-Style-Type" content="text/css">
   <meta name='viewport' content='width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no' />
      
   <title>about433</title>
   <style type="text/css">
       
     body {background-color: #000000; padding: 10px;}
     p {margin: 0 0 20px 0; font: 18px Georgia; line-height: 26px; color: #bababa; }
    .header {margin: 0; font: 17px Helvetica Neue, Arial; line-height: 28px; color: #007aff; font-weight: bold; text-transform: uppercase; letter-spacing: .1em;}
    .accent {color: #fff; }
    .accent_blue { color: #007aff; }
    a { color: white; text-decoration: none; font-style: italic; border-bottom: 1px solid #007aff; }

   </style>
 </head>
 <body>
 */


#Preview {
    About433View()
}
