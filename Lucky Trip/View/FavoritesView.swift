//
//  MostRecentView.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import UIKit
import CoreData

class FavoritesView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // VARIABLES
    private var places : [Place] = []

    // BINDING
    @IBOutlet weak var placesTV: UITableView!
    
    // LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // PROTOCOLS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.contentView

        let nameLabel = contentView?.viewWithTag(1) as! UILabel
        let descriptionLabel = contentView?.viewWithTag(2) as! UILabel
        let distanceLabel = contentView?.viewWithTag(3) as! UILabel
        
        let place: Place = places[indexPath.row]
        
        nameLabel.text = place.name
        descriptionLabel.text = place.name
        distanceLabel.text = place.name
        
        return cell!

    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .delete
         {
            removeFavorite(f)
         }
    }
    
    // METHODS
    
    func chooseFilter() {
        UserDefaults.standard.setValue("location", forKey: "filter")
    }
    
    func addToFavorites(placeToAdd: Place) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let placeEntity = NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)
        let newPlace = NSManagedObject(entity: placeEntity!, insertInto: context)
        newPlace.setValue(placeToAdd.name, forKey: "name")
        do {
          try context.save()
         } catch {
          print("Error saving")
        }
    }

    // ACTIONS

}

