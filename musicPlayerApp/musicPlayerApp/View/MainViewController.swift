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
		self.bindViewModel()
		self.viewModel?.network.fetchContentItems(completionHandler: { item in
			print(item?.title)
		})

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateViewBasedOnConnected()
	}
}

extension MainViewController {
	func layout() {
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(trackLabel)
		stackView.addArrangedSubview(playPauseButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
		bindViewModel()
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
