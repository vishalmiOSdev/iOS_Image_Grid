//
//  ImageGridViewModel.swift
//  Acharyaprashant_Assignment
//
//  Created by Vishal Manhas on 02/11/24.
//

import SwiftUI


import SwiftUI

class ImageGridViewModel: ObservableObject {
    @Published var images: [ImageInfo] = []
    @Published var isLoading = false

    private let apiURL = "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=200"
    private var activeTasks: [String: URLSessionDataTask] = [:]
    private let memoryCache = MemoryCacheManager.shared
    private let diskCache = DiskCacheManager.shared

    init() {
        fetchImages()
    }
    
    func fetchImages() {
        isLoading = true
        NetworkManager.shared.fetch(urlString: apiURL) { [weak self] (result: Result<[ImageInfo], NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let images):
                    self?.images = images
                case .failure(let error):
                    print("Error fetching images: \(error.localizedDescription)")
                }
            }
        }
    }

    func loadImage(for imageInfo: ImageInfo, completion: @escaping (UIImage?) -> Void) {
        let imageUrl = imageInfo.imageURL

        if let cachedImage = memoryCache.getImage(forKey: imageUrl) {
            completion(cachedImage)
            return
        }

        if let diskImage = diskCache.getImage(forKey: imageUrl) {
            memoryCache.saveImage(diskImage, forKey: imageUrl)
            completion(diskImage)
            return
        }
       
        activeTasks[imageUrl]?.cancel()

        let task = NetworkManager.shared.downloadImage(urlString: imageUrl) { [weak self] result in
            DispatchQueue.main.async {
                self?.activeTasks[imageUrl] = nil
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self?.memoryCache.saveImage(image, forKey: imageUrl)
                        self?.diskCache.saveImage(image, forKey: imageUrl)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
        }
        
        activeTasks[imageUrl] = task
    }

    func cancelLoad(for imageUrl: String) {
        activeTasks[imageUrl]?.cancel()
        activeTasks[imageUrl] = nil
    }
}
