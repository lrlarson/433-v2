//
//  CredutsView.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/12/25.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Credits")
                    .font(.title2)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("The *4'33\"* application was created for the [John Cage Trust](http://www.johncage.org) by:")
                    Text("[Phil Stone](http://www.pkstonemusic.com) - initial concept and lead iOS programming")
                    Text("[Larry Larson](http://www.larsonassoc.org) - database and web programming")
                    Text("[Didier Garcia](http://cargocollective.com/pixelion) - design consulting")
                    Spacer().frame(height: 10)
                    Text("The project was made possible through the support and guidance of Laura Kuhn, Executive Director of the [John Cage Trust](http://www.johncage.org), and Gene Caprioglio, Vice President for New Music & Rights at [Edition Peters](http://www.edition-peters.com).")
                    Text("*4'33\"* is published by Henmar Press Inc., a division of the [C.F. Peters Group](http://www.edition-peters.com). All rights reserved.")
                    
                    Spacer().frame(height: 20)
                    Text("Cover Image: John Cage (Erlangen, Germany, 1990) Photographer: Erich Malter")
                    Text("Special thanks to Peggy Cosgrave, John and Merce's neighbor for years and years.")
                    Text("Dedicated to Mark Trayle; my friend, bandmate and constant source of inspiration. - PS")
                    Spacer().frame(height: 20)
                 }
                .padding(.horizontal, 24)
                .font(.system(size: 20))
            }
        }
        .padding(.bottom, 16)
    }
}

/*
 <p class="accent_white">The <i>4<span class="accent_blue">'</span>33<span class="accent_blue">"</span> </i>application was created for the <a href="http://www.johncage.org">John Cage Trust</a> by:
 <br />
 <p>  <a href="http://www.pkstonemusic.com">Phil Stone</a>, initial concept and lead iOS programming</p>
 <p> <a href="http://www.larsonassoc.org">Larry Larson</a>, database and web programming</p>
 <p> <a href="http://cargocollective.com/pixelion">Didier Garcia</a>, design consulting</p>
 <br />
 <p>The project was made possible through the support and guidance of Laura Kuhn, Executive Director of the <a href="http://www.johncage.org">John Cage Trust</a>, and Gene Caprioglio, Vice President for New Music & Rights at <a href="http://www.edition-peters.com">Edition Peters.</a></p>
 <p class="accent_white"><i>4<span class="accent_blue">'</span>33<span class="accent_blue">"</span> </i> is published by Henmar Press Inc., a division of the <a href="http://www.edition-peters.com">C.F. Peters Group</a>. All rights reserved.</p>
 <p style="margin-top: 3em; margin-bottom: 4em;">Cover Image <b>John Cage (Erlangen, Germany, 1990)</b>&nbsp;Photographer: Erich Malter</p>
 <p style="margin-top: 3em; margin-bottom: 4em;">Special thanks to Peggy Cosgrave, John and Merce's neighbor for years and years.</p>
 <p style="margin-top: 3em; margin-bottom: 4em;">Dedicated to Mark Trayle; my friend, bandmate and constant source of inspiration. - PS</p>
 <body>
 */


#Preview {
    About433View()
}
