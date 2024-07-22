//
//  MainViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import Foundation

final class MainViewController: UIViewController {
	var viewModel: MainViewModel?
	private var currentTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var dataSource: [SPTAppRemoteContentItem]?

	private lazy var tableView: UITableView = {
		let view = UITableView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.separatorStyle = .none
		view.register(SectionCell.self, forCellReuseIdentifier: SectionCell.identifier)
		view.delegate = self
		view.rowHeight = SectionCell.rowHeight
		view.dataSource = self
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

//	private lazy var signOutButton: UIButton = {
//		let signOutButton = UIButton()
//		signOutButton.translatesAutoresizingMaskIntoConstraints = false
//		signOutButton.setTitle("Sign out", for: .normal)
//		signOutButton.setTitleColor(.black, for: .normal)
//		signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//		signOutButton.addTarget(self, action: #selector(didTapSignOut(_:)), for: .touchUpInside)
//		return signOutButton
//	}()

	//MARK: - View LifeCycle
	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = MainViewModel(self)
//		self.viewModel?.network.appRemote.playerAPI?.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		self.bindViewModel()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		self.layout()
		self.viewModel?.getPlayerState()
		self.viewModel?.getContentItems()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.viewModel?.contentItems.unbind()
		self.viewModel?.itemPosters.unbind()
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

	//MARK: - Actions
//	@objc func didTapSignOut(_ button: UIButton) {
//		if viewModel?.network.appRemote.isConnected == true {
//			viewModel?.network.appRemote.disconnect()
//			viewModel?.network.appRemote.delegate = nil
//			let vc = LogInViewController()
//			vc.modalPresentationStyle = .fullScreen
//			self.present(vc, animated: true)
//		}
//	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.contentItems.bind { [weak self] content in
			guard let self = self, let content = content else { return }
			self.dataSource = content.filter { $0.children != nil }
			self.tableView.reloadData()
		}

		self.viewModel?.itemPosters.bind { [weak self] dict in
			self?.tableView.reloadData()
		}
	}
}
//MARK: - SPTAppRemoteDelegate
extension MainViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
//		updateViewBasedOnConnected()
		self.viewModel?.getContentItems()
		self.tableView.reloadData()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
//		viewModel?.network.appRemote.delegate = nil
//		let vc = LogInViewController()
//		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
		viewModel?.network.sessionManager?.renewSession()
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		//		viewModel?.network.appRemote.delegate = nil
		//		let vc = LogInViewController()
		//		vc.modalPresentationStyle = .fullScreen
		//		self.present(vc, animated: true)
		viewModel?.network.sessionManager?.renewSession()
	}
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let data = dataSource else { return 0 }
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else { return UITableViewCell() }
		cell.selectionStyle = .none
		guard let data = self.dataSource, let viewModel = self.viewModel else { return cell }
		cell.setData(viewController: self, viewModel: viewModel, data: data[indexPath.row])
		return cell
	}
}
