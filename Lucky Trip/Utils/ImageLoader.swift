//
//  ImageLoader.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import Foundation

import Alamofire

class ImageLoader{
    
    static let shared: ImageLoader = {
        let instance = ImageLoader()
        return instance
    }()
    
    let imageCache = NSCache<NSString,UIImage>()
    let utilityQueue = DispatchQueue.global(qos: .utility)
    
    func loadImage(identifier: String, url: String, completion: @escaping (UIImage?) -> () ) {
        
        if let cachedImage = self.imageCache.object(forKey: NSString(string: identifier)) {
            completion(cachedImage)
        }else{
            utilityQueue.async {
                if (url != ""){
                    let url = URL(string: url)!
                    
                    guard let data = try? Data(contentsOf: url) else {return}
                    let image = UIImage(data: data)
                    if (image != nil) {
                        DispatchQueue.main.async {
                            self.imageCache.setObject(image!, forKey: NSString(string: identifier))
                            completion (image)
                        }
                    }
                }
            }
        }
    }
}
