//
//  ImageInfo.swift
//  Acharyaprashant_Assignment
//
//  Created by Vishal Manhas on 02/11/24.
//

import Foundation

struct ImageInfo: Identifiable, Decodable {
    let id: String
    let title: String
    let thumbnail: Thumbnail

    var imageURL: String {
        return "\(thumbnail.domain)/\(thumbnail.basePath)/0/\(thumbnail.key)"
    }
}

struct Thumbnail: Decodable {
    let domain: String
    let basePath: String
    let key: String
}
