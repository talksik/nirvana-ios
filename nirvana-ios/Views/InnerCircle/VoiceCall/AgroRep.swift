//
//  AgroRep.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/28/21.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct AgoraRep: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let agoraViewController = AgoraViewController()
        agoraViewController.agoraDelegate = context.coordinator
        return agoraViewController
    }
  
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  
    }
    
    class Coordinator: NSObject, AgoraRtcEngineDelegate {
        var parent: AgoraRep
        init(_ agoraRep: AgoraRep) {
            parent = agoraRep
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
