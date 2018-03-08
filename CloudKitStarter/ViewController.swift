//
//  ViewController.swift
//  CloudKitStarter
//
//  Created by Steven Shang on 3/8/18.
//  Copyright © 2018 cocoanuts. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let model = CloudDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        tableView.dataSource = self
        tableView.delegate = self
        
        model.delegate = self
        model.retrieveData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        presentImageAlertController()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        model.retrieveData()
    }
    
    func presentImageAlertController() {
        
        let alertController = UIAlertController(title: "Select Image", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.openCamera()
        }
        let libraryAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.openLibrary()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: "public.image") {
            
            let imageFile = info[UIImagePickerControllerEditedImage] as! UIImage
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            let dateString = formatter.string(from: Date())
            model.saveData(image: imageFile, date: dateString)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        model.loadData(index: indexPath.row) { (image, date) in
            cell.postImageView.image = image
            cell.postDateLabel.text = date
        }
        
        return cell
    }
}

extension ViewController: CloudDataManagerDelegate {
    
    func reportError(error: Error) {
        
        let message = error.localizedDescription
        let alertController = UIAlertController(title: "iCloud Error",
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func dataUpdated() {
        tableView.reloadData()
    }
    
}



