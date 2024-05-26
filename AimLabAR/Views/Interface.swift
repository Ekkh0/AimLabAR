//
//  Menu.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 20/05/24.
//

import SwiftUI

struct Interface: View {
    @State var currPage: String = "Menu"
    @State var score: Int = 0
    
    var body: some View {
        if currPage == "Game"{
            GameView(score: $score, currPage: $currPage)
        }else if currPage == "Menu"{
            MenuView(currPage: $currPage)
        }else if currPage == "NewScores"{
            ScoreView(addNewScoreState: true, currPage: $currPage, score: $score)
        }else if currPage == "ViewScores"{
            ScoreView(addNewScoreState: false, currPage: $currPage, score: $score)
        }
    }
}
