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
    private var favoritePlaces : [Place] = []
    private var selectedPlace: Place?
    
    // BINDING
    @IBOutlet weak var placesTV: UITableView!
    
    // LIFECYCLE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "details"){
            let destination = segue.destination as! PlaceDetailsView
            destination.xid = selectedPlace?.xid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    // PROTOCOLS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.contentView
        
        let nameLabel = contentView?.viewWithTag(1) as! UILabel
        let descriptionLabel = contentView?.viewWithTag(2) as! UILabel
        let distanceLabel = contentView?.viewWithTag(3) as! UILabel
        
        let place: Place = favoritePlaces[indexPath.row]
        
        nameLabel.text = place.name
        descriptionLabel.text = place.kinds
        distanceLabel.text = String(place.dist)
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            removeFavorite(xid: favoritePlaces[indexPath.row].xid!)
            favoritePlaces.remove(at: indexPath.row)
            placesTV.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = favoritePlaces[indexPath.row]
        performSegue(withIdentifier: "details", sender: selectedPlace?.xid)
    }
    
    // METHODS
    
    func loadData() {
        favoritePlaces = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceEntity")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                favoritePlaces.append(
                    Place(
                        xid: data.value(forKey: "xid") as? String,
                        name: data.value(forKey: "name") as! String,
                        dist: data.value(forKey: "dist") as! Double,
                        kinds: data.value(forKey: "kinds") as? String,
                        point: CGPoint(
                            x: data.value(forKey: "lon") as! Double,
                            y: data.value(forKey: "lat") as! Double
                        )
                    )
                )
            }
        } catch {
            print("Failed")
        }
        placesTV.reloadData()
    }
    
    func chooseFilter() {
        UserDefaults.standard.setValue("location", forKey: "filter")
    }
    
    func removeFavorite(xid: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceEntity")
        request.predicate = NSPredicate(format: "xid LIKE %@", xid)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                context.delete(data)
                do {
                    try context.save()
                    print("Favorite deleted")
                }
                catch {
                    print("Failed to delete")
                }
            }
        } catch {
            print("Failed to fetch")
        }
    }
    
    // ACTIONS
    
}

