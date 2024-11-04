//
//  CacheManager.swift
//  Acharyaprashant_Assignment
//
//  Created by Vishal Manhas on 02/11/24.
//

import Foundation
import UIKit


class MemoryCacheManager {
    static let shared = MemoryCacheManager()
    private let memoryCache = NSCache<NSString, UIImage>()

    private init() {}

    func saveImage(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
    }

    func getImage(forKey key: String) -> UIImage? {
        return memoryCache.object(forKey: key as NSString)
    }
}


class DiskCacheManager {
    static let shared = DiskCacheManager()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    func saveImage(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filePath = cacheDirectory.appendingPathComponent(key)
        try? data.write(to: filePath)
    }

    func getImage(forKey key: String) -> UIImage? {
        let filePath = cacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: data)
    }
}
