//
//  MostRecentView.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import UIKit

class PlaceDetailsView: UIViewController {

    // VARIABLES
    var xid: String?
    var wikiUrl: String?
    
    // BINDING
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kindsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var wikiButton: UIButton!
    
    // LIFECYCLE

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "wiki"){
            let destination = segue.destination as! WikiWebView
            destination.url = wikiUrl
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    // METHODS
    func loadData() {
        PlaceViewModel.sharedInstance.getPlaceDetails(xid: xid!) { [self] success, place in
            if success {
                ImageLoader.shared.loadImage(identifier: (place?.image)!, url: (place?.image)!) { image in
                    self.imageView.image = image
                }
                nameLabel.text = place?.name
                kindsLabel.text = place?.kinds
                addressLabel.text = (place?.address?.city)! + ", " + (place?.address?.county)!
                descriptionTV.text = place?.wikipediaExtracts?.text
                
                wikiButton.addAction(UIAction(handler: { [self] act in
                    wikiUrl = place?.wikipedia
                    print(wikiUrl)
                    performSegue(withIdentifier: "wiki", sender: wikiUrl)
                }), for: .touchUpInside)
            }
        }
    }
    
    // ACTIONS
    @IBAction func loadWiki(_ sender: Any) {
    }
}

