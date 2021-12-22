//
//  FooterControlsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/12/21.
//

import SwiftUI

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

struct FooterControlsView: View {
    @StateObject var viewModel:FooterControlsViewModel = FooterControlsViewModel()
    
    @GestureState var isLongPressingRecord: Bool = false
    @State var isHolding = false
    @State var completedLongPress = false
    
    @State var scaleBigPulser:CGFloat = 1
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged {_ in
                self.isHolding = true
            }
            .onEnded {_ in
                self.isHolding = false
            }
    }
        
    var body: some View {
        ZStack {
            Button(action: {
                
            }, label: {
                Image(systemName: self.isHolding ? "waveform" : "mic.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(NirvanaColor.teal)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .scaleEffect(self.isHolding ? 1.2: 1,
                                 anchor: .center)
                    .simultaneousGesture(dragGesture)
//                    .animation(.default, value: self.isHolding)
            })
                .zIndex(10)

            Circle()
                .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .scaleEffect(self.scaleBigPulser,
                             anchor: .center)
                .foregroundColor(NirvanaColor.teal)
                .opacity(0.3)
                .onAppear {
                    let baseAnimation = Animation.easeOut(duration: 1)
                    let repeated = baseAnimation.repeatForever(autoreverses: true)
                    
                    withAnimation(repeated) {
                        self.scaleBigPulser = 1.12
                    }
                }
            
            Circle()
                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .scaleEffect(self.isHolding ? 1.5: 1,
                             anchor: .center)
                .foregroundColor(NirvanaColor.teal)
                .opacity(0.5)
                .animation(Animation.easeInOut(duration:1).repeat(while: self.isHolding, autoreverses: true))
            
            Circle()
                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .scaleEffect(self.isHolding ? 1.1: 1,
                             anchor: .center)
                .foregroundColor(NirvanaColor.teal)
                .opacity(0.9)
                .animation(Animation.easeInOut(duration: 1).repeat(while: self.isHolding, autoreverses: true))
        }
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
