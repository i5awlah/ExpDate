//
//  SoundManager.swift
//  ExpDate
//
//  Created by Khawlah on 07/12/2022.
//

import AVKit

class SoundManager {
    
    static let shared = SoundManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "scanner-beep", withExtension: ".mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
