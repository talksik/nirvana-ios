//
//  ChatsCarouselViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation

final class ChatsCarouselViewModel: ObservableObject {
    @Published var carouselUsers:[User]
    
    init() {
        self.carouselUsers = [
            User(_profilePic: "liam", _firstN: "Liam", _lastN: "Digregorio"),
            User(_profilePic: "heran", _firstN: "Heran", _lastN: "Patel"),
            User(_profilePic: "sarth", _firstN: "Sarth", _lastN: "Shah"),
            User(_profilePic: "kevin", _firstN: "Kevin", _lastN: "Le"),
            User(_profilePic: "rohan", _firstN: "Rohan", _lastN: "Chadha")
        ]
    }
}

//struct CarouselUser {
//    // add anything specific needed in the view for carousel
//    // perhaps notification information for each
//    // their messages?
//
//}

//sample data
