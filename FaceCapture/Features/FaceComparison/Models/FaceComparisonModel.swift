//
//  FaceComparisonModel.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit

struct FaceComparisonModel {
    var capturedImage: UIImage?
    var selectedImage: UIImage?
    var comparisonResult: String?
    var isSDKInitialized: Bool
    var isCapturingFace: Bool
    var errorMessage: String?
    
    init() {
        self.capturedImage = nil
        self.selectedImage = nil
        self.comparisonResult = nil
        self.isSDKInitialized = false
        self.isCapturingFace = false
        self.errorMessage = nil
    }
    
    mutating func reset() {
        capturedImage = nil
        selectedImage = nil
        errorMessage = nil
        comparisonResult = nil
        isCapturingFace = false
    }
    
    var canCaptureFace: Bool {
        return isSDKInitialized && !isCapturingFace
    }
}
