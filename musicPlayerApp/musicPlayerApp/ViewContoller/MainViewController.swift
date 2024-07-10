//
//  MainViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import Foundation

final class MainViewController: UIViewController {

	var viewModel: MainViewModel?
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var dataSource: [SPTAppRemoteContentItem]?
	private var count = 0
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

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private lazy var trackLabel: UILabel = {
		let trackLabel = UILabel()
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.font = UIFont.preferredFont(forTextStyle: .body)
		trackLabel.textAlignment = .center
		return trackLabel
	}()

	private lazy var playPauseButton: UIButton = {
		let playPauseButton = UIButton()
		playPauseButton.translatesAutoresizingMaskIntoConstraints = false
		playPauseButton.addTarget(self, action: #selector(didTapPauseOrPlay), for: .primaryActionTriggered)
		return playPauseButton
	}()
	private lazy var signOutButton: UIButton = {
		let signOutButton = UIButton()
		signOutButton.translatesAutoresizingMaskIntoConstraints = false
		signOutButton.setTitle("Sign out", for: .normal)
		signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		signOutButton.addTarget(self, action: #selector(didTapSignOut(_:)), for: .touchUpInside)
		return signOutButton
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
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .brown
		self.layout()
		self.viewModel?.getPlayerState()
		self.viewModel?.getContentItems()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateViewBasedOnConnected()
	}
}

extension MainViewController {
	func layout() {
		stackView.addArrangedSubview(tableView)
//		stackView.addArrangedSubview(imageView)
//		stackView.addArrangedSubview(trackLabel)
//		stackView.addArrangedSubview(playPauseButton)
		stackView.addArrangedSubview(signOutButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

//			recommendationCollectionView.topAnchor.constraint(equalTo: stackView.topAnchor),
//			recommendationCollectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
//			recommendationCollectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

			tableView.topAnchor.constraint(equalTo: stackView.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
		])
	}

	func update(playerState: SPTAppRemotePlayerState?) {
		guard let playerState = playerState else { return }
		if lastPlayerState?.track.uri != playerState.track.uri {
			self.viewModel?.getPoster(for: playerState.track)
		}
		lastPlayerState = playerState
		trackLabel.text = playerState.track.name

		let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
		if playerState.isPaused {
			playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
		} else {
			playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
		}
	}

	func updateViewBasedOnConnected() {
		self.bindViewModel()
		if viewModel?.network.appRemote.isConnected == true {
			imageView.isHidden = false
			trackLabel.isHidden = false
			playPauseButton.isHidden = false
		}
		else { // show login
			imageView.isHidden = true
			trackLabel.isHidden = true
			playPauseButton.isHidden = true
		}
	}

	//MARK: - Actions
	@objc func didTapPauseOrPlay(_ button: UIButton) {
		if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
			self.viewModel?.network.appRemote.playerAPI?.resume(nil)
		} else {
			self.viewModel?.network.appRemote.playerAPI?.pause(nil)
		}
	}

	@objc func didTapSignOut(_ button: UIButton) {
		if viewModel?.network.appRemote.isConnected == true {
			viewModel?.network.appRemote.disconnect()
			viewModel?.network.appRemote.delegate = nil
			let vc = LogInViewController()
			vc.modalPresentationStyle = .fullScreen
			self.present(vc, animated: true)
		}
	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.trackPoster.bind { [weak self] trackPoster in
			guard let trackPoster = trackPoster else { return }
			DispatchQueue.main.async {
				self?.imageView.image = trackPoster
			}
		}

		self.viewModel?.playerState.bind { [weak self] playerState in
			guard let self = self, let playerState = playerState else { return }
			DispatchQueue.main.async {
				self.update(playerState: playerState)
			}
		}

		self.viewModel?.contentItems.bind { [weak self] content in
			guard let self = self, let content = content else { return }
			self.dataSource = content
			self.count = 0
			self.tableView.reloadData()
		}

	}
}
//MARK: - SPTAppRemoteDelegate
extension MainViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
		updateViewBasedOnConnected()
		appRemote.playerAPI?.delegate = self
		appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			}
		})
		self.viewModel?.getPlayerState()
		self.viewModel?.getContentItems()
		DispatchQueue.main.async {
			self.count = 0
			self.tableView.reloadData()
		}
		//		self.viewModel?.network.appRemote.
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
		updateViewBasedOnConnected()
		lastPlayerState = nil
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		updateViewBasedOnConnected()
		lastPlayerState = nil
	}
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension MainViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
		DispatchQueue.main.async {
			self.update(playerState: playerState)
		}
	}
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}
	

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else { return UITableViewCell() }
		guard let data = self.dataSource else { return cell }
		if data.count > self.count {
			cell.setData(data: data[count].children)
		}
		count += 1
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dataSource?[section].title
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return dataSource?.count ?? 1
	}
}
