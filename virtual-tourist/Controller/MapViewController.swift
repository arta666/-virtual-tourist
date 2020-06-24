//
//  ViewController.swift
//  virtual-tourist
//
//  Created by Arman on 22/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {
    
    //MARK : Prperties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    
    var pins: [Pin] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Virtual Tourist"

        mapView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        
        mapView.addGestureRecognizer(longPress)
        
        fetchStoredPins()

    }
    
    
    fileprivate func fetchStoredPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
    }

    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            let pressMapCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            
            createPin(forCoordinate: pressMapCoordinate)
            
        default:
            break
        }
    }
    
  
    
    
    func addAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
       }
    
    
    private func createPin(forCoordinate coordinate: CLLocationCoordinate2D) {
        // Geocode the coordinate to get more details about the location.
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                var locationName: String?
                
                if let placemark = placemarks?.first {
                    locationName = placemark.name
                }
                do {
                    
                    let lat = coordinate.latitude
                    
                    let lon = coordinate.longitude
                    
                    let pin = Pin(context: self.dataController.viewContext)
                    pin.name = locationName
                    pin.latitude = lat
                    pin.longitude = lon

                    try self.dataController.viewContext.save()
            
                    self.addPin(createdPin: pin)
                } catch {
                    self.showAlertDialog(title: "Adding Pin Failed!", message: error.localizedDescription)
                }
            }
        }
    }
    

    
    private func addPin(createdPin pin : Pin){

        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude , longitude: pin.longitude)
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = pin.name
        // Finally we place the annotation in an array of annotations.
        pins.append(pin)
        
        mapView.addAnnotation(annotation)
    }
    
    func showAlertDialog(title:String,message : String){
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
        
    }

}




extension MapViewController: MKMapViewDelegate {
    
    // MARK : MAP Delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // delegate to response on pin tap
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "GalleryVC") as? GalleryViewController
        controller?.coordinate = view.annotation?.coordinate
        
        for pin in pins {
            if pin.latitude.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.pin = pin
            }
        }
        controller?.dataController = dataController
        self.show(controller!, sender: nil)
    }
       
}


