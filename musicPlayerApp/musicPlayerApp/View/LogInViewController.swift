//
//  ViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 08.07.2024.
//

import UIKit

class LogInViewController: UIViewController {

	var viewModel: LogInViewModel?

	private var lastPlayerState: SPTAppRemotePlayerState?

	// MARK: - Subviews
	let stackView = UIStackView()
	let connectLabel = UILabel()
	let connectButton = UIButton(type: .custom)
//	let imageView = UIImageView()
//	let trackLabel = UILabel()
//	let playPauseButton = UIButton(type: .system)
	let signOutButton = UIButton(type: .system)

	// MARK: App Life Cycle
	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = LogInViewModel(self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		style()
		layout()
//		bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateViewBasedOnConnected()
	}

	func update(playerState: SPTAppRemotePlayerState?) {
		guard let playerState = playerState else { return }
		if lastPlayerState?.track.uri != playerState.track.uri {
			self.viewModel?.getPoster(for: playerState.track)
		}
		lastPlayerState = playerState
//		trackLabel.text = playerState.track.name

		let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
		if playerState.isPaused {
//			playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
		} else {
//			playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
		}
	}

	// MARK: - Actions
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
		}
	}

	@objc func didTapConnect(_ button: UIButton) {
		guard let sessionManager = viewModel?.network.sessionManager else { return }
		sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: "")
	}

	// MARK: - Private Helpers
	private func presentAlertController(title: String, message: String, buttonTitle: String) {
		DispatchQueue.main.async {
			let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
			let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
			controller.addAction(action)
			self.present(controller, animated: true)
		}
	}
}

// MARK: Style & Layout
extension LogInViewController {
	func style() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.alignment = .center

		connectLabel.translatesAutoresizingMaskIntoConstraints = false
		connectLabel.text = "Log in to Spotify"
//		connectLabel.font = UIFont.preferredFont(forTextStyle: .title1)
		connectLabel.textColor = .white
		connectLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

		connectButton.translatesAutoresizingMaskIntoConstraints = false
		var cfg = UIButton.Configuration.plain()
		cfg.imagePadding = 10
		connectButton.configuration = cfg
		connectButton.setTitle("Continue with Spotify", for: [])
		connectButton.tintColor = .systemGreen
		connectButton.setImage(UIImage(named: "stpGreenIcon"), for: [])
		connectButton.imageView?.contentMode = .scaleAspectFit
		connectButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
		connectButton.layer.borderColor = UIColor.systemGreen.cgColor
		connectButton.layer.borderWidth = 2
		connectButton.layer.cornerRadius = 14
		connectButton.addTarget(self, action: #selector(didTapConnect), for: .primaryActionTriggered)

//		imageView.translatesAutoresizingMaskIntoConstraints = false
//		imageView.contentMode = .scaleAspectFit

//		trackLabel.translatesAutoresizingMaskIntoConstraints = false
//		trackLabel.font = UIFont.preferredFont(forTextStyle: .body)
//		trackLabel.textAlignment = .center

//		playPauseButton.translatesAutoresizingMaskIntoConstraints = false
//		playPauseButton.addTarget(self, action: #selector(didTapPauseOrPlay), for: .primaryActionTriggered)

		signOutButton.translatesAutoresizingMaskIntoConstraints = false
		signOutButton.setTitle("Sign out", for: .normal)
		signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		signOutButton.addTarget(self, action: #selector(didTapSignOut(_:)), for: .touchUpInside)
	}

	func layout() {

		stackView.addArrangedSubview(connectLabel)
		stackView.addArrangedSubview(connectButton)
//		stackView.addArrangedSubview(imageView)
//		stackView.addArrangedSubview(trackLabel)
//		stackView.addArrangedSubview(playPauseButton)
		stackView.addArrangedSubview(signOutButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}

	func updateViewBasedOnConnected() {
//		bindViewModel()
		if viewModel?.network.appRemote.isConnected == true {
			connectButton.isHidden = true
			signOutButton.isHidden = false
			connectLabel.isHidden = true
//			imageView.isHidden = false
//			trackLabel.isHidden = false
//			playPauseButton.isHidden = false
		}
		else { // show login
			signOutButton.isHidden = true
			connectButton.isHidden = false
			connectLabel.isHidden = false
//			imageView.isHidden = true
//			trackLabel.isHidden = true
//			playPauseButton.isHidden = true
		}
	}

//	func bindViewModel() {
//		self.viewModel?.trackPoster.bind { [weak self] trackPoster in
//			guard let trackPoster = trackPoster else { return }
//			DispatchQueue.main.async {
////				self?.imageView.image = trackPoster
//			}
//		}
//
//		self.viewModel?.playerState.bind { [weak self] playerState in
//			guard let self = self, let playerState = playerState else { return }
//			DispatchQueue.main.async {
//				self.update(playerState: playerState)
//			}
//		}
//	}
}

// MARK: - SPTAppRemoteDelegate
extension LogInViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		updateViewBasedOnConnected()
//		appRemote.playerAPI?.delegate = self
		appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			}
		})
//		self.viewModel?.getPlayerState()
		viewModel?.network.appRemote.delegate = nil
		let vc = MainViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		updateViewBasedOnConnected()
		lastPlayerState = nil
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		updateViewBasedOnConnected()
		lastPlayerState = nil
	}
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension LogInViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
//		update(playerState: playerState)
	}
}
