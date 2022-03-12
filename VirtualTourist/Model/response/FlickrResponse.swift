//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 12/3/22.
//
//{
//"photos": {
//    "page": 5,
//    "pages": 5459,
//    "perpage": 1,
//    "total": 5459,
//    "photo": [
//        {
//            "id": "****",
//            "owner": "****",
//            "secret": "****",
//            "server": "****",
//            "farm": 66,
//            "title": "Crenellations Pattern",
//            "ispublic": 1,
//            "isfriend": 0,
//            "isfamily": 0,
//            "url_m": "https://live.staticflickr.com/****/****.jpg",
//            "height_m": 333,
//            "width_m": 500
//        }
//    ]
//},
//"stat": "ok"
//}

import Foundation

struct FlickrResponse: Codable {
    let photos: PhotoPage
    let stat: String
}

struct PhotoPage: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let photo: [Image]
}
    
struct Image: Codable {
    let id: String
    let title: String
    let urlImage: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case urlImage = "url_m"
    }
}

