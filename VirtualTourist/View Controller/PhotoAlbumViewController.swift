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
    var fetchedController:NSFetchedResultsController<Photo>!
    var pin: Pin!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapLocation.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if pin != nil {
            zoomRegion()
            addPointAnnotation()
            setupFetchedResultsController()
            
            if pin.photos?.count == 0 {
                getPhotosList()
            }
        }
        
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedController = nil
    }
    
    // MARK: Actions to Buttons
    @IBAction func reloadImages(_ sender: Any) {
        deleteImages()
        getPhotosList()
        self.collectionView.reloadData()
    }
    

    // MARK: Private methods
    
    private func getPhotosList() {
        FlickrClient.getSearchGeoPhotoList(latitude: pin.latitude, longitude: pin.longitude) { photos, error in
            if !photos.isEmpty {
                
                for photoResponse in photos {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.id = photoResponse.id
                    photo.title = photoResponse.title
                    photo.pin = self.pin
                    photo.url = photoResponse.urlImage
                    self.pin.addToPhotos(photo)
                    
                    try? self.dataController.viewContext.save()
                }
            }
        }
    }
    
    // Deletes the `Images` at the specified index path
    func deleteImages() {
        for imageDelete in fetchedController.fetchedObjects! {
            dataController.viewContext.delete(imageDelete)
            try? dataController.viewContext.save()
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
    
    fileprivate func zoomRegion() {
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapLocation.setRegion(region, animated: true)
    }
    
    fileprivate func addPointAnnotation() {
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate.latitude = pin.latitude
        myPin.coordinate.longitude = pin.longitude
        myPin.title = pin.title
        
        mapLocation.addAnnotation(myPin)
    }
}

// MARK: Collection View Delegate
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageFetched = fetchedController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPicture", for: indexPath) as! CellPicture
        
        if (imageFetched.image == nil) {
            cell.indicator.startAnimating()
            cell.indicator.isHidden = false
               
            FlickrClient.downloadPosterImage(url: imageFetched.url!) { data, Error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageCell?.image = image
                cell.setNeedsLayout()
                cell.indicator.stopAnimating()
                cell.indicator.isHidden = true
                
                imageFetched.image = data
                try? self.dataController.viewContext.save()
               }
        } else {
            cell.imageCell?.image = UIImage(data: imageFetched.image!)
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


// MARK: Core Data Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin!)
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedController.delegate = self
        
        do {
            try fetchedController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            collectionView.insertSections(indexSet)
        case .delete:
            collectionView.deleteSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
}
