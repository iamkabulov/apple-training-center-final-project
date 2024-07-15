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

	// MARK: App Life Cycle
	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = LogInViewModel(self)
		self.viewModel?.network.appRemote.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
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
//		stackView.spacing = 20
		stackView.alignment = .center

		connectLabel.translatesAutoresizingMaskIntoConstraints = false
		connectLabel.text = "Log in to Spotify"
//		connectLabel.textColor = .
		connectLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

		connectButton.translatesAutoresizingMaskIntoConstraints = false
		var cfg = UIButton.Configuration.plain()
		cfg.imagePadding = 10
		connectButton.configuration = cfg
		connectButton.setTitle("Continue with Spotify", for: [])
		connectButton.tintColor = .black
		connectButton.setImage(UIImage(named: "stpGreenIcon"), for: [])
		connectButton.imageView?.contentMode = .scaleAspectFit
		connectButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
		connectButton.layer.borderColor = UIColor.black.cgColor
		connectButton.layer.borderWidth = 2
		connectButton.layer.cornerRadius = 14
		connectButton.addTarget(self, action: #selector(didTapConnect), for: .touchDown)
	}

	func layout() {

		stackView.addSubview(connectLabel)
		stackView.addSubview(connectButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			connectLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 20),
			connectLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

			connectButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
			connectButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
		])
	}

	func updateViewBasedOnConnected() {
		if viewModel?.network.appRemote.isConnected == true {
			connectButton.isHidden = true
			connectLabel.isHidden = true
		}
		else { // show login
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
		let vc = MusicBarController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//		updateViewBasedOnConnected()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//		updateViewBasedOnConnected()
	}
}
