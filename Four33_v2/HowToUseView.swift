//
//  HowToUseView.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI

struct HowToUseView: View {
    var body: some View {
        VStack {
            Text("How to use").font(.title2)
            ScrollViewReader { value in
                ScrollView {
                    Text("This application allows you to record and share personal performances of John Cage's *4'33\"*.")
                        .padding(.bottom, 20)
                        .padding(.horizontal, 10)
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 16) {
                            Button("\u{2022} Recording") {
                                withAnimation {
                                    value.scrollTo(1, anchor: .top)
                                }
                            }
                            Button("\u{2022} Playing") {
                                withAnimation {
                                    value.scrollTo(2, anchor: .top)
                                }
                            }
                            Button("\u{2022} Library (saved recordings)") {
                                withAnimation {
                                    value.scrollTo(3, anchor: .top)
                                }
                            }
                            Button("\u{2022} World of 4'33\" (sharing)") {
                                withAnimation {
                                    value.scrollTo(4, anchor: .top)
                                }
                            }
                            .padding(.bottom, 20)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recording").font(.title)
                                Text("Select the **Record & Play** tab. Press the **Record** button to start a new performance. Three movements, (of lengths matching David Tudor's 1952 Woodstock, NY première of *4'33\"*) will be recorded, with 10 second breaks in between.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("You may stop the recording at any time -- partial performances are perfectly fine -- but pressing **Record** again will start a new recording. Also note that only complete recordings are accepted for upload to johncage.org.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("When the recording is complete (or inadvertently stopped before completion\u{002A}), you will be asked if you wish to save it. This is your only chance to do so; if you choose not to save, it will be erased. Saved recordings may be viewed and loaded on the *Library* screen.")
                                    .font(.system(size: 18))
                                Text("\u{002A}A phone call or pre-set alarm, for example, can stop the recording, which then cannot be resumed; however, a partial recording may be saved.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer().frame(height: 20)
                            }.id(1)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Playing").font(.title)
                                Text("On the **Record & Play** screen, press the **Play** button. Playback may be paused at any time by pressing **Pause**, and resumed by hitting **Play** again. You may rewind the recording to the beginning by pressing the **Reset** button.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("During both recording and playback, progress through the three movements is indicated by the three bars near the bottom of the screen.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer().frame(height: 20)
                            }.id(2)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Library").font(.title)
                                Text("This screen lists all the recordings you have saved, and one built-in recording (always listed last, which can't be deleted, renamed or uploaded).")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Tapping on a recording title displays a window showing where (assuming Location Services are enabled) and when the recording was made. Also on this screen are three buttons:")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                VStack(spacing: 16) {
                                    Text("Play").font(.title3)
                                    Text("Press this, and after a brief pause while the selected recording loads, the display will switch to the **Record & Play** screen and begin playback")
                                        .font(.system(size: 18))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("Rename").font(.title3)
                                    Text("If you wish to change the name of the currently-selected recording, tap the **Rename** button. You will be prompted for a new name, and returned to the Library, where the new name will be displayed.")
                                        .font(.system(size: 18))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("Upload").font(.title3)
                                    Text("You may upload your favorite recordings to be shared with the world at (http://www.johncage.org)[www.johncage.org]. Note that incomplete recordings or ones with no location information will not be eligible for upload. Tap the **Upload** button, confirm that you wish to upload your recording, then enter your name (or a pseudonym) when prompted. Your recording will then be uploaded to johncage.org. Shortly after that, you should be able to find it on the map of the *World of 4'33\" screen (see below).")
                                        .font(.system(size: 18))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("*Please note that you are responsible for the content of your recordings -- any use of copyrighted or offensive material is not allowed. The Cage Trust reserves the right to remove any recording for any reason.*")
                                        .font(.system(size: 18))
                                        .fixedSize(horizontal: false, vertical: true)
                                }.padding(30)
                                Spacer().frame(height: 20)
                                Text("If you press the **Edit** button at the top of the \"Library\" screen, **delete** buttons will appear by each recording; you can make any desired deletions, and then press **Done** to make the **delete** buttons disappear.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer().frame(height: 20)
                            }.id(3)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("World of 4'33\"").font(.title)
                                Text("On this screen, you can listen to recordings of 4/33\" performances from all over the world, including ones that you have uploaded. Browse the global map by scrolling and zooming; each pin on the map represents an uploaded recording; tap a pin to display a detail balloon, and in that balloon, you can tap the **Play** button to play the recording.")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("A set of playback information and controls are displayed at the bottom of the screen after the first selection is made. As in the **Record & Play** screen, playback may be paused at any time by pressing **Pause**, and resumed by hitting **Play** again. Tap the **purple pin** to re-center the map on the current recording (this is handy if you've browsed to somewhere else on the map and forgotten where the current recording is located).")
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer().frame(height: 20)
                            }.id(4)
                        }
                    }
                    .padding(.horizontal, 24)
                }
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
