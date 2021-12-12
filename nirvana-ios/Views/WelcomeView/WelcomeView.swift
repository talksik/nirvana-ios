//
//  Onboarding.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct WelcomeView: View {
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
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                
                VStack(alignment: .leading) {
                    
                    Text("Your ")
                        .font(.title)
                    + Text("minimalist ")
                        .font(.title)
                        .foregroundColor(NirvanaColors.teal)
                    + Text("social media.")
                        .font(.title)
                    
                    Text("tired of the rat race on insta, tik-tok, snap, meta?")
                        .foregroundColor(Color.gray)
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Button(
                        action: {
                            print("Start your detox button clicked")
                        },
                        label: {
                            Text("Start Your Detox")
                                .bold()
                                .foregroundColor(NirvanaColors.white)
                        }
                    )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(NirvanaColors.teal)
                        .clipShape(Capsule())
        //                        .shadow(color: NirvanaColors.teal, radius: 3, x: 1, y: 2)
        //                        .cornerRadius(8)
                
                    Button(
                        action: {
                            print("link to w ebsite learn more clicked")
                        },
                        label: {
                            Text("Learn More")
                                .bold()
                        }
                    )
                        .background(NirvanaColors.bgLightGrey)

                    //learn more button to usenirvana.com
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(NirvanaColors.teal)
        .background(NirvanaColors.bgLightGrey)
        //        .background(RadialGradient(gradient: Gradient(colors: [NirvanaColors.teal.opacity(0.1), NirvanaColors.bgLightGrey, NirvanaColors.bgLightGrey]), center: .center, startRadius: 0, endRadius: 200)
        //        )

    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

