//
//  File.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation
import AVFoundation

class Audio {
    var player: AVAudioPlayer?
    
    func playSound(file: String) {
        let url = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer.init(contentsOf: url!)
            player?.play()
        } catch {
            print("Sound not found")
        }
    }
}
