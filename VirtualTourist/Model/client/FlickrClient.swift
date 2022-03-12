//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 12/3/22.
//

import Foundation


class FlickrClient {

    struct Auth {
        static var key = ""
    }
    
    struct Page {
        static var perPage = 25
        static var choosePage = Int.random(in: 1..<perPage)
    }

    // MARK: Endpoints

    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest"
        
        case searchGeoPhoto(Double, Double)
        
        var stringValue: String {
            switch self {
                case .searchGeoPhoto(let lat, let lon):
                return Endpoints.base + "/?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1&extras=url_m&per_page=\(Page.perPage)&page=\(Page.choosePage)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: Request Search GEO Methods

    class func getSearchGeoPhotoList(latitude: Double, longitude: Double, completion: @escaping ([Image], Error?) -> Void) {
        let urlExtension = Endpoints.searchGeoPhoto(latitude, longitude).url
        MethodAPI.taskForGETRequest(url: urlExtension, responseType: FlickrResponse.self) { response, error in
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }

}
