//
//  RemoteImage.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI

struct RemoteImage: View {
    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image
    
    // custom average color property we need to access
    var averageColor: UIColor?

    private enum LoadState {
        case loading, success, failure
    }
    
    var body: some View {
        selectImage()
            .resizable()
    }

    init(url: String, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
    
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://avatars.githubusercontent.com/u/41487836")
    }
}

class NirvanaImage {
    static func getAverageColor(url:String) -> UIColor? {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        
        if let data = try? Data(contentsOf: parsedURL) {
            if let image = UIImage(data: data) {
                print("got the average color of image \(image.averageColor)")
                return image.averageColor
            } else {
                print("failed to get image average color")
                return nil
            }
        }
        print("failed to get image average color")
        return nil
    }
}
