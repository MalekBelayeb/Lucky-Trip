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
            BASE_URL + "/places/radius",
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
    
    func getPlaceDetails(xid: String, completed: @escaping (Bool, Place?) -> Void ) {
        AF.request(
            BASE_URL + "/places/xid/" + xid,
            method: .get,
            parameters: [
                "apikey": API_KEY,
            ],
            encoding: URLEncoding(destination: .queryString)
        ).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    completed(true, self.makeItemWithDetails(jsonItem: JSON(response.data!)))
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
            dist: jsonItem["dist"].doubleValue,
            kinds: jsonItem["kinds"].stringValue,
            point: CGPoint(x: jsonItem["lon"].doubleValue, y: jsonItem["lat"].doubleValue)
        )
    }
    
    func makeItemWithDetails(jsonItem: JSON) -> Place {
        Place(
            xid: jsonItem["xid"].stringValue,
            name: jsonItem["name"].stringValue,
            dist: jsonItem["dist"].doubleValue,
            address: Address(
                city: jsonItem["address"]["city"].stringValue,
                state: jsonItem["address"]["state"].stringValue,
                county: jsonItem["address"]["county"].stringValue,
                suburb: jsonItem["address"]["suburb"].stringValue,
                country: jsonItem["address"]["country"].stringValue,
                postcode: jsonItem["address"]["postcode"].stringValue,
                pedestrian: jsonItem["address"]["pedestrian"].stringValue,
                country_code: jsonItem["address"]["country_code"].stringValue,
                state_district: jsonItem["address"]["state_district"].stringValue
            ),
            kinds: jsonItem["kinds"].stringValue,
            wikipedia: jsonItem["wikipedia"].stringValue,
            image: jsonItem["preview"]["source"].stringValue,
            wikipediaExtracts: WikipediaExtracts(
                title: jsonItem["wikipedia_extracts"]["title"].stringValue,
                text: jsonItem["wikipedia_extracts"]["text"].stringValue,
                html: jsonItem["wikipedia_extracts"]["html"].stringValue
            ),
            point: CGPoint(x: jsonItem["lon"].doubleValue, y: jsonItem["lat"].doubleValue)
        )
    }
}
