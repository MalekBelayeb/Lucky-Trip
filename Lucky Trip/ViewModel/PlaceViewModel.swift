//
//  PlaceViewModel.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import SwiftyJSON
import Alamofire
import UIKit.UIImage
import Foundation

class PlaceViewModel {
    
    static let sharedInstance = PlaceViewModel()
    
    func getPlacesByCoordinates(radius: Int, lon: Double, lat: Double, completed: @escaping (Bool, [Place]?) -> Void ) {
        AF.request(
            BASE_URL + "/places",
            method: .get,
            parameters: [
                "apikey": API_KEY,
                "radius": radius,
                "lon": lon,
                "lat": lat,
                "format": "json"
            ],
            encoding: URLEncoding(destination: .queryString)
        ).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    var places : [Place]? = []
                    for singleJsonItem in JSON(response.data!) {
                        places!.append(self.makeItem(jsonItem: singleJsonItem.1))
                    }
                    completed(true, places)
                case let .failure(error):
                    debugPrint(error)
                    completed(false, nil)
                }
            }
    }
    
    func getPlaceDetails(xid: String, completed: @escaping (Bool, [Place]?) -> Void ) {
        AF.request(
            BASE_URL + "places/xid/" + xid,
            method: .post,
            parameters: [
                "apikey": API_KEY,
            ],
            encoding: URLEncoding(destination: .queryString)
        ).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    var places : [Place]? = []
                    for singleJsonItem in JSON(response.data!) {
                        places!.append(self.makeItem(jsonItem: singleJsonItem.1))
                    }
                    completed(true, places)
                case let .failure(error):
                    debugPrint(error)
                    completed(false, nil)
                }
            }
    }
    
    
    func makeItem(jsonItem: JSON) -> Place {
        Place(
            xid: jsonItem["xid"].stringValue,
            name: jsonItem["name"].stringValue,
            point: CGPoint(x: jsonItem["lon"].doubleValue, y: jsonItem["lat"].doubleValue)
        )
    }
}
