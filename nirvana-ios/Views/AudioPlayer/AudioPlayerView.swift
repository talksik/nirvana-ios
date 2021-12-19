//
//  AudioPlayer.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    @State var player = AVPlayer()
    
    var audioUrl: URL? = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
    
    var body: some View {
        Text("we should here the music play")
        .onAppear() {
            player = AVPlayer(url: audioUrl!)
            player.play()
        }
    }
}


struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
