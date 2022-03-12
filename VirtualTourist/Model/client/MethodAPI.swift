//
//  MethodAPI.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 12/3/22.
//

import Foundation

class MethodAPI {
    
    // MARK: Methods
    
    enum Methods {
        static let get = "GET"
        static let post = "POST"
        static let put = "PUT"
        static let delete = "DELETE"
    }
    
    // MARK: Request Method GET
    
    public class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion:
                                                                 @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
}
