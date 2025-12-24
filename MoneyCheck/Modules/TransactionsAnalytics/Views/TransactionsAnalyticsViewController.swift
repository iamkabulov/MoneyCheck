import UIKit
import Combine
import SnapKit
import SwiftUI

final class TransactionsAnalyticsViewController: UIViewController {

    private lazy var hostingController = UIHostingController(rootView: donutView)
    @Published var items: [DonutChartItem] = []
    private let viewModel: TransactionsAnalyticsViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var donutView = DonutChartView(
        viewModel: self.viewModel,
        onLegendTap: { [weak self] item in
            self?.handleLegendTap(item)
        }
    )

    init(viewModel: TransactionsAnalyticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDonutChart()
    }

    deinit {
        print("TransactionsAnalyticsViewController deinit")
    }

    private func bindViewModel() {
        viewModel.$chartDonutItems
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.items, on: self)
                .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }

    private func setupDonutChart() {
        // 4️⃣ Добавляем как child VC
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // 5️⃣ Autolayout

        hostingController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func handleLegendTap(_ item: DonutChartItem) {
        print("Tapped legend:", item.title)

        // варианты:
        // • открыть список транзакций
        // • отфильтровать таблицу
        // • подсветить сектор
        // • показать BottomSheet
    }

}
