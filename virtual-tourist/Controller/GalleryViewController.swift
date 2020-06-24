//
//  GalleryViewController.swift
//  virtual-tourist
//
//  Created by Arman on 24/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class GalleryViewController : UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate: CLLocationCoordinate2D!
    var photos : [PhotoModel]!
    var pin : Pin!
    var dataController: DataController!
    
    var totalPages : Int = 0
    
    var randomPage : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = pin.name {
            navigationItem.title = title
        }
        let predicate = NSPredicate(format: "pin == %@", pin)
        // fetch request
        let fetchRequest:NSFetchRequest<PhotoModel> = PhotoModel.fetchRequest()
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        if photos.isEmpty {
            fetchImages()
        }
        
    }
    // MARK:- Get photos from flickr and save them
    func fetchImages(){
        setUIEnabled(false)
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        
        if totalPages > 0 {
            let pageLimit = min(totalPages, 40)
            randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        }
        
        ApiClient.loadPhotos(page:randomPage,lat:lat,lon:lon,
                             completion: self.handleLoadPhotos(response:error:))
        
        
    }
    
    func handleLoadPhotos(response:FlickerPhotos?,error:Error?){
        
        if let response = response {
            
            let photos : [Photo] = response.photos.photo
            
            for photo in photos {
                
                let imageUrl:String? = photo.photoUrl
                
                guard let imageUrlString = imageUrl  else {
                    print("Image URl Failed!")
                    setUIEnabled(true)
                    return
                }
                
                // if an image exists at the url, set the image
                guard let imageURL = URL(string: imageUrlString) else{
                    print("Image not Exists At URL")
                    setUIEnabled(true)
                    return
                }
                
                ApiClient.requestImageFile(url: imageURL) { (data, error) in
                    if let data = data {
                        let photo: PhotoModel = PhotoModel(context: self.dataController.viewContext)
                        photo.url = imageURL
                        photo.data = data
                        photo.pin = self.pin
                        try? self.dataController.viewContext.save()
                        self.photos.append(photo)
                    } else {
                        print(error?.localizedDescription ?? "Something Wrong!")
                    }
                    self.refreshCollection()
                }
                
               

            }
            setUIEnabled(true)
            refreshCollection()

            
        }else {
            setUIEnabled(true)
            showAlertDialog(title: "Failur!",
                            message: error?.localizedDescription ?? "Something Wrong!")
        }
    }
    
    func refreshCollection(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    func showAlertDialog(title:String,message : String){
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    func setUIEnabled(_ enabled: Bool) {
        
        DispatchQueue.main.async {
            if enabled {
                
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
            } else {
                
                self.activityIndicator.alpha = 1.0
                self.activityIndicator.startAnimating()
            }
        }
        
    }
    @IBAction func ReloadImage(_ sender: Any) {
        pin.photo = nil
        print(dataController.viewContext.hasChanges)
        try? self.dataController.viewContext.save()
        collectionView.reloadData()
        photos.removeAll()
        fetchImages()
    }
    
}
extension GalleryViewController: MKMapViewDelegate {
    
    // MARK : MAP Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
