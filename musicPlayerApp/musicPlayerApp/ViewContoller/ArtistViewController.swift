//
//  ArtistViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 23.07.2024.
//

import UIKit

class ArtistViewController: UIViewController {

	var viewModel: ArtistViewModel?
	var artistDetails: ArtistEntity?

	// MARK: - Subviews
	let stackView = UIStackView()
	let connectLabel = UILabel()
	let artistItem: SPTAppRemoteArtist

	// MARK: App Life Cycle
	init(item: SPTAppRemoteArtist) {
		self.artistItem = item
		super.init(nibName: nil, bundle: nil)
		self.viewModel = ArtistViewModel(self)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		self.title = self.artistItem.name
		viewModel?.getArtistDetails(with: self.artistItem)

		style()
		layout()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		self.navigationController?.popViewController(animated: true)
	}

	deinit {
		print("DEINIT ARTIST")
	}

	func bindViewModel() {
		self.viewModel?.details.bind { [weak self] details in
			self?.artistDetails = details
			DispatchQueue.main.async {
				self?.connectLabel.text = self?.artistDetails?.type
			}
		}
	}

//	@objc func didTapConnect(_ button: UIButton) {
//		viewModel.getToken() { appRemote in
//			self.appRemoteDidEstablishConnection(appRemote)
//		}
//	}
}

// MARK: Style & Layout
extension ArtistViewController {
	func style() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center

		connectLabel.translatesAutoresizingMaskIntoConstraints = false
		connectLabel.text = "Log in to Spotify"
		connectLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

	}

	func layout() {

		stackView.addSubview(connectLabel)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			connectLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 20),
			connectLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

		])
	}
}

// MARK: - SPTAppRemoteDelegate
extension ArtistViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		let vc = MusicBarController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//		viewModel?.network.sessionManager?.renewSession()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//		updateViewBasedOnConnected()
//		viewModel?.network.sessionManager?.renewSession()
	}
}
