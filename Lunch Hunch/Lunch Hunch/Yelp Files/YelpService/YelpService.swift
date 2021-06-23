//
//  YelpService.swift
//  Yelp
//
//  Created by Mike Conner on 6/14/21.
//

import Foundation
    
struct YELPService: NetworkServicing {
    
    var apiKey = "4Q3KPa9t4zHJoG3_yNUzN5iYXCRe-1w1DQu-uP0WD-gXg0crMgqwv-2eCnn_x25YgeyAwgMOCociondj89sudvA_kv7yC9RCbX4mH8dlhsI-Nvp38zDR1p8D7vLHYHYx"
    
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: YELPEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = endpoint.url else {
            completion(.failure(.badURL))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        perform(request) { result in
            switch result {
            case .success(let data):
                print(data)
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
}

