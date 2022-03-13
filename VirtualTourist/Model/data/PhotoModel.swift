//
//  PhotoModel.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 13/3/22.
//

import Foundation


class PhotoModel {
    static let shared = PhotoModel()
    private init() {}
    var photoslist = [Image]()
}
