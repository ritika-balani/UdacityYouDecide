//
//  Flickr.swift
//  UpgradedSleepingInTheLibrary
//
//  Created by Raj Balani on 25/07/19.
//  Copyright © 2019 balani. All rights reserved.
//


import UIKit

let apiKey = "6c69dec8faa72f3e76295dc8107e6569"

class Flickr {
  
  let processingQueue = OperationQueue()
  
  func searchFlickrForTerm(_ searchTerm: String, completion : @escaping (_ results: FlickrSearchResults?, _ error : NSError?) -> Void){
    
    guard let searchURL = flickrSearchURLForSearchTerm(searchTerm) else {
      let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
      completion(nil, APIError)
      return
    }
    
    let searchRequest = URLRequest(url: searchURL)
    
    URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
      
      if let _ = error {
        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
        OperationQueue.main.addOperation({
          completion(nil, APIError)
        })
        return
      }
      
      guard let _ = response as? HTTPURLResponse,
        let data = data else {
          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
      }
      
      do {
        
        guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
        let stat = resultsDictionary["stat"] as? String else {
          
          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        switch (stat) {
        case "ok":
          print("Results have been processed")
        case "fail":
          if let message = resultsDictionary["message"] {
            
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
            
            OperationQueue.main.addOperation({
              completion(nil, APIError)
            })
          }
          
          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: nil)
          
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
  
          return
        default:
          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
          
          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        var flickrPhotos = [FlickrPhoto]()
        
        for photoObject in photosReceived {
          guard let photoID = photoObject["id"] as? String,
            let farm = photoObject["farm"] as? Int ,
            let server = photoObject["server"] as? String ,
            let apiKey = photoObject["apiKey"] as? String else {
              break
          }
          let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, apiKey: apiKey)
          
          guard let url = flickrPhoto.generateImageURL(),
            let imageData = try? Data(contentsOf: url as URL) else {
              break
          }
          
          if let image = UIImage(data: imageData) {
            flickrPhoto.thumbnail = image
            flickrPhotos.append(flickrPhoto)
          }
        }
              
        OperationQueue.main.addOperation({
          completion(FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), nil)
        })
        
      } catch _ {
        completion(nil, nil)
        return
      }
      
      
      }) .resume()
  }
  
  fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
    
    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
      return nil
    }
    
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
    
    guard let url = URL(string:URLString) else {
      return nil
    }
    
    return url
  }
}
