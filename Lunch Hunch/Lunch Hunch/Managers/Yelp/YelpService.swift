//
//  YelpService.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import UIKit

struct YELPService: NetworkServicing {
    
    // MARK: - Properties
    var apiKey = "4Q3KPa9t4zHJoG3_yNUzN5iYXCRe-1w1DQu-uP0WD-gXg0crMgqwv-2eCnn_x25YgeyAwgMOCociondj89sudvA_kv7yC9RCbX4mH8dlhsI-Nvp38zDR1p8D7vLHYHYx"
    private let cache = NSCache<NSString, UIImage>()
        
    // MARK: - Functions
    /// Get restaurant data from
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: YELPEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = endpoint.url else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        perform(request) { result in
            switch result {
            case .success(let data):
                guard let decodedObject = data.decode(type: type) else {
                    completion(.failure(.couldNotUnwrap))
                    return
                }
                completion(.success(decodedObject))
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n\(error)")
            }
        }
    }
    
    /// Get restaurant image
    func downloadImage(fromUrlString urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error  = error {
                completion(nil)
                print("Error in \(#function) : \(error.localizedDescription) \n---\n\(error)")
                return
            }
            guard let _ = response as? HTTPURLResponse else {
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.cache.setObject(image, forKey: cacheKey)
            completion(image)
        }.resume()
    } // end downloadImage
    
}

