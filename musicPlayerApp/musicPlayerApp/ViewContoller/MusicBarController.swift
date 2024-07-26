import UIKit

final class MusicBarController: UITabBarController {

	private lazy var miniPlayerView: MiniPlayerView = {
		let mini = MiniPlayerView()
		mini.translatesAutoresizingMaskIntoConstraints = false
		mini.layer.cornerRadius = 10
		return mini
	}()

	let mainViewController = MainViewController()
	let profileController = SearchViewController()
	let playListController = ListViewController()

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
		self.miniPlayerView.playPauseTappedDelegate = { [weak self] isPlay in
			if isPlay {
				self?.viewModel?.play()
			} else {
				self?.viewModel?.pause()
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
		self.viewModel?.network.appRemote.delegate = self
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
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		cleanupResources()
		self.viewModel = nil
		print("MUSICBAR DELETED")
	}

	private func cleanupResources() {
		self.viewModel?.playerState.unbind()
		self.viewModel?.trackPoster.unbind()
		self.viewModel?.network.appRemote.delegate = nil
		stopTimer()
	}

	func selectedNavController() -> UINavigationController? {
		return self.selectedViewController as? UINavigationController
	}

	@objc private func miniPlayerTapped() {
		guard let playerState = self.lastPlayerState else { return }
		let vc = PlayerViewController(playerState: playerState, currentTime: self.currentTime, vc: self, isRepeat: self.isRepeat, isShuffled: self.isShuffled)

		vc.openArtistViewHandler = { [weak self] artist in
			guard let self = self else { return }
			if let selectedNavController = self.selectedNavController() {
				let targetViewController = ListViewController(artistItem: artist)
				selectedNavController.pushViewController(targetViewController, animated: true)
			} else {
				print("Selected UINavigationController not found")
			}
		}

		vc.upToDate(currentTime: self.currentTime)
		vc.isRepeatHandler = { [weak self] value in
			self?.isRepeat = value
		}

		vc.isShuffleHandler = { [weak self] value in
			self?.isShuffled = value
		}
		vc.modalPresentationStyle = .pageSheet
		self.present(vc, animated: true, completion: nil)
	}

	func setupViews() {
		let homeNav = UINavigationController(rootViewController: mainViewController)
		let searchNav = UINavigationController(rootViewController: profileController)
		let favouriteNav = UINavigationController(rootViewController: playListController)

		mainViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)
		profileController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
		playListController.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "music.note.list"), selectedImage: nil)

		let tabBarList = [homeNav, searchNav, favouriteNav]
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

		miniPlayerView.handler = { [weak self] in
			self?.viewModel?.network.appRemote.delegate = self
		}
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

	// MARK: - Binding ViewModel
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
			self.currentTime += 1
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

// MARK: - SPTAppRemoteDelegate
extension MusicBarController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		cleanupResources()
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = LogInViewController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}
}
