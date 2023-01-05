//
//  MostRecentView.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import UIKit
import CoreData
import CoreLocation
import MaterialComponents

class MostRecentView: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    // VARIABLES
    private var places: [Place] = []
    private var placesAux: [Place] = []
    private var favoritePlaces: [Place] = []
    private var selectedPlace: Place?
    private var radius = 5000
    private var lon: Double?
    private var lat: Double?
    let locationManager = CLLocationManager()
    var currentLocation: CGPoint?
    
    // BINDING
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var placesTV: UITableView!
    @IBOutlet weak var selectCityButton: UIButton!
    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var category1View: UIView!
    @IBOutlet weak var category2View: UIView!
    @IBOutlet weak var category3View: UIView!
    @IBOutlet weak var category4View: UIView!
    
    // LIFECYCLE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "details"){
            let destination = segue.destination as! PlaceDetailsView
            destination.xid = selectedPlace?.xid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Tunis", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 10.0028528, y: 36.7948004))
                }),
                UIAction(title: "Sousse", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 10.6180544, y: 35.8283346))
                }),
                UIAction(title: "Ariana", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 10.1352548, y: 36.8688529))
                }),
                UIAction(title: "Bizerte", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 9.8439518, y: 37.2810719))
                }),
                UIAction(title: "Sfax", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 10.6628876, y: 34.7613743))
                }),
                UIAction(title: "Manouba", handler: { [self] (_) in
                    chooseFilter(coordinates: CGPoint(x: 10.042555, y: 36.8098793))
                }),
            ]
        }
        
        selectCityButton.menu = UIMenu(title: "My menu", image: nil, identifier: nil, options: [], children: menuItems)
        
        useMyLocationButton.addAction(UIAction(handler: { [self] act in
            if (currentLocation != nil){
                chooseFilter(coordinates: currentLocation!)
            }
        }), for: .touchUpInside)
        
        setupCategories()
        setupLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFavorites()
        loadFilters()
        loadData()
    }
    
    // PROTOCOLS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.contentView
        
        let nameLabel = contentView?.viewWithTag(1) as! UILabel
        let descriptionLabel = contentView?.viewWithTag(2) as! UILabel
        let distanceLabel = contentView?.viewWithTag(3) as! UILabel
        let favoriteButton = contentView?.viewWithTag(4) as! UIButton
        
        let place: Place = places[indexPath.row]
        
        nameLabel.text = place.name
        descriptionLabel.text = place.kinds
        distanceLabel.text = String(place.dist)
        
        if favoritePlaces.contains(where: { thisPlace in
            return thisPlace.xid == place.xid!
        }){
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else{
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        favoriteButton.removeTarget(nil, action: nil, for: .allEvents)
        
        favoriteButton.addAction(UIAction(handler: { act in
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            self.addToFavorites(placeToAdd: place)
        }), for: .touchUpInside)
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = places[indexPath.row]
        performSegue(withIdentifier: "details", sender: selectedPlace?.xid)
    }
    
    // METHODS
    
    func loadFavorites() {
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
    }
    
    func loadData(){
        if (lon != nil && lat != nil) {
            PlaceViewModel.sharedInstance.getPlacesByCoordinates(radius: radius, lon: lon!, lat: lat!) { [self] success, placesFromAPI in
                places = placesFromAPI!
                placesAux = placesFromAPI!
                placesTV.reloadData()
                
                placesLabel.text = "Places of interest (" + String(places.count) + ")"
            }
        }
    }
    
    func loadFilters() {
        if (UserDefaults.standard.value(forKey: "lon") != nil) &&
            (UserDefaults.standard.value(forKey: "lat") != nil){
            lon = UserDefaults.standard.value(forKey: "lon") as? Double
            lat = UserDefaults.standard.value(forKey: "lat") as? Double
        } else {
            print("No old config")
        }
    }
    
    func chooseFilter(coordinates: CGPoint) {
        print("CHOSING FILTER WITH LOCATION")
        print(coordinates)
        
        lon = coordinates.x
        lat = coordinates.y
        
        UserDefaults.standard.setValue(coordinates.x, forKey: "lon")
        UserDefaults.standard.setValue(coordinates.y, forKey: "lat")
        
        loadData()
    }
    
    func setupCategories() {
        var chipView = MDCChipView()
        chipView.titleLabel.text = "historic"
        chipView.setTitleColor(UIColor.red, for: .selected)
        chipView.sizeToFit()
        chipView.addAction(UIAction(handler: { act in
            self.selectCategory(category: "historic")
        }), for: .touchUpInside)
        category1View.addSubview(chipView)
        
        chipView = MDCChipView()
        chipView.titleLabel.text = "cultural"
        chipView.setTitleColor(UIColor.red, for: .selected)
        chipView.sizeToFit()
        chipView.addAction(UIAction(handler: { act in
            self.selectCategory(category: "cultural")
        }), for: .touchUpInside)
        category2View.addSubview(chipView)
        
        chipView = MDCChipView()
        chipView.titleLabel.text = "museums"
        chipView.setTitleColor(UIColor.red, for: .selected)
        chipView.sizeToFit()
        chipView.addAction(UIAction(handler: { act in
            self.selectCategory(category: "museums")
        }), for: .touchUpInside)
        category3View.addSubview(chipView)
        
        chipView = MDCChipView()
        chipView.titleLabel.text = "religion"
        chipView.setTitleColor(UIColor.red, for: .selected)
        chipView.sizeToFit()
        chipView.addAction(UIAction(handler: { act in
            self.selectCategory(category: "religion")
        }), for: .touchUpInside)
        category4View.addSubview(chipView)
    }
    
    func selectCategory(category: String) {
        places = []
        for place in placesAux {
            if (place.kinds!.contains(category)) {
                places.append(place)
            }
        }
        placesLabel.text = "Places of interest (" + String(places.count) + ")"
        placesTV.reloadData()
    }
    
    func addToFavorites(placeToAdd: Place) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let placeEntity = NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)
        let newPlace = NSManagedObject(entity: placeEntity!, insertInto: context)
        newPlace.setValue(placeToAdd.xid, forKey: "xid")
        newPlace.setValue(placeToAdd.name, forKey: "name")
        newPlace.setValue(placeToAdd.dist, forKey: "dist")
        newPlace.setValue(placeToAdd.kinds, forKey: "kinds")
        newPlace.setValue(placeToAdd.point.x, forKey: "lon")
        newPlace.setValue(placeToAdd.point.y, forKey: "lat")
        do {
            try context.save()
            print("Saved to favorites")
        } catch {
            print("Error saving")
        }
    }
    
    func setupLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        currentLocation = CGPoint(x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude)
        print(currentLocation)
    }
    
    // ACTIONS
    
}

