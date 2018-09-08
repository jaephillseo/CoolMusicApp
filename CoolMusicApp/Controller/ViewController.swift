//
//  ViewController.swift
//  CoolMusicApp
//
//  Created by Alex Kong on 10/19/17.
//  Copyright © 2017 AlexKong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey("AIzaSyD4fJ2dmm2Ow66qwOX48OwFU_nc6-llyJA")
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.335162, longitude: -121.881157, zoom: 16)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        let currentLocation = CLLocationCoordinate2D(latitude: 37.335162, longitude: -121.881157)
        let marker = GMSMarker(position: currentLocation)
        marker.title = "San Jose State Univeristy"
        marker.map = mapView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // User is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    // Handles Firebase logout
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

