//
//  FaceComparisonViewModel.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit
import Combine
import FaceSDK

protocol FaceComparisonViewModelDelegate: AnyObject {
    func viewModelDidUpdateModel(_ model: FaceComparisonModel)
    func viewModelDidEncounterError(_ error: String)
}

final class FaceComparisonViewModel {
    
    // MARK: - Properties
    private var model = FaceComparisonModel()
    private let faceSDKManager: FaceSDKManager
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: FaceComparisonViewModelDelegate?
    
    // MARK: - Computed Properties
    var currentModel: FaceComparisonModel {
        return model
    }
    
    var captureButtonTitle: String {
        if model.isCapturingFace {
            return AppConstants.Strings.capturingFace
        } else if model.isSDKInitialized {
            return AppConstants.Strings.captureButtonTitle
        } else {
            return AppConstants.Strings.sdkNotReady
        }
    }
    
    // MARK: - Initialization
    init(faceSDKManager: FaceSDKManager = FaceSDKManager()) {
        self.faceSDKManager = faceSDKManager
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Subscribe to SDK state changes
        faceSDKManager.isInitializedPublisher  // CAMBIADO: Service -> Manager
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isInitialized in
                self?.model.isSDKInitialized = isInitialized
                self?.notifyDelegate()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func initializeSDK() {
        Task {
            do {
                try await faceSDKManager.initialize()
                print("SDK initialization completed successfully")
            } catch {
                await MainActor.run {
                    self.handleError("Failed to initialize SDK: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startFaceCapture() {
        guard model.canCaptureFace else {
            handleError("SDK not ready or already capturing")
            return
        }
        
        model.isCapturingFace = true
        model.errorMessage = nil
        notifyDelegate()
        
        Task {
            do {
                print("Starting face capture...")
                let capturedImage = try await faceSDKManager.captureForLiveness()
                
                await MainActor.run {
                    self.model.capturedImage = capturedImage
                    self.model.isCapturingFace = false
                    self.notifyDelegate()
                    print("Face capture completed successfully")
                }
                
            } catch {
                await MainActor.run {
                    self.model.isCapturingFace = false
                    self.handleError("Face capture failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setSelectedImage(_ image: UIImage) {
        model.selectedImage = image
        model.errorMessage = nil
        notifyDelegate()
    }
    
    func compareImages() {
        guard let img1 = model.capturedImage, let img2 = model.selectedImage else {
            handleError("Selecciona ambas imágenes antes de comparar.")
            return
        }
        model.comparisonResult = nil
        notifyDelegate()
        
        Task {
            do {
                let similarityScore = try await faceSDKManager.compareFaces(image1: img1, image2: img2)
                
                let percent = Int(round(similarityScore * 100))
                await MainActor.run {
                    self.model.comparisonResult = "Similitud: \(percent)%"
                    self.notifyDelegate()
                }
            } catch {
                await MainActor.run {
                    self.handleError("La comparación ha fallado: \(error.localizedDescription)")
                }
            }
        }
    }

    
    func reset() {
        model.reset()
        notifyDelegate()
    }
    
    func retrySDKInitialization() {
        model.errorMessage = nil
        notifyDelegate()
        initializeSDK()
    }
    
    // MARK: - Private Methods
    private func handleError(_ message: String) {
        model.errorMessage = message
        delegate?.viewModelDidEncounterError(message)
        notifyDelegate()
    }
    
    private func notifyDelegate() {
        delegate?.viewModelDidUpdateModel(model)
    }
}
