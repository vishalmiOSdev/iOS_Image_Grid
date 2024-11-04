//
//  Networking.swift
//  Acharyaprashant_Assignment
//
//  Created by Vishal Manhas on 02/11/24.
//

import Foundation


enum NetworkError: Error {
    case invalidURL
    case requestFailed
}

class NetworkManager {
    static let shared = NetworkManager()
    private let urlSession = URLSession(configuration: .default)

    func fetch<T: Decodable>(urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response:\n \(jsonString)")
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.requestFailed))
            }
        }.resume()
    }

    func downloadImage(urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return nil
        }

        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download failed: \(error)")
                completion(.failure(.requestFailed))
                return
            }

            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
        return task
    }
}
