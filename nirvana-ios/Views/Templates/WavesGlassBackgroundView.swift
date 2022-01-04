//
//  WavesGlassBackgroundView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import SwiftUI

struct WavesGlassBackgroundView: View {
    let universalSize = UIScreen.main.bounds
    // y position of where waves should start
    let baseLineY = UIScreen.main.bounds.height * 0.95

    var isRecording: Bool = false
    
    @State var animateWaves = false
    
    let recordingColors = [NirvanaColor.solidBlue, NirvanaColor.dimTeal, Color.orange.opacity(0.8), NirvanaColor.teal.opacity(0.7), NirvanaColor.teal.opacity(0.7), NirvanaColor.solidTeal.opacity(0.7), NirvanaColor.solidBlue]
    let normalColors = [NirvanaColor.solidBlue, NirvanaColor.dimTeal, Color.orange.opacity(0.4), NirvanaColor.teal.opacity(0.5), NirvanaColor.teal.opacity(0.3), NirvanaColor.solidTeal.opacity(0.3), NirvanaColor.solidBlue]
    
    var body: some View {
        ZStack {
            AngularGradient(
                gradient: Gradient(
                    colors: self.isRecording ? recordingColors : normalColors),
                center: .bottom,
                angle: .degrees(120))
            
            // background for the glassmorphic feel
            Image("glosspink")
                .resizable()
                .blur(radius: 5)
             
            LinearGradient(gradient: Gradient(
                colors: [NirvanaColor.white.opacity(0), NirvanaColor.white.opacity(1.0)]), startPoint: .bottom, endPoint: .top)
            
            getWave(peakPercentage: 0.4, troughPercentage: 0.65, peakAltercation: baseLineY, troughAltercation: baseLineY - 50)
                .foregroundColor(NirvanaColor.dimTeal.opacity(0.5))
                .blur(radius:2)
                .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                .animation(
                    Animation.linear(duration: 20).repeatForever(autoreverses: false),
                    value: self.animateWaves
                )
            
            getWave(peakPercentage: 0.2, troughPercentage: 0.75, peakAltercation: baseLineY - 50, troughAltercation: baseLineY + 50)
                .foregroundColor(Color.orange.opacity(0.3))
                .blur(radius:2)
                .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                .animation(
                    Animation.linear(duration: 10).repeatForever(autoreverses: false),
                    value: self.animateWaves
                )
            
            getWave(peakPercentage: 0.45, troughPercentage: 0.75, peakAltercation: baseLineY + 50, troughAltercation: baseLineY - 60)
                .foregroundColor(NirvanaColor.teal.opacity(0.3))
                .blur(radius:2)
                .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                .animation(
                    Animation.linear(duration: 12).repeatForever(autoreverses: false),
                    value: self.animateWaves
                )

        }
        .ignoresSafeArea(.all)
        .onAppear() {
            // start repeat animation for waves
            self.animateWaves = true
        }
    }
    
    private func getWave(peakPercentage: Double, troughPercentage: Double, peakAltercation: CGFloat, troughAltercation: CGFloat) -> Path {
        Path {path in
            path.move(
                to: CGPoint(
                    x: 0,
                    y: baseLineY
                )
            )

            path.addCurve(
                to: CGPoint(x: universalSize.width, y: baseLineY),
                control1: CGPoint(x: universalSize.width * peakPercentage, y: peakAltercation),
                control2: CGPoint(x: universalSize.width * troughPercentage, y: troughAltercation))
            
            path.addCurve(
                to: CGPoint(x: 2*universalSize.width, y: baseLineY),
                control1: CGPoint(x: universalSize.width * (1 + peakPercentage), y: peakAltercation),
                control2: CGPoint(x: universalSize.width * (1 + troughPercentage), y: troughAltercation))
            
            
            path.addLine(to: CGPoint(x: 2*universalSize.width, y: universalSize.height))
            path.addLine(to: CGPoint(x: 0, y: universalSize.height))
        }
    }
}

struct WavesGlassBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        WavesGlassBackgroundView()
    }
}
