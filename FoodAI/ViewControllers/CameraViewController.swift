import UIKit
import AVFoundation
import PhotosUI

class CameraViewController: UIViewController {
    private let viewModel = FoodAnalysisViewModel()
    
    private lazy var cameraPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var centerSquare: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 60
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 32.5
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var flipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Analyzing food..."
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [spinner, label])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        if let previewLayer = viewModel.getPreviewLayer() {
            previewLayer.frame = cameraPreviewView.bounds
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(cameraPreviewView)
        view.addSubview(overlayView)
        overlayView.addSubview(centerSquare)
        view.addSubview(controlsStackView)
        view.addSubview(loadingView)
        
        controlsStackView.addArrangedSubview(galleryButton)
        controlsStackView.addArrangedSubview(captureButton)
        controlsStackView.addArrangedSubview(flipButton)
        
        NSLayoutConstraint.activate([
            cameraPreviewView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            centerSquare.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            centerSquare.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            centerSquare.widthAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.8),
            centerSquare.heightAnchor.constraint(equalTo: centerSquare.widthAnchor),
            
            controlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            captureButton.widthAnchor.constraint(equalToConstant: 65),
            captureButton.heightAnchor.constraint(equalToConstant: 65),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCamera() {
        Task {
            do {
                try await viewModel.setupCamera()
                if let previewLayer = viewModel.getPreviewLayer() {
                    previewLayer.frame = cameraPreviewView.bounds
                    cameraPreviewView.layer.addSublayer(previewLayer)
                }
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func captureButtonTapped() {
        loadingView.isHidden = false
        viewModel.capturePhoto()
    }
    
    @objc private func flipButtonTapped() {
        Task {
            do {
                try await viewModel.flipCamera()
                if let previewLayer = viewModel.getPreviewLayer() {
                    previewLayer.frame = cameraPreviewView.bounds
                    cameraPreviewView.layer.addSublayer(previewLayer)
                }
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func galleryButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension CameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(error)
                }
                return
            }
            
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.showAnalysis(for: image)
                }
            }
        }
    }
    
    private func showAnalysis(for image: UIImage) {
        let analysisVC = AnalysisViewController(image: image, viewModel: viewModel)
        let nav = UINavigationController(rootViewController: analysisVC)
        present(nav, animated: true)
    }
} 