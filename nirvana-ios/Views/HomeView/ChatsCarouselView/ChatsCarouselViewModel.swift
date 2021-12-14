//
//  ChatsCarouselViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation

final class ChatsCarouselViewModel: ObservableObject {
    @Published var carouselUsers:[TestUser]
    
    init() {
        self.carouselUsers = [
            TestUser(_profilePic: "liam", _firstN: "Liam", _lastN: "Digregorio"),
            TestUser(_profilePic: "heran", _firstN: "Heran", _lastN: "Patel"),
            TestUser(_profilePic: "sarth", _firstN: "Sarth", _lastN: "Shah"),
            TestUser(_profilePic: "kevin", _firstN: "Kevin", _lastN: "Le"),
            TestUser(_profilePic: "rohan", _firstN: "Rohan", _lastN: "Chadha")
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
