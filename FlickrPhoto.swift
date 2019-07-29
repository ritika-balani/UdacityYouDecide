//
//  FlickrPhoto.swift
//  UpgradedSleepingInTheLibrary
//
//  Created by Raj Balani on 25/07/19.
//  Copyright © 2019 balani. All rights reserved.
//

import UIKit

class FlickrPhoto : Equatable {
  var thumbnail : UIImage?
  var largeImage : UIImage?
  let photoID : String
  let farm : Int
  let server : String
  let apiKey : String
  
  init (photoID:String,farm:Int, server:String, apiKey:String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.apiKey = apiKey
  }
  
  func generateImageURL(_ size:String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(apiKey)_\(size).jpg") {
      return url
    }
    return nil
  }
  
  func loadSelectedImage(_ completion: @escaping (_ flickrPhoto:FlickrPhoto, _ error: NSError?) -> Void) {
    guard let loadURL = generateImageURL("b") else {
      DispatchQueue.main.async {
        completion(self, nil)
      }
      return
    }
    
    let imageLoadRequest = URLRequest(url:loadURL)
    
    URLSession.shared.dataTask(with: imageLoadRequest, completionHandler: { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
          completion(self, error as NSError?)
        }
        return
      }
      
      guard let data = data else {
        DispatchQueue.main.async {
          completion(self, nil)
        }
        return
      }
      
      let fetchedImage = UIImage(data: data)
      self.largeImage = fetchedImage
      DispatchQueue.main.async {
        completion(self, nil)
      }
    }).resume()
  }
  
  func fillAspectRatio(_ size:CGSize) -> CGSize {
    
    guard let thumbnail = thumbnail else {
      return size
    }
    
    let imageSize = thumbnail.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
  
}

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}
