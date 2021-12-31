//
//  CallView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/28/21.
//

import SwiftUI

struct CallView: View {
  @Environment(\.presentationMode) var presentationMode
    
  var body: some View {
    VStack {
      Text("Welcome to the call!")
        .bold()
      Spacer()
      HStack {
        Image(systemName: "mic.circle.fill")
          .font(.system(size:64.0))
          .foregroundColor(.blue)
          .padding()
        Spacer()
        Image(systemName: "phone.circle.fill")
          .font(.system(size:64.0))
          .foregroundColor(.red)
          .padding()
          .onTapGesture {
              presentationMode.wrappedValue.dismiss()
            }
      }
        
        AgoraRep()
        .frame(width: 0, height: 0, alignment: .center)
        
      .padding()
    }
  }
}

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        CallView()
    }
}
