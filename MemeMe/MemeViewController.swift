//
//  ViewController.swift
//  MemeMe
//
//  Created by Komil Bagshi on 17/11/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import UIKit
import Photos
class MemeViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
   
    
    //MARK: Outlets
        //imageview
    @IBOutlet var imagePickerView: UIImageView!
        //barbutton
    @IBOutlet var cameraButton: UIBarButtonItem!
        //toolbars
    @IBOutlet var topToolBar: UIToolbar!
    @IBOutlet var buttomToolBar: UIToolbar!
        //textfields
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var buttomTextField: UITextField!
    
    
    let memeTextAttributes:[NSAttributedString.Key : Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
       NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -3
    ]
    

    enum ButtonType: Int {
        case share = 0, cancel, camera, album
    }
    
    // MARK: Actions
    @IBAction func imageFunctionsButton(_ sender: UIBarButtonItem) {
        //based on button tags we select the button type "enum"
        switch(ButtonType(rawValue: sender.tag)!) {
        case .share:
            //code
            print("share clicked")
            let mySavedImage = save()
            let shareItems = ["My Meme", mySavedImage] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    print("not completed.")
                    return
                }
                self.dismiss(animated: true, completion: nil)
                print("user has completed the sharing :D")
            }
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
        case .cancel:
            //no current requerment is requested.
            print("cancel clicked")
            
        case .camera:
            print("camera clicked")
            pickerOption(Type: true)
        case .album:
            print("album clicked")
            pickerOption(Type: false)
        }
    }
    
    func pickerOption(Type: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if Type {
        imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    //save
    func save() -> UIImage {
        //create meme with generated image function
        let meme = Meme(topTextField: topTextField.text, bottomTextField: buttomTextField.text, orginalImage: imagePickerView.image, memedImage: generateMemedImage())
        // add meme to the array in the app delegate
        return meme.memedImage!
    }
    
    // generated meme
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        self.topToolBar.isHidden = true
        self.buttomToolBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.topToolBar.isHidden = false
        self.buttomToolBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        return memedImage
    }
    
    // image picker delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    func setupTextFields(){
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        buttomTextField.defaultTextAttributes = memeTextAttributes
        buttomTextField.textAlignment = .center
    }
    
    // view will appear
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    //keyboard
    func subscribeToKeyboardNotifications() {
            //show
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
            //hide
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    func checker(){
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        //show
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
         if buttomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}

extension MemeViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 0
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
