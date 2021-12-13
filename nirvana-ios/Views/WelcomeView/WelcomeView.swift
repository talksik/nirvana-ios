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
        VStack(spacing: 0) {
            // nav bar
            HeaderView()
            
            VStack {
                // illustration
                Image("undraw_friendship_mni7")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
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
                    
                    Spacer()
                }
                .frame(maxWidth: screenWidth - 20)
                
                
                VStack(alignment: .center) {
                    NavigationLink(destination: HomeView()) {
                        Text("Start Your Detox")
                            .bold()
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                        
                        
                    Button(
                        action: {
                            print("link to website learn more clicked")
                        },
                        label: {
                            Text("Learn More")
                                .bold()
                        })

                    //learn more button to usenirvana.com
                }
                .padding(.top, 20)
                
            }
            .padding()
            .frame(maxWidth: screenWidth - 20)

            Spacer()
        } // Vstack
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
        .navigationBarTitleDisplayMode(.inline)
        //        .background(RadialGradient(gradient: Gradient(colors: [NirvanaColor.teal.opacity(0.1), NirvanaColor.bgLightGrey, NirvanaColor.bgLightGrey]), center: .center, startRadius: 0, endRadius: 200)
        //        )
        
    } // View body
} // View


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

