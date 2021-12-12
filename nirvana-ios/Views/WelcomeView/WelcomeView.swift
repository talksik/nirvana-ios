//
//  Onboarding.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct WelcomeView: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack {
            // nav bar
            HeaderView()
            
            VStack {
                // illustration
                Image("undraw_friendship_mni7")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    
                    Text("Your ")
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                    + Text("minimalist ")
                        .font(.title)
                        .foregroundColor(NirvanaColor.teal)
                    + Text("social media.")
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                    
                    Text("tired of the rat race on insta, tik-tok, snap, meta?")
                        .foregroundColor(Color.gray)
                        .padding(.top, 5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: screenWidth - 20)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Button(
                        action: {
                            print("Start your detox button clicked")
                        },
                        label: {
                            Text("Start Your Detox")
                                .bold()
                                .foregroundColor(NirvanaColor.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 25)
                                .background(NirvanaColor.teal)
                                .clipShape(Capsule())
                                .shadow(radius:10)
                        })
                        
                        
                    Button(
                        action: {
                            print("link to website learn more clicked")
                        },
                        label: {
                            Text("Learn More")
                                .bold()
                        })
                        .background(NirvanaColor.bgLightGrey)

                    //learn more button to usenirvana.com
                }
                .padding(.top, 20)
                .frame(maxWidth: 300)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: screenWidth - 20)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
        //        .background(RadialGradient(gradient: Gradient(colors: [NirvanaColor.teal.opacity(0.1), NirvanaColor.bgLightGrey, NirvanaColor.bgLightGrey]), center: .center, startRadius: 0, endRadius: 200)
        //        )

    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

