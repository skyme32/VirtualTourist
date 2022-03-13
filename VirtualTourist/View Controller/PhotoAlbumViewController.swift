//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 13/3/22.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapLocation: MKMapView!
    
    // MARK: Variables
    var dataController:DataController!
    
    var fetchedController:NSFetchedResultsController<Pin>!
    
    var annotation: MKAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapLocation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let pin = annotation {
            mapLocation.addAnnotation(pin)
            zoomRegion()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedController = nil
    }

}


// MARK: MapKit delegte
extension PhotoAlbumViewController: MKMapViewDelegate {
    
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
    
    func zoomRegion() {
        let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapLocation.setRegion(region, animated: true)
    }
}

// MARK: Core Data
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
}
