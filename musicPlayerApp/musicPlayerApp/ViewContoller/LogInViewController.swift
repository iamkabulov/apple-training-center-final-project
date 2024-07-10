//
//  ViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 08.07.2024.
//

import UIKit

class LogInViewController: UIViewController {

	var viewModel: LogInViewModel?

	// MARK: - Subviews
	let stackView = UIStackView()
	let connectLabel = UILabel()
	let connectButton = UIButton(type: .custom)
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
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	@objc func didTapConnect(_ button: UIButton) {
		guard let sessionManager = viewModel?.network.sessionManager else { return }
		sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: "")
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
	}

	func layout() {

		stackView.addArrangedSubview(connectLabel)
		stackView.addArrangedSubview(connectButton)
		stackView.addArrangedSubview(signOutButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}

	func updateViewBasedOnConnected() {
		if viewModel?.network.appRemote.isConnected == true {
			connectButton.isHidden = true
			signOutButton.isHidden = false
			connectLabel.isHidden = true
		}
		else { // show login
			signOutButton.isHidden = true
			connectButton.isHidden = false
			connectLabel.isHidden = false
		}
	}
}

// MARK: - SPTAppRemoteDelegate
extension LogInViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		updateViewBasedOnConnected()
		viewModel?.network.appRemote.delegate = nil
		let vc = MainViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		updateViewBasedOnConnected()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		updateViewBasedOnConnected()
	}
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension LogInViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
	}
}
