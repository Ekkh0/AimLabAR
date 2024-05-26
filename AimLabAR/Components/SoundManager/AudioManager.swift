//
//  AudioManager.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 01/05/24.
//

import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    func playSound(soundName: String, type: String, duration: TimeInterval) {
        if let path = Bundle.main.url(forResource: soundName, withExtension: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer?.play()
                
                // Start a timer to stop playback after the specified duration
                timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    self.stopPlayback()
                }
            } catch {
                print("Error: Could not find and play the sound file.")
            }
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        timer?.invalidate()
    }
}
