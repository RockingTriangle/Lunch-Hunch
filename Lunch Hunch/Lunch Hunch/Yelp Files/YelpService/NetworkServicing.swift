//
//  NetworkServicing.swift
//  Yelp
//
//  Created by Mike Conner on 6/14/21.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case unexpectedError
    case requestError(Error)
    case noData
    case badURL
    case couldNotUnwrap
    case non200Response(HTTPURLResponse)
    
    var localizedDescription: String {
        switch self {
        case .requestError(let error):
            return "Request error: \(error)"
        case .noData:
            return "No data"
        case .badURL:
            return "Bad URL"
        case .couldNotUnwrap:
            return "Unable to unwrap"
        case .unexpectedError:
            return "Unexpected Error"
        case .non200Response(let response):
            return "Non 200 response: \(response.statusCode).... \(response.url!.absoluteString)"
        }
    }
}

protocol NetworkServicing {
    var apiKey: String { get }
    func perform(_ request: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

extension NetworkServicing {
    func perform(_ request: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n\(error)")
                completion(.failure(.unexpectedError))
            }
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.non200Response(response)))
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
}

extension Data {
    func decode<T: Decodable>(type: T.Type, T_ decoder: JSONDecoder = JSONDecoder()) -> T? {
        return try? decoder.decode(T.self, from: self)
    }
}

