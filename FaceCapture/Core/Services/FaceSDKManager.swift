//
//  FaceSDKManager.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit
import FaceSDK
import Combine

final class FaceSDKManager {
    
    // MARK: - Published Properties
    @Published private(set) var isInitialized = false
    @Published private(set) var isInitializing = false
    
    // MARK: - Public Publishers
    var isInitializedPublisher: AnyPublisher<Bool, Never> {
        $isInitialized.eraseToAnyPublisher()
    }
    
    var isInitializingPublisher: AnyPublisher<Bool, Never> {
        $isInitializing.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    func initialize() async throws {
        guard !isInitialized && !isInitializing else { return }
        
        await MainActor.run {
            isInitializing = true
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            FaceSDK.service.initialize { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.isInitializing = false
                    
                    if success {
                        self?.isInitialized = true
                        continuation.resume()
                    } else {
                        let errorMessage = error?.localizedDescription ?? "Unknown SDK initialization error"
                        continuation.resume(throwing: FaceSDKError.initializationFailed(errorMessage))
                    }
                }
            }
        }
    }
    
    // MARK: - Face Capture (UIKit Native)
    func captureForLiveness() async throws -> UIImage {
        guard isInitialized else {
            throw FaceSDKError.notInitialized
        }
        
        guard let topViewController = await getCurrentTopViewController() else {
            throw FaceSDKError.noViewController
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            
            DispatchQueue.main.async {
                let configuration = LivenessConfiguration { config in
                    config.livenessType = .passive
                }
                
                print("Starting liveness from: \(type(of: topViewController))")
                
                FaceSDK.service.startLiveness(
                    from: topViewController,
                    animated: true,
                    configuration: configuration,
                    onLiveness: { response in
                        print("onLiveness called - Status: \(response.liveness)")
                        
                        guard !hasResumed else {
                            print("Already resumed, ignoring onLiveness")
                            return
                        }
                        hasResumed = true
                        
                        if let error = response.error {
                            let errorMessage = self.handleLivenessError(error as NSError)
                            continuation.resume(throwing: FaceSDKError.captureSessionFailed(errorMessage))
                            return
                        }
                        
                        if response.liveness.rawValue == 0, let image = response.image {
                            print("Face capture successful! Image size: \(image.size)")
                            continuation.resume(returning: image)
                        } else {
                            print("Liveness failed or no image available")
                            continuation.resume(throwing: FaceSDKError.captureSessionFailed("Face validation failed"))
                        }
                    },
                    completion: {
                        print("completion called - UI dismissed")

                    }
                )
            }
        }
    }
    
    @MainActor
    private func getCurrentTopViewController() async -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: \.isKeyWindow),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return getTopViewController(from: rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController ?? navigationController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController ?? tabBarController)
        }
        
        if let presentedViewController = viewController.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        return viewController
    }
    
    func compareFaces(image1: UIImage, image2: UIImage) async throws -> Double {
        // Transforma UIImage a Data si es necesario
        let faces = [
            MatchFacesImage(image: image1, imageType: .printed),
            MatchFacesImage(image: image2, imageType: .printed)
        ]
        let request = MatchFacesRequest(images: faces)
        
        return try await withCheckedThrowingContinuation { continuation in
            FaceSDK.service.matchFaces(request) { response in
                if let sdkError = response.error {
                    continuation.resume(throwing: FaceSDKError.captureSessionFailed(sdkError.localizedDescription))
                    return
                }
                // Mapear resultados a Double, ignorando los nulos
                let validResults = response.results.compactMap { $0.similarity?.doubleValue }
                
                if let best = validResults.max() {
                    continuation.resume(returning: best)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "com.face",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la similitud"]
                    ))
                }
            }
        }
    }

    
    private func handleLivenessError(_ error: NSError) -> String {
        switch error.code {
        case LivenessError.cancelled.rawValue:
            return "Face capture was cancelled"
        case LivenessError.noLicense.rawValue:
            return "SDK license error. Please contact support."
        case LivenessError.processingTimeout.rawValue:
            return "Timeout occurred. Please try again."
        case LivenessError.cameraHasNoPermission.rawValue:
            return "Camera permission required. Please enable in Settings."
        case LivenessError.cameraNotAvailable.rawValue:
            return "Camera not available on this device."
        case LivenessError.processingFailed.rawValue:
            return "Face processing failed. Please ensure good lighting and remove glasses."
        case LivenessError.apiCallFailed.rawValue:
            return "Network error occurred. Please check your connection."
        default:
            return "Face capture failed: \(error.localizedDescription)"
        }
    }
    
    deinit {
        if isInitialized {
            FaceSDK.service.deinitialize()
        }
    }
}

enum FaceSDKError: LocalizedError {
    case initializationFailed(String)
    case notInitialized
    case noViewController
    case captureSessionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .initializationFailed(let message):
            return "Failed to initialize Face SDK: \(message)"
        case .notInitialized:
            return "Face SDK is not initialized"
        case .noViewController:
            return "Could not find a view controller to present from"
        case .captureSessionFailed(let message):
            return message
        }
    }
}
