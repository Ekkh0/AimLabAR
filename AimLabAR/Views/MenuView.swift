//
//  MenuView.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 21/05/24.
//

import SwiftUI

struct MenuView: View {
    @Binding var currPage: String
    @StateObject var soundManager = SoundManager()
    
    var body: some View {
        VStack{
            Image("Logo")
                .resizable()
                .frame(width: 700, height: 700)
            Text("Start Game")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .padding([.trailing, .leading], 30)
                .frame(height: 75)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.orangeCustom, lineWidth: 10)
                        .fill(Color(hex: 0xFFFAF1))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                )
                .onTapGesture {
                    playButtonClickSound()
                    currPage = "Game"
                }
            Text("View Scores")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .padding([.trailing, .leading], 30)
                .frame(height: 75)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.orangeCustom, lineWidth: 10)
                        .fill(Color(hex: 0xFFFAF1))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                )
                .padding(.top, 30)
                .onTapGesture {
                    soundManager.playSound(soundName: "Button1", type: "mp3", duration: 3)
                    playButtonClickSound()
                    currPage = "ViewScores"
                }
        }
        .frame(width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
        .background(Image("Background")
            .resizable()
            .rotationEffect(.degrees(90))
            .aspectRatio(contentMode: .fill)
        )
    }
    
    func playButtonClickSound(){
        let randNum = Int.random(in: 0...3)
        switch randNum{
        case 0:
            soundManager.playSound(soundName: "Button1", type: "mp3", duration: 1)
        case 1:
            soundManager.playSound(soundName: "Button2", type: "mp3", duration: 1)
        case 2:
            soundManager.playSound(soundName: "Button3", type: "mp3", duration: 1)
        case 3:
            soundManager.playSound(soundName: "Button4", type: "mp3", duration: 1)
        default:
            break
        }
    }
}

