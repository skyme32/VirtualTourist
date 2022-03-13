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
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    var dataController:DataController!
    
    var fetchedController:NSFetchedResultsController<Pin>!
    
    var annotation: MKAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapLocation.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let pin = annotation {
            mapLocation.addAnnotation(pin)
            zoomRegion()
            getPhotosList()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedController = nil
    }
    
    // MARK: Actions to Buttons
    @IBAction func reloadImages(_ sender: Any) {
        getPhotosList()
    }
    

    // MARK: Private methods
    
    private func getPhotosList() {
        FlickrClient.getSearchGeoPhotoList(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { photos, error in
            PhotoModel.shared.photoslist = photos
            self.collectionView.reloadData()
        }
    }
}

// MARK: MapKit delegate
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

// MARK: Core Data Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
}

// MARK: Collection View Delegate
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoModel.shared.photoslist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPicture", for: indexPath) as! CellPicture
        cell.indicator.startAnimating()
        cell.indicator.isHidden = false
        
        if !PhotoModel.shared.photoslist.isEmpty {
            let pin = PhotoModel.shared.photoslist[indexPath.row]
            
            FlickrClient.downloadPosterImage(url: pin.urlImage) { data, Error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageCell?.image = image
                cell.setNeedsLayout()
                cell.indicator.stopAnimating()
                cell.indicator.isHidden = true
            }
        }
        
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3)-3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
