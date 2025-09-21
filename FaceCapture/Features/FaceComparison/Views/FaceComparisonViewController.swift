//
//  FaceComparisonViewController.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit

final class FaceComparisonViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = FaceComparisonViewModel()
    private lazy var imagePickerService = ImagePickerService(presentingViewController: self)
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.Design.Spacing.large
        stackView.alignment = .fill
        return stackView
    }()
    
    // Status Label
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // Capture Face Button
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(AppConstants.Strings.captureButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = AppConstants.Colors.primary
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.roundCorners()
        button.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Captured Image Container
    private lazy var capturedImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppConstants.Colors.surface
        view.roundCorners()
        view.addBorder()
        view.isHidden = true
        return view
    }()
    
    private lazy var capturedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var capturedImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Captured Face"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // Select Image Button
    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(AppConstants.Strings.selectImageButtonTitle, for: .normal)
        button.setTitleColor(AppConstants.Colors.primary, for: .normal)
        button.backgroundColor = AppConstants.Colors.surface
        button.titleLabel?.font = .systemFont(ofSize:18, weight: .semibold)
        button.roundCorners()
        button.addBorder()
        button.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Selected Image Container
    private lazy var selectedImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppConstants.Colors.surface
        view.roundCorners()
        view.addBorder()
        view.isHidden = true
        return view
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var selectedImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Selected Image"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // Botón para comparar imágenes
    private lazy var compareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Compare Images", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.Colors.primary
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.roundCorners()
        button.isEnabled = true // Lo ocultarás/controlarás cuando lo necesites
        button.alpha = 1.0
        button.addTarget(self, action: #selector(compareButtonTapped), for: .touchUpInside)
        return button
    }()

    // Etiqueta para resultado de la comparación
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = AppConstants.Colors.primary
        label.textAlignment = .center
        label.text = ""
        label.numberOfLines = 0
        label.backgroundColor = AppConstants.Colors.surface
        label.roundCorners()
        return label
    }()

    
    // Reset Button
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(AppConstants.Strings.resetButtonTitle, for: .normal)
        button.setTitleColor(AppConstants.Colors.secondary, for: .normal)
        button.backgroundColor = AppConstants.Colors.surface
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.roundCorners()
        button.addBorder(color: AppConstants.Colors.secondary)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.initializeSDK()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = AppConstants.Strings.appTitle
        view.backgroundColor = AppConstants.Colors.background
        
        // Add main views
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Setup image containers
        setupImageContainers()
        
        // Add components to stack view
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(captureButton)
        stackView.addArrangedSubview(capturedImageContainer)
        stackView.addArrangedSubview(selectImageButton)
        stackView.addArrangedSubview(selectedImageContainer)
        stackView.addArrangedSubview(compareButton)
        stackView.addArrangedSubview(resultLabel)
        stackView.addArrangedSubview(resetButton)
        
        setupConstraints()
    }
    
    private func setupImageContainers() {
        // Captured image container setup
        capturedImageContainer.addSubviews(capturedImageLabel, capturedImageView)
        
        NSLayoutConstraint.activate([
            capturedImageLabel.topAnchor.constraint(equalTo: capturedImageContainer.topAnchor, constant: AppConstants.Design.Spacing.medium),
            capturedImageLabel.leadingAnchor.constraint(equalTo: capturedImageContainer.leadingAnchor, constant: AppConstants.Design.Spacing.medium),
            capturedImageLabel.trailingAnchor.constraint(equalTo: capturedImageContainer.trailingAnchor, constant: -AppConstants.Design.Spacing.medium),
            
            capturedImageView.topAnchor.constraint(equalTo: capturedImageLabel.bottomAnchor, constant: AppConstants.Design.Spacing.small),
            capturedImageView.leadingAnchor.constraint(equalTo: capturedImageContainer.leadingAnchor, constant: AppConstants.Design.Spacing.medium),
            capturedImageView.trailingAnchor.constraint(equalTo: capturedImageContainer.trailingAnchor, constant: -AppConstants.Design.Spacing.medium),
            capturedImageView.bottomAnchor.constraint(equalTo: capturedImageContainer.bottomAnchor, constant: -AppConstants.Design.Spacing.medium),
            capturedImageView.heightAnchor.constraint(equalToConstant: AppConstants.Design.ImageSize.preview)
        ])
        
        // Selected image container setup
        selectedImageContainer.addSubviews(selectedImageLabel, selectedImageView)
        
        NSLayoutConstraint.activate([
            selectedImageLabel.topAnchor.constraint(equalTo: selectedImageContainer.topAnchor, constant: AppConstants.Design.Spacing.medium),
            selectedImageLabel.leadingAnchor.constraint(equalTo: selectedImageContainer.leadingAnchor, constant: AppConstants.Design.Spacing.medium),
            selectedImageLabel.trailingAnchor.constraint(equalTo: selectedImageContainer.trailingAnchor, constant: -AppConstants.Design.Spacing.medium),
            
            selectedImageView.topAnchor.constraint(equalTo: selectedImageLabel.bottomAnchor, constant: AppConstants.Design.Spacing.small),
            selectedImageView.leadingAnchor.constraint(equalTo: selectedImageContainer.leadingAnchor, constant: AppConstants.Design.Spacing.medium),
            selectedImageView.trailingAnchor.constraint(equalTo: selectedImageContainer.trailingAnchor, constant: -AppConstants.Design.Spacing.medium),
            selectedImageView.bottomAnchor.constraint(equalTo: selectedImageContainer.bottomAnchor, constant: -AppConstants.Design.Spacing.medium),
            selectedImageView.heightAnchor.constraint(equalToConstant: AppConstants.Design.ImageSize.preview)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack View
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppConstants.Design.Spacing.large),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppConstants.Design.Spacing.large),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppConstants.Design.Spacing.large),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -AppConstants.Design.Spacing.large),
            
            // Button Heights
            captureButton.heightAnchor.constraint(equalToConstant: AppConstants.Design.ButtonHeight.standard),
            selectImageButton.heightAnchor.constraint(equalToConstant: AppConstants.Design.ButtonHeight.standard),
            resetButton.heightAnchor.constraint(equalToConstant: AppConstants.Design.ButtonHeight.standard),
            compareButton.heightAnchor.constraint(equalToConstant: AppConstants.Design.ButtonHeight.standard)

        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
        imagePickerService.delegate = self
    }
    
    // MARK: - Actions
    @objc private func captureButtonTapped() {
        print("Capture button tapped")
        viewModel.startFaceCapture()
    }
    
    @objc private func selectImageButtonTapped() {
        print("Select image button tapped")
        imagePickerService.showImageSourceSelection()
    }
    
    @objc private func compareButtonTapped() {
        viewModel.compareImages()
    }
    
    @objc private func resetButtonTapped() {
        print("Reset button tapped")
        viewModel.reset()
    }
    
    // MARK: - UI Updates
    private func updateUI(with model: FaceComparisonModel) {
        // Update capture button
        captureButton.setTitle(viewModel.captureButtonTitle, for: .normal)
        captureButton.isEnabled = model.canCaptureFace
        captureButton.alpha = model.canCaptureFace ? 1.0 : 0.6
        
        // Update status label
        if !model.isSDKInitialized {
            statusLabel.text = AppConstants.Strings.initializingSDK
            statusLabel.isHidden = false
        } else if model.isCapturingFace {
            statusLabel.text = AppConstants.Strings.capturingFace
            statusLabel.isHidden = false
        } else {
            statusLabel.isHidden = true
        }
        
        // Update captured image
        if let capturedImage = model.capturedImage {
            capturedImageView.image = capturedImage
            capturedImageContainer.isHidden = false
        } else {
            capturedImageContainer.isHidden = true
        }
        
        // Update selected image
        if let selectedImage = model.selectedImage {
            selectedImageView.image = selectedImage
            selectedImageContainer.isHidden = false
        } else {
            selectedImageContainer.isHidden = true
        }
        
        resultLabel.text = model.comparisonResult ?? ""
    }
}

// MARK: - FaceComparisonViewModelDelegate
extension FaceComparisonViewController: FaceComparisonViewModelDelegate {
    
    func viewModelDidUpdateModel(_ model: FaceComparisonModel) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: model)
        }
    }
    
    func viewModelDidEncounterError(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showRetryAlert(title: "Error", message: error) {
                self?.viewModel.retrySDKInitialization()
            }
        }
    }
}

// MARK: - ImagePickerServiceDelegate
extension FaceComparisonViewController: ImagePickerServiceDelegate {
    
    func imagePickerDidSelectImage(_ image: UIImage) {
        print("Image selected from picker")
        viewModel.setSelectedImage(image)
    }
    
    func imagePickerDidCancel() {
        print("Image picker was cancelled")
    }
}
