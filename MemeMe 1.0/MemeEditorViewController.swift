//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Keng Susumpow on 16/5/22.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
    ]
    
    let topTextFieldDelegate = MemeTextFieldDelegate()
    let bottomTextFieldDelegate = MemeTextFieldDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topTextField.delegate = topTextFieldDelegate
        bottomTextField.delegate = bottomTextFieldDelegate
    }
    
    // MARK: Disable a camera button
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        initializeApp()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Retrieve a selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // @TODO: Implement this
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                   imagePickerView.image = image
        }
        
        shareButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Why do we need to implement this?
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //    // @TODO: Why need to be implements?
    //    self.dismiss(animated: true, completion: nil)
    //}
    
    // MARK: Image picker helper function
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Pick an image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    // MARK: Pick an image from camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    // MARK: Share the generated meme
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        shareController.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> () in
            if (completed) {
                self.saveMeme(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(shareController, animated: true, completion: nil)
    }
    
    // MARK: Clear everything
    @IBAction func cancelMeme(_ sender: Any) {
        initializeApp()
    }
    
    // MARK: Keyboard notifications subscription
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Keyboard notifications unsubscription
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Move the view up
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    // MARK: Move the view back down
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            //view.frame.origin.y += getKeyboardHeight(notification)
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Generate Memed Image for sharing
    func generateMemedImage() -> UIImage {
        // @TODO: Hide toolbar and navbar
        setupToolbars(inVisible: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        setupToolbars(inVisible: false)
        
        return memedImage
    }
    
    // Why do we need to do this???
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    // MARK: Setup toolbar visibility
    func setupToolbars(inVisible: Bool) {
        self.topToolbar.isHidden = inVisible
        self.bottomToolbar.isHidden = inVisible
    }
    
    // MARK: Initialize UI Objects
    func initializeApp() {
        shareButton.isEnabled = false
        setupMemeTextFields(textField: topTextField, text: "TOP")
        imagePickerView.image = nil
        setupMemeTextFields(textField: bottomTextField, text: "BOTTOM")
        setupToolbars(inVisible: false)
    }
    
    func setupMemeTextFields(textField: UITextField, text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
    }
}

