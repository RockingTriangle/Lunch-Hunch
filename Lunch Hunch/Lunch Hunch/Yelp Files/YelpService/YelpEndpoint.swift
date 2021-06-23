//
//  YelpEndpoint.swift
//  Yelp
//
//  Created by Mike Conner on 6/15/21.
//

import Foundation

class YELPEndpoint {
    
    static let shared = YELPEndpoint()
    
    let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    var searchArea: SearchArea = .location("Dayton, OH") // "Dayton, OH" is test data only, will be replaced by user's location or lat/lon of pin on map
    var parameters: [URLQueryItem] = []
    var sortingOption: SortingOption = .distance
    
    var url: URL? {
        guard let url = URL(string: baseURL),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        
        if searchArea.searchAreaQueryItem.count == 1 {
            guard let queryLocation = searchArea.searchAreaQueryItem.first else { return nil }
            components.queryItems = [queryLocation]
        } else {
            guard let queryLatitude = searchArea.searchAreaQueryItem.first,
                  let queryLongitude = searchArea.searchAreaQueryItem.last else { return nil }
            components.queryItems = [queryLatitude, queryLongitude]
        }
        
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
/// Selectable options to add or remove from the API call
extension YELPEndpoint {
    
    // Required search parameters
    /// - one or the other is required
    enum SearchArea {
        case location(String)
        case latLon(Coordinates)
        
        var searchAreaQueryItem: [URLQueryItem] {
            switch self {
            case .location(let location):
                let searchLocation = URLQueryItem(name: "location", value: location)
                return [searchLocation]
            case .latLon(let coordinates):
                let searchLatitude = URLQueryItem(name: "latitude", value: String(coordinates.latitude))
                let searchLongitude = URLQueryItem(name: "longitude", value: String(coordinates.longitude))
                return [searchLatitude, searchLongitude]
            }
        }
    }
    
    // Optional search parameters
    /// - each one has default values
    enum Parameters {
        case radius(Int)
        case categories(String)
        case limit(Int)
        case price(Int)
        
        var parameterQueryItem: URLQueryItem {
            switch self {
            case .radius(let radius):
                return URLQueryItem(name: "radius", value: radius.description)
            case .categories(let categories):
                return URLQueryItem(name: "categories", value: categories)
            case .limit(let limit):
                return URLQueryItem(name: "limit", value: String(limit))
            case .price(let price):
                return URLQueryItem(name: "price", value: "\(price)")
            }
        }
    }
    
    // Sorting is optional when using the YELP! API
    /// - However, we always use it in our queries with .distance as the
    /// - default but provide .rating and .bestMatch as options for the user
    enum SortingOption {
        case bestMatch
        case rating
        case distance
        
        var sortingOptionValue: URLQueryItem {
            switch self {
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
