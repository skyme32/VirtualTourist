//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 12/3/22.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapVirtualTourist: MKMapView!
    
    // MARK: Variables
    var dataController:DataController!
    
    var fetchedController:NSFetchedResultsController<Pin>!
    
    var pins: [Pin] = []
    
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Maps
        mapVirtualTourist.delegate = self
        
        // Generate long-press UIGestureRecognizer.
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
                
        // Added UIGestureRecognizer to MapView.
        mapVirtualTourist.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedController = nil
    }
}

// MARK: MapKit delegte
extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.orange
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlExtern = view.annotation?.subtitle! {
                
            }
        }
    }
    
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        // Do not generate pins many times during long press.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        // Get the coordinates of the point you pressed long.
        let location = sender.location(in: mapVirtualTourist)
        let coordinate: CLLocationCoordinate2D = mapVirtualTourist.convert(location, toCoordinateFrom: mapVirtualTourist)
        
        // Generate pins.
        getAddressFromLatLon(location: coordinate)
    }
    
    func getAddressFromLatLon(location: CLLocationCoordinate2D) {
        let locationCL: CLLocation = CLLocation(latitude:location.latitude, longitude: location.longitude)
    
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(locationCL) { [weak self] (placemarks, error) in
            guard self != nil else { return }
            
            if let _ = error { return }
            
            guard let placemark = placemarks?.first else { return }
            let locality = placemark.locality ?? String(format: "%f", location.latitude)
            let country = placemark.country ?? String(format: "%f", location.longitude)
            
            let myPin: MKPointAnnotation = MKPointAnnotation()
            myPin.coordinate = location
            myPin.title = "\(locality), \(country)"
            
            // Added pins to MapView.
            self!.mapVirtualTourist.addAnnotation(myPin)
            self!.addPin(title: "\(locality), \(country)", longitude: location.longitude, latitude: location.latitude)
        }
    }
}

// MARK:
extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedController.delegate = self
        do {
            try pins = dataController.viewContext.fetch(fetchRequest)
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        for pin in pins {
            let myPin: MKPointAnnotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            myPin.coordinate = coordinate
            myPin.title = pin.title
            
            // Added pins to MapView.
            self.mapVirtualTourist.addAnnotation(myPin)
        }
    }
    
    /// Adds a new notebook to the end of the `notebooks` array
    func addPin(title: String, longitude: Double, latitude: Double) {
        let pinSave = Pin(context: dataController.viewContext)
        pinSave.title = title
        pinSave.creationDate = Date()
        pinSave.longitude = longitude
        pinSave.latitude = latitude
        try? dataController.viewContext.save()
    }
}
