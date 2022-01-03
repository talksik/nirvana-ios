//
//  ProgressBarView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 1/2/22.
//

import SwiftUI

struct ProgressBarView: View {
    var progress: Float
    var color: Color = Color.orange
        
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
            .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            .foregroundColor(color)
            .rotationEffect(Angle(degrees: 270.0))
            .animation(.linear)
    }
}

//struct ProgressBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressBarView()
//    }
//}
