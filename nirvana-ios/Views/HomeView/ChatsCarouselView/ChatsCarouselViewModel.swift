//
//  ChatsCarouselViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation

final class ChatsCarouselViewModel: ObservableObject {
    @Published var carouselUsers:[CarouselUser] = []
    
    init() {
        carouselUsers = [
            CarouselUser(_profilePic: "liam", _firstN: "Liam", _lastN: "Digregorio"),
            CarouselUser(_profilePic: "heran", _firstN: "Heran", _lastN: "Patel"),
            CarouselUser(_profilePic: "sarth", _firstN: "Sarth", _lastN: "Shah"),
            CarouselUser(_profilePic: "kevin", _firstN: "Kevin", _lastN: "Le"),
            CarouselUser(_profilePic: "rohan", _firstN: "Rohan", _lastN: "Chadha")
        ]
    }
}

class CarouselUser: User {
    // add anything specific needed in the view for carousel
    // perhaps notification information for each
    // their messages?
}

//sample data
