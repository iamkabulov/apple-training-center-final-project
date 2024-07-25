//
//  ViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 08.07.2024.
//

import UIKit

class LogInViewController: UIViewController {

	private enum Spacing {
		static let medium: CGFloat = 20
	}

	var viewModel: LogInViewModel?

	// MARK: - Subviews
	private lazy var stackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		return stackView
	}()
	private lazy var connectLabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 20, weight: .bold))
			.setText("Log in to Spotify")
			.build()
	}()

	private lazy var connectButton = {
		var cfg = UIButton.Configuration.plain()
		cfg.imagePadding = 10
		return ButtonBuilder()
			.setConfiguration(cfg)
			.setTitle("Continue with Spotify", for: [])
			.setTintColor(.black)
			.setImage(UIImage(named: "stpGreenIcon"), for: [])
			.setFont(UIFont.preferredFont(forTextStyle: .title2))
			.setBorder(color: UIColor.black.cgColor, width: 2, cornerRadius: 14)
			.addTarget(self, action: #selector(didTapConnect), for: .touchUpInside)
			.build()
	}()

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
		layout()
	}

	override func viewWillAppear(_ animated: Bool) {
		viewModel?.network.appRemote.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	deinit {
		self.viewModel = nil
		print("DEINIT LOGIN")
	}

	@objc func didTapConnect(_ button: UIButton) {
		self.viewModel?.network.appRemote.delegate = self
		viewModel?.getToken() { [weak self] appRemote in
			self?.appRemoteDidEstablishConnection(appRemote)
		}
	}
}

// MARK: Style & Layout
extension LogInViewController {
	func layout() {
		stackView.addSubview(connectLabel)
		stackView.addSubview(connectButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			connectLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: Spacing.medium),
			connectLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

			connectButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
			connectButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
		])
	}
}

// MARK: - SPTAppRemoteDelegate
extension LogInViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = MusicBarController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
	}
}
