//
//  Constants.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit

enum AppConstants {
    
    // Design System
    enum Design {
        enum Spacing {
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let xLarge: CGFloat = 32
        }
        
        enum CornerRadius {
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
        }
        
        enum ButtonHeight {
            static let standard: CGFloat = 50
        }
        
        enum ImageSize {
            static let preview: CGFloat = 200
        }
    }
    
    // Colors
    enum Colors {
        static let primary = UIColor.systemBlue
        static let secondary = UIColor.systemGray
        static let background = UIColor.systemBackground
        static let surface = UIColor.secondarySystemBackground
    }
    
    // Strings
    enum Strings {
        static let appTitle = "Face SDK Integration"
        static let captureButtonTitle = "Capture Face"
        static let selectImageButtonTitle = "Select Image"
        static let resetButtonTitle = "Reset"
        static let initializingSDK = "Initializing SDK..."
        static let capturingFace = "Capturing Face..."
        static let sdkNotReady = "SDK Loading..."
    }
}
