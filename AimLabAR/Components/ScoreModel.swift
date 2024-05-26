//
//  ScoreModel.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 21/05/24.
//

import Foundation
import SwiftData

class Score: Codable{
    var name: String
    var score: Int
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}
