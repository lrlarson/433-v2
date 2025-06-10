//
//  HowToUseView.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI

/* Button("to top") {
 withAnimation{
     value.scrollTo(0, anchor: .top)
 }
}
*/
struct HowToUseView: View {
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                    Text("How to use").font(.title2).id("top")
                    Spacer().frame(height: 10)
                    Text("This application allows you to record and share personal performances of John Cage's *4'33\"*.")
                        .padding(.bottom, 20)
                        .padding(.horizontal, 10)
                        .font(.system(size: 18))
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 16) {
                                Button("\u{2022} Recording") {
                                    withAnimation {
                                        value.scrollTo("recording", anchor: .top)
                                    }
                                }
                                Button("\u{2022} Playing") {
                                    withAnimation {
                                        value.scrollTo("playing", anchor: .top)
                                    }
                                }
                                Button("\u{2022} Library (saved performances)") {
                                    withAnimation {
                                        value.scrollTo("library", anchor: .top)
                                    }
                                }
                                Button("\u{2022} World of *4'33\"* (sharing)") {
                                    withAnimation {
                                        value.scrollTo("world", anchor: .top)
                                    }
                                }
                                .padding(.bottom, 20)
                            }.font(.title3)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recording").font(.title)
                                Text("Select the **Record & Play** tab. Press the **Record** button to start a new performance. Three movements, (of lengths matching David Tudor's 1952 Woodstock, NY première of *4'33\"*) will be recorded, with 10 second breaks in between.")
                                Text("You may stop recording at any time -- partial performances are perfectly fine -- but pressing **Record** again will start a new performance. Also note that only complete performances are accepted for upload to johncage.org.")
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("When the performance is complete (or inadvertently stopped before completion\u{002A}), you will be asked if you wish to save it. This is your only chance to do so; if you choose not to save, it will be erased. Saved performances may be viewed and loaded on the *Library* screen.")
                                 Text("\u{002A}A phone call or pre-set alarm, for example, can stop the performance, which then cannot be resumed; however, a partial performance may be saved.")
                                Spacer().frame(height: 20)
                            }.id("recording")
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Playing").font(.title)
                                Text("On the **Record & Play** screen, press the **Play** button. Playback may be paused at any time by pressing **Pause**, and resumed by hitting **Play** again. You may rewind the recording to the beginning by pressing the **Reset** button.")
                                Text("During both recording and playback, progress through the three movements is indicated by the three bars near the bottom of the screen.")
                                Spacer().frame(height: 20)
                            }.id("playing")
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Library").font(.title)
                                Text("This screen lists all the performances you have saved, and one built-in performance (\"Cage's NYC Apartment\", which can't be deleted, renamed or uploaded).")
                                 Text("Tapping on a performance title displays a window showing where (assuming Location Services are enabled) and when the recording was made. Also on this screen are three buttons:")
                                 VStack(spacing: 16) {
                                    Text("Play").font(.title3)
                                    Text("Press this, and after a brief pause while the selected performance loads, the display will switch to the **Record & Play** screen and begin playback")
                                    Text("Rename").font(.title3)
                                    Text("If you wish to change the name of the currently-selected performance, tap the **Rename** button. You will be prompted for a new name for the performance.")
                                    Text("Upload").font(.title3)
                                    Text("You may upload your favorite performances to be shared with the world at [johncage.org](http://www.johncage.org). Note that incomplete performance or ones with no location information will not be eligible for upload. Tap the **Upload** button, confirm that you wish to upload your performance, then enter your name (or a pseudonym) when prompted. Your performance will then be uploaded to johncage.org. Shortly after that, you should be able to find it on the map of the World of *4'33\"* screen (see below).")
                                    Text("*Please note that you are responsible for the content of your performances -- any use of copyrighted or offensive material is not allowed. The Cage Trust reserves the right to remove any performance for any reason.*")
                                 }.padding(30)
                                Spacer().frame(height: 4)
                                Spacer().frame(height: 20)
                            }.id("library")
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("World of *4'33\"*").font(.title)
                                Text("On this screen, you can listen to recordings of *4'33\"* performances from all over the world, including ones that you have uploaded. Browse the global map by scrolling and zooming; each pin on the map represents an uploaded recording; tap a pin to display a detail balloon, and in that balloon, you can tap the **Play** button to play the recording.")
                                Text("A set of playback information and controls are displayed at the bottom of the screen after the first selection is made. As in the **Record & Play** screen, playback may be paused at any time by pressing **Pause**, and resumed by hitting **Play** again. Tap the **purple pin** to re-center the map on the current recording (this is handy if you've browsed to somewhere else on the map and forgotten where the current recording is located).")
                                Spacer().frame(height: 20)
                            }.id("world")
                        }
                    }
                    .padding(.horizontal, 24)
                    .font(.system(size: 18))
                }
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    About433View()
}
