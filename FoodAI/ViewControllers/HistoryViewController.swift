import UIKit

class HistoryViewController: UIViewController {
    private let viewModel = HistoryViewModel()
    private var selectedDate = Date()
    
    private lazy var calendarView: UICalendarView = {
        let calendar = UICalendarView()
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.delegate = self
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private lazy var summaryView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Summary"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .orange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(FoodEntryCell.self, forCellReuseIdentifier: "FoodEntryCell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "History"
        view.backgroundColor = .systemBackground
        
        view.addSubview(calendarView)
        view.addSubview(summaryView)
        view.addSubview(tableView)
        
        summaryView.addSubview(summaryTitleLabel)
        summaryView.addSubview(caloriesLabel)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            summaryView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 16),
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            summaryTitleLabel.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 16),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 16),
            
            caloriesLabel.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 8),
            caloriesLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 16),
            caloriesLabel.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        Task {
            await viewModel.loadAllLogs()
            await viewModel.loadLog(for: selectedDate)
            updateUI()
        }
    }
    
    private func updateUI() {
        caloriesLabel.text = "\(Int(viewModel.totalCalories(for: selectedDate))) kcal"
        tableView.reloadData()
    }
}

// MARK: - UICalendarViewDelegate
extension HistoryViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let calories = viewModel.totalCalories(for: date)
        
        if calories > 0 {
            return .customView {
                let view = UIView()
                view.backgroundColor = .orange.withAlphaComponent(0.3)
                view.layer.cornerRadius = 3
                return view
            }
        }
        
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        guard let date = Calendar.current.date(from: previousDateComponents) else { return }
        selectedDate = date
        Task {
            await viewModel.loadLog(for: date)
            updateUI()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries(for: selectedDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodEntryCell", for: indexPath) as! FoodEntryCell
        let entries = viewModel.entries(for: selectedDate)
        cell.configure(with: entries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let entries = viewModel.entries(for: selectedDate)
        let entry = entries[indexPath.row]
        
        Task {
            await viewModel.deleteEntry(entry, from: selectedDate)
            updateUI()
        }
    }
}

// MARK: - FoodEntryCell
class FoodEntryCell: UITableViewCell {
    private lazy var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(foodImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            foodImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            foodImageView.widthAnchor.constraint(equalToConstant: 60),
            foodImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            caloriesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            caloriesLabel.leadingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: 16),
            
            timeLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with entry: FoodAnalysis) {
        titleLabel.text = entry.foodName
        caloriesLabel.text = "\(Int(entry.calories)) kcal"
        timeLabel.text = entry.timestamp.formatted(date: .abbreviated, time: .shortened)
        
        // Load image asynchronously
        Task {
            if let data = try? Data(contentsOf: entry.imageUrl),
               let image = UIImage(data: data) {
                await MainActor.run {
                    foodImageView.image = image
                }
            }
        }
    }
} 