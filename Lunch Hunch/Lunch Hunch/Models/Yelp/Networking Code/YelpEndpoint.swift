//
//  YelpEndpoint.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import Foundation
import CoreLocation

class YELPEndpoint {
    
    // MARK: - Properties
    static let shared = YELPEndpoint()
    let baseURL = "https://api.yelp.com/v3/businesses/search"
    var locationQueries: [URLQueryItem]?
    var parameters: [URLQueryItem] = []
    var sortingOption: SortingOption = .distance
    var url: URL? {
        guard let url = URL(string: baseURL),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        
        components.queryItems = locationQueries
        
        if parameters.count > 0 {
            for parameter in parameters {
                components.queryItems?.append(parameter)
            }
        }
        
        components.queryItems?.append(sortingOption.sortingOptionValue)
        return components.url
    }
    
}

// MARK: - Extension
extension YELPEndpoint {
    
    enum Parameters {
        case radius(Int)
        case categories(String)
        case price(String)
        
        var parameterQueryItem: URLQueryItem {
            switch self {
            case .radius(let radius):
                return URLQueryItem(name: "radius", value: radius.description)
            case .categories(let categories):
                return URLQueryItem(name: "categories", value: categories)
            case .price(let price):
                return URLQueryItem(name: "price", value: price)
            }
        }
    }
    
    enum SortingOption {
        case random
        case bestMatch
        case rating
        case distance
        
        var sortingOptionValue: URLQueryItem {
            switch self {
            case .random:
                return URLQueryItem(name: "sort_by", value: "random")
            case .bestMatch:
                return URLQueryItem(name: "sort_by", value: "best_match")
            case .rating:
                return URLQueryItem(name: "sort_by", value: "rating")
            case .distance:
                return URLQueryItem(name: "sort_by", value: "distance")
            }
        }
    }
    
}
