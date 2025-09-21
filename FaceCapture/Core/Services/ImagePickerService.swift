//
//  ImagePickerService.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit
import PhotosUI

protocol ImagePickerServiceDelegate: AnyObject {
    func imagePickerDidSelectImage(_ image: UIImage)
    func imagePickerDidCancel()
}

final class ImagePickerService: NSObject {
    
    weak var delegate: ImagePickerServiceDelegate?
    private weak var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    func showImageSourceSelection() {
        let alertController = UIAlertController(
            title: "Select Image Source",
            message: "Choose where to get your image from",
            preferredStyle: .actionSheet
        )
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        // Photo Library option
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentPhotosPicker()
        })
        
        // Cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.delegate?.imagePickerDidCancel()
        })
        
        // For iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = presentingViewController?.view
            popover.sourceRect = presentingViewController?.view.bounds ?? .zero
        }
        
        presentingViewController?.present(alertController, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        presentingViewController?.present(imagePicker, animated: true)
    }
    
    private func presentPhotosPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let photosPicker = PHPickerViewController(configuration: configuration)
        photosPicker.delegate = self
        
        presentingViewController?.present(photosPicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            if let image = info[.originalImage] as? UIImage {
                self?.delegate?.imagePickerDidSelectImage(image)
            } else {
                self?.delegate?.imagePickerDidCancel()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.delegate?.imagePickerDidCancel()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ImagePickerService: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let result = results.first else {
                self?.delegate?.imagePickerDidCancel()
                return
            }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self?.delegate?.imagePickerDidSelectImage(image)
                        } else {
                            self?.delegate?.imagePickerDidCancel()
                        }
                    }
                }
            } else {
                self?.delegate?.imagePickerDidCancel()
            }
        }
    }
}
