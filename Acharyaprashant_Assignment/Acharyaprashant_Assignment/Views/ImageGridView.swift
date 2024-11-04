//
//  ImageGridView.swift
//  Acharyaprashant_Assignment
//
//  Created by Vishal Manhas on 02/11/24.
//

import SwiftUI

struct ImageGridView: View {
    @StateObject private var viewModel = ImageGridViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(viewModel.images) { imageInfo in
                        ImageCellView(imageInfo: imageInfo, viewModel: viewModel)
                    }
                }
                .padding()
                .overlay(
                    viewModel.isLoading ? LoadingView() : nil
                )
            }
            .navigationTitle("Image Grid")
        }
        .onAppear {
            viewModel.fetchImages()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading Images...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
}



struct ImageCellView: View {
    let imageInfo: ImageInfo
    @ObservedObject var viewModel: ImageGridViewModel
    @State private var image: UIImage? = nil
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } else if loadFailed {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle()))
            }
        }
        .onAppear {
            viewModel.loadImage(for: imageInfo) { loadedImage in
                if let loadedImage = loadedImage {
                    self.image = loadedImage
                    self.loadFailed = false
                } else {
                    self.loadFailed = true
                }
            }
        }
        .onDisappear {
            viewModel.cancelLoad(for: imageInfo.imageURL)
        }
    }
}


#Preview {
    ImageGridView()
}
