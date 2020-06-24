//
//  ApiClient.swift
//  virtual-tourist
//
//  Created by Arman on 23/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import Foundation

class ApiClient {
    
    struct Auth {
        static let apiKey = ""
    }
    
    struct Method {
        static var search = "flickr.photos.search"
    }
    
    enum Endpoints {
        
        static let base = "https://api.flickr.com/services/rest"
        
        static let defaultParams = "/?api_key=\(Auth.apiKey)&format=json&nojsoncallback=1&extras=url_m&accuracy=6&per_page=30"
        
        case randomByCoordinate(Int,Double,Double)
        
        var stringValue : String {
            switch self {
            case .randomByCoordinate(let page,let lat,let lon):
                return Endpoints.base + Endpoints.defaultParams + "&method=\(Method.search)&page=\(page)&lat=\(lat)&lon=\(lon)"
            }
            
            
        }
        var url: URL {
            return URL(string:stringValue)!
        }
        
    }
    
    
    class func loadPhotos(page:Int,lat:Double,lon:Double,completion: @escaping (FlickerPhotos?, Error?) -> Void){
    
        taskForGETRequest(url: Endpoints.randomByCoordinate(page,lat,lon).url, responseType: FlickerPhotos.self) { (response, error) in
            if let response = response {
                completion(response,error)
            }else{
                completion(nil,error)
            }
        }
    }
    
    
    
    class func requestImageFile(url:URL,completion: @escaping (Data? ,Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
              
              guard let data = data else {
                DispatchQueue.main.async {
                   completion(nil,error)
                }
                  
                  return
              }
              DispatchQueue.main.async {
                 completion(data,nil)
              }
//              let downloadedImage = UIImage(data: data)
              
          }
          task.resume()
      }
    
    class func taskForGETRequest<ResponseType : Codable>
        (url:URL,responseType:ResponseType.Type,
         completion: @escaping (ResponseType?,Error?) -> Void) -> URLSessionTask{
        
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
                do {
                    let errorResponse = try decoder.decode(FlickerResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil,errorResponse)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
}
