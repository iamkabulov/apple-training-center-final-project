import UIKit

final class MainViewController: UIViewController {
	var viewModel: MainViewModel?
	private var currentTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var dataSource: [SPTAppRemoteContentItem]? {
		didSet {
			self.tableView.updateDataSource(dataSource ?? [])
		}
	}

	private lazy var tableView: MainTableView = {
		let view = MainTableView(viewModel: self.viewModel, viewController: self)
		return view
	}()

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.alignment = .center
		return stackView
	}()

	//MARK: - View LifeCycle
	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = MainViewModel(self)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		self.viewModel?.network.appRemote.delegate = self
//		self.bindViewModel() /// интересно, зачем это нужно было?
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		self.layout()
		self.viewModel?.getContentItems()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	deinit {
		cleanupResources()
		print("MAIN VIEW DEINIT")
	}
}

extension MainViewController {
	func layout() {
		stackView.addSubview(tableView)
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			tableView.topAnchor.constraint(equalTo: stackView.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -64)
		])
	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.contentItems.bind { [weak self] content in
			guard let self = self, let content = content else { return }
			self.dataSource = content.filter { $0.children != nil }
		}

		self.viewModel?.itemPosters.bind { [weak self] dict in
			self?.tableView.reloadData()
		}
	}

	private func cleanupResources() {
		self.viewModel?.contentItems.unbind()
		self.viewModel?.itemPosters.unbind()
		self.viewModel?.network.appRemote.delegate = nil
		self.viewModel = nil
	}
}

//MARK: - SPTAppRemoteDelegate
extension MainViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		cleanupResources()
		self.viewModel = nil
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = LogInViewController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}
}
