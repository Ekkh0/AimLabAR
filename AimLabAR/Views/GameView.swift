//
//  ContentView.swift
//  AimLabAR
//
//  Created by Dharmawan Ruslan on 16/05/24.
//

import SwiftUI
import ARKit
import SceneKit
import RealityKit

struct GameView : View {
    @State var targetCount: Int = Int.random(in: 1...4)
    @State var timer: Int = 60
    @State var ammo: Int = 8
    @State var reloading: Bool = false
    @Binding var score: Int
    @Binding var currPage: String
    @State var reloadTime: Double = 2
    @State var scopeSize: CGFloat = 750
    @StateObject var soundManager = SoundManager()
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack{
            ARViewContainer(targetCount: $targetCount, ammo: $ammo, score: $score, reloading: $reloading)
                .frame(width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
                .zIndex(1)
            ZStack{
                BackdropView().blur(radius: 5, opaque: true)
                Circle()
                    .frame(width: scopeSize, height: scopeSize)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .allowsHitTesting(false)
            .zIndex(2)
            Image("Crosshair")
                .resizable()
                .frame(width: scopeSize*1.1, height: scopeSize*1.1)
                .aspectRatio(contentMode: .fit)
                .allowsHitTesting(false)
                .zIndex(3)
            Circle()
                .stroke(.black, lineWidth: 30)
                .frame(width: scopeSize, height: scopeSize)
                .allowsHitTesting(false)
                .zIndex(3)
            if reloading{
                HStack{
                    Image("Bullet")
                        .resizable()
                        .frame(width: 70, height: 70)
                    Text("Reloading...")
                        .foregroundColor(.white)
                        .font(GroteskBold(50))
                }
                    .padding()
                    .background(.black)
                    .cornerRadius(15)
                    .offset(y: 425)
                    .zIndex(3)
                    .allowsHitTesting(false)
                Circle()
                    .trim(from: 0, to: CGFloat(Double(reloadTime) / Double(2)))
                    .stroke(.red, lineWidth: 30)
                    .frame(width: scopeSize, height: scopeSize)
                    .rotationEffect(.degrees(-90))
                    .zIndex(3)
                    .onAppear{
                        withAnimation(Animation.linear(duration: 2)){
                            reloadTime = 0
                        }
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                            generator.prepare()
                            generator.impactOccurred()
                            soundManager.playSound(soundName: "Reload", type: "mp3", duration: 0.1)
                        }
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                            reloadTime = 2
                            timer.invalidate()
                        }
                    }
                    .allowsHitTesting(false)
            }else{
                HStack{
                    Image("Bullet")
                        .resizable()
                        .frame(width: 70, height: 70)
                    Text("\(ammo)/8")
                        .foregroundColor(.white)
                        .font(GroteskBold(80))
                }
                .padding()
                .background(.black)
                .cornerRadius(15)
                .offset(y: 425)
                .zIndex(3)
                .allowsHitTesting(false)
            }
            RoundedRectangle(cornerRadius: 45)
                .trim(from: 0, to: CGFloat(Double(timer) / Double(60)))
                .stroke(.red, lineWidth: 40)
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.maxY, height: UIScreen.main.bounds.maxX)
                .rotationEffect(.degrees(-90))
                .zIndex(3)
                .allowsHitTesting(false)
            VStack{
                    HStack{
                            Circle()
                            .foregroundColor(.black)
                            .frame(width: 80, height: 80)
                            .overlay{
                                Image(systemName: "scope")
                                    .font(.system(size: 70))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        Text("\(score)")
                            .font(.system(size: 80))
                            .fontWeight(.bold)
                    }
                Spacer()
                HStack{
                    Circle()
                        .foregroundColor(.black)
                    .frame(width: 35, height: 35)
                    .overlay{
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                    Text("\(targetCount)")
                        .font(GroteskBold(35))
                }
                .offset(y: -40)
            }
            .padding(.top, 60)
            .zIndex(3)
        }
        .frame(width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            score = 0
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                withAnimation(Animation.linear(duration: 1)){
                    if timer == 15 {
                        timer -= 1
                        soundManager.playSound(soundName: "Timer", type: "wav", duration: 15)
                    }else{
                        timer -= 1
                    }
                }
                if timer == -1 {
                    currPage = "NewScores"
                }
            }
        }
    }
}

// Ini mungkin buat view tambahannya bisa di bikin file terpisah, tapi dikelompokin jadi satu folder GameView, soalnya jadi kepanjangan - Elian
struct BackdropView: UIViewRepresentable {
    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var targetCount: Int
    @Binding var ammo: Int
    @Binding var score: Int
    @Binding var reloading: Bool
    @State var toggleRound: Bool = false
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        spawnTargets(in: arView, count: targetCount)
        
        return arView
    }
    
    private func spawnTargets(in arView: ARView, count: Int) {
        for _ in 0..<count {
            let sphere = MeshResource.generateSphere(radius: 0.3)
            let material = SimpleMaterial(color: .yellow, isMetallic: true)
            let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
            let randomLoc = [Float.random(in: -10...10), Float.random(in: -2...0), Float.random(in: -10 ... -3)]
            sphereEntity.transform.translation = SIMD3(randomLoc)
            sphereEntity.generateCollisionShapes(recursive: true)
            
            let anchorEntity = AnchorEntity(world: .zero)
            anchorEntity.addChild(sphereEntity)
            DispatchQueue.main.async{
                sphereEntity.move(to: Transform(translation: SIMD3([Float.random(in: -10...10), Float.random(in: 0...4), Float.random(in: -10 ... -3)])), relativeTo: sphereEntity, duration: 5, timingFunction: .easeOut)
            }
            
            arView.scene.addAnchor(anchorEntity)
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if toggleRound{
            resetTargets(in: uiView)
        }
    }
    
    func resetTargets(in arView: ARView) {
        arView.scene.anchors.removeAll()
        spawnTargets(in: arView, count: targetCount)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(targetCount: $targetCount, toggleWin: $toggleRound, ammo: $ammo, score: $score, reloading: $reloading)
    }
    
    class Coordinator: NSObject {
        @Binding var targetCount: Int
        @Binding var toggleRound: Bool
        @Binding var ammo: Int
        @Binding var score: Int
        @Binding var reloading: Bool
        @StateObject var soundManager = SoundManager()
        
        init(targetCount: Binding<Int>,
             toggleWin: Binding<Bool>,
             ammo: Binding<Int>,
             score: Binding<Int>,
             reloading: Binding<Bool>
        ) {
            _targetCount = targetCount
            _toggleRound = toggleWin
            _ammo = ammo
            _score = score
            _reloading = reloading
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            
            if ammo != 0{
                generator.prepare()
                generator.impactOccurred()
                soundManager.playSound(soundName: "Shot", type: "mp3", duration: 3)
                ammo -= 1
                toggleRound = false
                guard let arView = sender.view as? ARView else { return }
                let tapLocation = CGPoint(x: UIScreen.main.bounds.maxX/2, y: UIScreen.main.bounds.maxY/2)
                
                // Perform a hit test
                if let hitEntity = arView.entity(at: tapLocation) {
                    score+=1
                    //                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.targetCount-=1
                    hitEntity.removeFromParent()
                    if targetCount==0{
                        targetCount = Int.random(in: 1...4)
                        toggleRound.toggle()
                    }
                }
                //                }
            }
            else if !reloading{
                toggleRound = false
                reloading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self.ammo = 8
                    self.reloading = false
                }
            }
        }
    }
}
