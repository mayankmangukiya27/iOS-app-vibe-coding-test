import UIKit

class AnalysisViewController: UIViewController {
    private let image: UIImage
    private let viewModel: FoodAnalysisViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var detailsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var foodNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .orange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nutrientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var ingredientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    
    init(image: UIImage, viewModel: FoodAnalysisViewModel) {
        self.image = image
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        analyzeImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        imageView.image = image
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(detailsView)
        
        detailsView.addSubview(foodNameLabel)
        detailsView.addSubview(caloriesLabel)
        detailsView.addSubview(nutrientsStackView)
        detailsView.addSubview(ingredientsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            detailsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            detailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            foodNameLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 16),
            foodNameLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            foodNameLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            caloriesLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 8),
            caloriesLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            caloriesLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            nutrientsStackView.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 16),
            nutrientsStackView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            nutrientsStackView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            ingredientsStackView.topAnchor.constraint(equalTo: nutrientsStackView.bottomAnchor, constant: 16),
            ingredientsStackView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            ingredientsStackView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            ingredientsStackView.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Analysis"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Analyze",
            style: .done,
            target: self,
            action: #selector(analyzeButtonTapped)
        )
    }
    
    private func analyzeImage() {
        Task {
            do {
                loadingView.isHidden = false
                view.addSubview(loadingView)
                NSLayoutConstraint.activate([
                    loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                    loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                viewModel.capturedImage = image
                await viewModel.analyzeFood()
                
                if viewModel.foodAnalysis != nil {
                    updateUI()
                } else {
                    loadingView.isHidden = true
                    showError(viewModel.error ?? FoodAIError.imageProcessingFailed)
                }
            } catch {
                loadingView.isHidden = true
                showError(error)
            }
        }
    }
    
    private func updateUI() {
        guard let analysis = viewModel.foodAnalysis else { return }
        
        foodNameLabel.text = analysis.foodName
        caloriesLabel.text = "\(Int(analysis.calories)) kcal"
        
        // Update nutrients
        nutrientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let nutrientsLabel = UILabel()
        nutrientsLabel.text = "Nutrients"
        nutrientsLabel.font = .boldSystemFont(ofSize: 18)
        nutrientsStackView.addArrangedSubview(nutrientsLabel)
        
        let nutrients = [
            ("Protein", analysis.nutrients.protein, UIColor.red),
            ("Carbs", analysis.nutrients.carbs, UIColor.blue),
            ("Fat", analysis.nutrients.fat, UIColor.yellow),
            ("Fiber", analysis.nutrients.fiber, UIColor.green)
        ]
        
        for (name, value, color) in nutrients {
            let label = UILabel()
            let attachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
            attachment.image = UIImage(systemName: "circle.fill")?
                .withConfiguration(config)
                .withTintColor(color)
            
            let attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: " \(name): \(String(format: "%.1f", value))g"))
            
            label.attributedText = attributedString
            nutrientsStackView.addArrangedSubview(label)
        }
        
        // Update ingredients
        ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = .boldSystemFont(ofSize: 18)
        ingredientsStackView.addArrangedSubview(ingredientsLabel)
        
        for ingredient in analysis.ingredients {
            let label = UILabel()
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "checkmark.circle.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12))
            
            let attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: " \(ingredient)"))
            
            label.attributedText = attributedString
            ingredientsStackView.addArrangedSubview(label)
        }
    }
    
    private func showError(_ error: Error) {
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Get detailed error information
            let title = "Analysis Failed"
            var message = ""
            
            if let localizedError = error as? LocalizedError {
                // Add error description
                if let description = localizedError.errorDescription {
                    message += description
                }
                
                // Add failure reason if available
                if let reason = localizedError.failureReason {
                    message += "\n\nReason: \(reason)"
                }
                
                // Add recovery suggestion if available
                if let suggestion = localizedError.recoverySuggestion {
                    message += "\n\nSuggestion: \(suggestion)"
                }
            } else {
                message = error.localizedDescription
            }
            
            // Create alert
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            }
            alert.addAction(okAction)
            
            // Ensure the view controller is in the window hierarchy
            if self.view.window != nil {
                // Check if we're already presenting something
                if let presented = self.presentedViewController {
                    presented.dismiss(animated: true) { [weak self] in
                        self?.present(alert, animated: true)
                    }
                } else {
                    self.present(alert, animated: true)
                }
            } else {
                // If not in window hierarchy, dismiss immediately
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func analyzeButtonTapped() {
        analyzeImage()
    }
} 
