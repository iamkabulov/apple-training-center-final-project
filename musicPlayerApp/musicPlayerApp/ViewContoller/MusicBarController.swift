//
//  MusicBarController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 12.07.2024.
//

import UIKit

final class MusicBarController: UITabBarController {

	private lazy var miniPlayerView: MiniPlayerView = {
		let mini = MiniPlayerView()
		mini.translatesAutoresizingMaskIntoConstraints = false
		mini.layer.cornerRadius = 10
		return mini
	}()

	let miniPlayerHeight: CGFloat = 64
	private var viewModel: MusicBarViewModel?
	private var isShuffled = false
	private var isRepeat = false
	private var timer: Timer?
	private var currentTime: Double = 0
	private var durationTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?

	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = MusicBarViewModel(self)
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		startTimer()
		setupViews()
		configure()
		setupMiniPlayer()
		viewModel?.getPlayerState()
		viewModel?.subscribeToState()
		NotificationCenter.default.addObserver(self, selector: #selector(miniPlayerTapped), name: .miniPlayerTapped, object: nil)
		bindViewModel()
		self.miniPlayerView.playPauseTappedDelegate = { isPlay in
			if isPlay {
				self.viewModel?.play()
			} else {
				self.viewModel?.pause()
			}
		}

		let appearance = tabBar.standardAppearance
		appearance.configureWithOpaqueBackground()
		appearance.shadowImage = nil
		appearance.shadowColor = nil
		tabBar.standardAppearance = appearance
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.viewModel?.getPlayerState()
		self.viewModel?.subscribeToState()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.viewModel?.getPlayerState()
		self.viewModel?.subscribeToState()
		self.bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.viewModel?.playerState.unbind()
		self.viewModel?.trackPoster.unbind()
	}

	@objc private func miniPlayerTapped() {
		guard let playerState = self.lastPlayerState else { return }
		let vc = PlayerViewController(playerState: playerState, currentTime: self.currentTime, vc: self, isRepeat: self.isRepeat, isShuffled: self.isShuffled)

		vc.upToDate(currentTime: self.currentTime)
		vc.isRepeatHandler = { value in
			self.isRepeat = value
		}

		vc.isShuffleHandler = { value in
			self.isShuffled = value
		}
		vc.modalPresentationStyle = .pageSheet
		self.present(vc, animated: true, completion: nil)
	}

	func setupViews() {
		let mainViewController = MainViewController()
		let profileController = SearchViewController()
		let playListController = ListViewController()

		let homeNav = UINavigationController(rootViewController: mainViewController)
		mainViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)
		profileController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
		playListController.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "music.note.list"), selectedImage: nil)

		let tabBarList = [homeNav, profileController, playListController]
		self.viewControllers = tabBarList
	}

	private func setupMiniPlayer() {
		miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(miniPlayerView)

		NSLayoutConstraint.activate([
			miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
			miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
			miniPlayerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
			miniPlayerView.heightAnchor.constraint(equalToConstant: miniPlayerHeight)
		])
	}


	func configure() {
		self.tabBar.tintColor = .label
	}

	func update(playerState: SPTAppRemotePlayerState?) {
		guard let playerState = playerState else { return }
		if lastPlayerState?.track.uri != playerState.track.uri {
			self.viewModel?.getPoster(for: playerState.track)
				self.currentTime = 0
				self.startTimer()
		}
		self.startTimer()
		self.miniPlayerView.setTrack(name: playerState.track.name,
									 artist: playerState.track.artist.name,
									 isPaused: playerState.isPaused)
	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.trackPoster.bind { [weak self] trackPoster in
			guard let trackPoster = trackPoster else { return }
			DispatchQueue.main.async {
				self?.miniPlayerView.setPoster(trackPoster)
			}
		}

		self.viewModel?.playerState.bind { [weak self] playerState in
			guard let self = self, let playerState = playerState else { return }
			self.lastPlayerState = playerState
			DispatchQueue.main.async {
				self.update(playerState: playerState)
				self.playerStateDidChange(playerState)
				self.viewModel?.getPoster(for: playerState.track)
				self.durationTime = Double(playerState.track.duration / 1000)
			}
		}
	}

	func startTimer() {
		if timer != nil {
			return
		}
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
	}

	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	@objc func updateValue() {
		guard let playerState = self.lastPlayerState else { return }
		if !playerState.isPaused {
			self.currentTime += 1 // Увеличиваем текущее время на 100 миллисекунд (0.1 секунды)
			if self.currentTime >= self.durationTime {
				self.stopTimer()
				self.currentTime = self.durationTime
				self.currentTime = 0
			}
		}
		self.startTimer()
	}

	func update(_ uri: String) {
		if uri != self.lastPlayerState?.track.uri {
			self.viewModel?.getPlayerState()
		}
		self.viewModel?.subscribeToState()
	}
}

extension MusicBarController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MiniPlayerExpandAnimator(miniPlayerView: miniPlayerView)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MiniPlayerCollapseAnimator(miniPlayerView: miniPlayerView)
	}
}

class MiniPlayerExpandAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	let miniPlayerView: UIView

	init(miniPlayerView: UIView) {
		self.miniPlayerView = miniPlayerView
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let toVC = transitionContext.viewController(forKey: .to) else { return }
		let containerView = transitionContext.containerView
		containerView.addSubview(toVC.view)

		toVC.view.frame = miniPlayerView.frame
		toVC.view.layoutIfNeeded()

		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			toVC.view.frame = containerView.bounds
		}, completion: { finished in
			transitionContext.completeTransition(finished)
		})
	}
}

class MiniPlayerCollapseAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	let miniPlayerView: UIView

	init(miniPlayerView: UIView) {
		self.miniPlayerView = miniPlayerView
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			fromVC.view.frame = self.miniPlayerView.frame
		}, completion: { finished in
			fromVC.view.removeFromSuperview()
			transitionContext.completeTransition(finished)
		})
	}
}

extension MusicBarController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
		DispatchQueue.main.async {
			if playerState.track.uri != self.lastPlayerState?.track.uri {
				self.lastPlayerState = playerState
				self.viewModel?.getPoster(for: playerState.track)
				self.viewModel?.getPlayerState()
			}
			self.update(playerState: playerState)
		}

		self.miniPlayerView.setPlayerState(playerState.isPaused)
		stopTimer()
		startTimer()
	}
}

//MARK: - SPTAppRemoteDelegate
extension MusicBarController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
		viewModel?.network.sessionManager?.renewSession()
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		viewModel?.network.sessionManager?.renewSession()
	}
}
