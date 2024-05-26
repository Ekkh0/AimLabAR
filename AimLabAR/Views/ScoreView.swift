//
//  ScoreView.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 21/05/24.
//

import SwiftUI

struct ScoreView: View {
    @State var addNewScoreState: Bool
    @Binding var currPage: String
    @Binding var score: Int
    @State var scores: [Score] = {
        if let data = UserDefaults.standard.data(forKey: "ScoresMem"),
           let decoded = try? JSONDecoder().decode([Score].self, from: data) {
            return decoded
        }
        return []
    }()
    @State var name: String = ""
    @StateObject var soundManager = SoundManager()
    
    var body: some View {
        VStack{
            if !addNewScoreState{
                HStack {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.orange)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .onTapGesture {
                            currPage = "Menu"
                        }
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.leading, 60)
            }
            Text("Scores")
                .font(.system(size: 45))
                .fontWeight(.bold)
                .padding([.top], 40)
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .fill(.shadow(.inner(radius: 10)))
                    .zIndex(1)
                    .foregroundColor(Color(hex: 0xFFFAF1))
                    .padding(30)
                ScrollView{
                    ForEach(0..<(scores.count), id: \.self){i in
                        HStack{
                            Text("\(i+1)")
                                .foregroundColor(.orange)
                                .font(GroteskBold(40))
                            Text("\(scores[i].name)")
                                .foregroundColor(Color(hex:0xEF652A))
                                .font(GroteskBold(40))
                            Spacer()
                            Image(systemName: "scope")
                                .foregroundColor(.orange)
                                .font(.system(size: 45))
                                .fontWeight(.bold)
                            Text("\(scores[i].score)")
                                .foregroundColor(.orange)
                                .font(.system(size: 45))
                                .fontWeight(.bold)
                        }
                        .border(width: 2, edges: [.bottom], color: .orangeCustom)
                    }
                }
                .zIndex(2)
                .padding(60)
            }
            .frame(width: 700)
            .background(.orangeCustom)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 5)
            .padding([.leading, .trailing, .bottom], 40)
            if addNewScoreState {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.orangeCustom, lineWidth: 10)
                        .fill(Color(hex: 0xFFFAF1))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    // Score input
                    VStack {
                        TextField("", text: $name)
                            .placeholder(when: name.isEmpty){
                                Text("Input Name...")
                                    .foregroundColor(Color(hex:0xEF652A))
                                    .opacity(0.5)
                                    .multilineTextAlignment(.center)
                                    .font(GroteskBold(50))
                            }
                            .padding()
                            .font(GroteskBold(50))
                            .border(width: 5, edges: [.bottom], color: .orangeCustom)
                        HStack {
                            Image(systemName: "scope")
                                .foregroundColor(.orange)
                                .font(.system(size: 45))
                                .fontWeight(.bold)
                            
                            Text("\(score)")
                                .foregroundColor(Color(hex:0xEF652A))
                                .font(GroteskBold(70))
                                .fontWeight(.bold)
                                .padding(.trailing, 10)
                            
                            Image(systemName: "arrowshape.right.circle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 45))
                        }
                        .padding(.bottom, 10)
                        .onTapGesture {
                            let scoreTemp = Score(name: name, score: score)
                            scores.append(scoreTemp)
                            if let encoded = try? JSONEncoder().encode(scores) {
                                UserDefaults.standard.set(encoded, forKey: "ScoresMem")
                            }
                            addNewScoreState = false
                        }
                    }
                }
                .frame(width: 350, height: 114)
                .zIndex(3)
                .padding(.bottom, 60)
                .padding(.top, 30)
            }
        }
        .frame(width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
        .background(Image("Background")
            .resizable()
            .rotationEffect(.degrees(90))
            .aspectRatio(contentMode: .fill)
        )
        .onAppear {
            if addNewScoreState{
                soundManager.playSound(soundName: "Alarm", type: "wav", duration: 5)
            }
            scores.sort { $0.score > $1.score }
        }
    }
}
