//
//  PlayerViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

final class PlayerViewController: UIViewController {

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 300
			static let width: CGFloat = 300
		}
		static let small: CGFloat = 4
		static let medium: CGFloat = 10
		static let large: CGFloat = 30
	}

	let configurationLarge = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
	let configurationSmall = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
	let configurationExSmall = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)

	var viewModel: PlayerViewModel?
	private var vc: MusicBarController?
	var isRepeatHandler: ((Bool) -> Void)?
	var isShuffleHandler: ((Bool) -> Void)?
	var openArtistViewHandler: ((SPTAppRemoteArtist) -> Void)?
	var artistItem: SPTAppRemoteArtist?
	private var isPaused = false
	private var timer: Timer?
	private var currentTime: Double = 0
	private var durationTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var isShuffled = false
	private var isRepeat = false
	private var isAdded = false

	private var imageView = ImageViewBuilder()
			.build()

	private lazy var trackLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 22, weight: .bold))
			.setTextColor(.label)
			.build()
	}()

	private lazy var artistButton: UIButton = {
		return ButtonBuilder()
			.setTitleColor(.systemGray2, for: .normal)
			.addTarget(self, action: #selector(didTappedArtist), for: .touchUpInside)
			.setTextAlignment(.left)
			.build()
	}()

	private lazy var slider: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.widthAnchor.constraint(equalToConstant: Spacing.Size.width).isActive = true
		slider.thumbTintColor = .black// button
		slider.tintColor = .black // used value
		slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
		let configuration = UIImage.SymbolConfiguration(pointSize: 12)
		let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)
		slider.setThumbImage(image, for: .normal)
		return slider
	}()

	private lazy var currentTimeLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.preferredFont(forTextStyle: .body))
			.setTextColor(.label)
			.build()
	}()

	private lazy var durationTimeLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.preferredFont(forTextStyle: .body))
			.setTextColor(.label)
			.build()
	}()

	private lazy var playPauseButton: UIButton = {
		return ButtonBuilder()
			.setTintColor(.black)
			.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
			.build()
	}()

	private lazy var nextButton: UIButton = {
		return ButtonBuilder()
			.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
			.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configurationSmall), for: .normal)
			.setTintColor(.black)
			.build()
	}()

	private lazy var previousButton: UIButton = {
		return ButtonBuilder()
			.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
			.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configurationSmall), for: .normal)
			.setTintColor(.black)
			.build()
	}()

	private lazy var shuffleButton: UIButton = {
		return ButtonBuilder()
			.addTarget(self, action: #selector(didTapShuffleButton), for: .touchUpInside)
			.setImage(UIImage(systemName: "shuffle", withConfiguration: configurationExSmall), for: .normal)
			.setTintColor(.black)
			.build()
	}()

	private lazy var repeatButton: UIButton = {
		return ButtonBuilder()
			.addTarget(self, action: #selector(didTapRepeatButton), for: .touchUpInside)
			.setImage(UIImage(systemName: "repeat", withConfiguration: configurationExSmall), for: .normal)
			.setTintColor(.black)
			.build()
	}()

	private lazy var addRemoveButton: UIButton = {
		return ButtonBuilder()
			.addTarget(self, action: #selector(addRemoveTapped), for: .touchUpInside)
			.setTitle("Добавить в избранное", for: .normal)
			.setTitleColor(.black, for: .normal)
			.build()
	}()

	init(playerState: SPTAppRemotePlayerState, currentTime: Double, vc: MusicBarController, isRepeat: Bool, isShuffled: Bool) {
		super.init(nibName: nil, bundle: nil)
		self.vc = vc
		self.viewModel = PlayerViewModel(self)
		self.viewModel?.network.appRemote.delegate = self
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		self.viewModel?.subscribeToState()
		self.viewModel?.getPoster(for: playerState.track)
		self.viewModel?.getPlayerState()
		self.lastPlayerState = playerState
		self.currentTime = currentTime
		self.setCurrentTime(currentTime)
		self.slider.value = Float(currentTime)
		self.isPaused = playerState.isPaused
		self.isRepeat = isRepeat
		self.isShuffled = isShuffled
		self.startTimer()
		self.update()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		startTimer()
		setup()
		view.backgroundColor = .systemBackground
		self.navigationController?.navigationBar.topItem?.title = ""
		bindViewModel()
		viewModel?.subscribeToState()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setCurrentTime(currentTime)
		self.slider.value = Float(currentTime)
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		self.viewModel?.subscribeToState()
		self.isPaused = self.lastPlayerState?.isPaused ?? false
		self.viewModel?.getPlayerState()
		self.startTimer()
		self.update()
		bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		clearResources()
	}

	deinit {
		print("Player DEINIT")
	}

	func bindViewModel() {
		self.viewModel?.trackPoster.bind { [weak self] img in
			DispatchQueue.main.async {
				guard let image = img else { return }
				self?.imageView.image = image
			}
		}

		self.viewModel?.playerState.bind { [weak self] playerState in
			if playerState?.track.uri == self?.lastPlayerState?.track.uri {
				guard let playerState = playerState else { return }
				self?.lastPlayerState = playerState
				self?.isAdded = playerState.track.isSaved
				self?.isAdded(playerState.track.isSaved)
				DispatchQueue.main.async {
					self?.durationTime = Double(playerState.track.duration / 1000)
					self?.trackLabel.text = playerState.track.name
					self?.artistItem = playerState.track.artist
					self?.isPaused = playerState.isPaused
					self?.artistButton.setTitle(playerState.track.artist.name, for: .normal)
					self?.slider.maximumValue = Float(self?.durationTime ?? 0)
					self?.durationTimeLabel.text = self?.formatTime(self?.durationTime ?? 0)
					self?.slider.minimumValue = 0
					self?.startTimer()
					self?.update()
				}
			} else {
				self?.viewModel?.getPlayerState()
			}
		}
	}

	func upToDate(currentTime: Double) {
		self.currentTime = currentTime
		self.slider.value = Float(currentTime)
	}

	func startTimer() {
		if timer != nil {
			return
		}
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
	}

	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	@objc func updateSlider() {
		DispatchQueue.main.async {
			if !self.isPaused {
				self.currentTime += 1
				if self.currentTime >= self.durationTime {
					self.stopTimer()
					self.currentTime = self.durationTime
					self.currentTime = 0
					self.slider.value = 0
				}
				self.slider.value = Float(self.currentTime)
				self.setCurrentTime(self.currentTime)
			}
			self.slider.value = Float(self.currentTime)
			self.setCurrentTime(self.currentTime)
			self.startTimer()
		}
	}

	@objc func addRemoveTapped() {
		guard let playerState = self.lastPlayerState else { return }
		if isAdded {
			self.addRemoveButton.setTitle("Добавить в избранное", for: .normal)
			self.addRemoveButton.setTitleColor(.black, for: .normal)
			viewModel?.removeFromLibrary(uri: playerState.track.uri)
			isAdded = false
		} else {
			self.addRemoveButton.setTitle("Удалить из избранного", for: .normal)
			self.addRemoveButton.setTitleColor(.red, for: .normal)
			viewModel?.addToLibrary(uri: playerState.track.uri)
			isAdded = true
		}
	}

	@objc func didTappedArtist() {
		self.dismiss(animated: true)
		guard let artistItem = self.artistItem else { return }
		openArtistViewHandler?(artistItem)
	}

	@objc func sliderValueChanged(_ sender: UISlider) {
		currentTime = Double(sender.value)
		viewModel?.seekToPosition(Int(sender.value))
		self.updateSlider()
	}

	@objc func didTapPauseOrPlay(_ button: UIButton) {
		if isPaused {
			viewModel?.play()
			startTimer()
			isPaused = false
		} else {
			viewModel?.pause()
			stopTimer()
			isPaused = true
		}
		self.update()
	}

	@objc func didTapNextButton(_ button: UIButton) {
		self.currentTime = 0
		self.slider.value = 0
		self.updateSlider()
		self.viewModel?.next()
		self.isRepeat = false
		self.isRepeatHandler?(self.isRepeat)
		self.update()
	}

	@objc func didTapPreviousButton(_ button: UIButton) {
		self.currentTime = 0
		self.slider.value = 0
		self.updateSlider()
		self.viewModel?.previous()
		self.isRepeat = false
		self.isRepeatHandler?(self.isRepeat)
		self.update()
	}

	@objc func didTapShuffleButton(_ button: UIButton) {
		if isShuffled {
			self.shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: configurationExSmall), for: .normal)
			self.isShuffled = false
		} else {
			self.shuffleButton.setImage(UIImage(systemName: "infinity", withConfiguration: configurationExSmall), for: .normal)
			self.isShuffled = true
		}
		self.isShuffleHandler?(self.isShuffled)
		self.viewModel?.shuffle(self.isShuffled)
	}

	@objc func didTapRepeatButton(_ button: UIButton) {
		guard self.lastPlayerState != nil else { return }
		if isRepeat {
			self.repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: configurationExSmall), for: .normal)
			self.viewModel?.repeatMode(.off)
			self.isRepeat = false
		} else {
			self.repeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: configurationExSmall), for: .normal)
			self.viewModel?.repeatMode(.track)
			self.isRepeat = true
		}
		isRepeatHandler?(self.isRepeat)
	}

	private func formatTime(_ seconds: Double) -> String {
		let minutes = Int(seconds) / 60
		let remainingSeconds = Int(seconds) % 60
		return String(format: "%d:%02d", minutes, remainingSeconds)
	}

	func setCurrentTime(_ duration: Double) {
		currentTimeLabel.text = formatTime(currentTime)
	}

	func update() {
		if isPaused {
			self.playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configurationLarge), for: .normal)
		} else {
			self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configurationLarge), for: .normal)
		}

		if isRepeat {
			self.repeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: configurationExSmall), for: .normal)
		} else {
			self.repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: configurationExSmall), for: .normal)
		}

		if isShuffled {
			self.shuffleButton.setImage(UIImage(systemName: "infinity", withConfiguration: configurationExSmall), for: .normal)
		} else {
			self.shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: configurationExSmall), for: .normal)
		}
	}

	func isAdded(_ value: Bool) {
		if value {
			self.addRemoveButton.setTitle("Удалить из избранного", for: .normal)
			self.addRemoveButton.setTitleColor(.red, for: .normal)
		} else {
			self.addRemoveButton.setTitle("Добавить в избранное", for: .normal)
			self.addRemoveButton.setTitleColor(.black, for: .normal)
		}
	}

	func clearResources() {
		viewModel?.trackPoster.unbind()
		viewModel?.playerState.unbind()
		viewModel?.network.appRemote.delegate = nil
		viewModel?.network.appRemote.playerAPI?.delegate = nil
		viewModel = nil
		timer?.invalidate()
		timer = nil
	}
}

extension PlayerViewController {
	func setup() {
		view.addSubview(slider)
		view.addSubview(currentTimeLabel)
		view.addSubview(durationTimeLabel)
		view.addSubview(trackLabel)
		view.addSubview(imageView)
		view.addSubview(artistButton)
		view.addSubview(playPauseButton)
		view.addSubview(nextButton)
		view.addSubview(previousButton)
		view.addSubview(shuffleButton)
		view.addSubview(repeatButton)
		view.addSubview(addRemoveButton)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.large),
			imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			imageView.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			imageView.heightAnchor.constraint(equalToConstant: Spacing.Size.height),

			trackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Spacing.medium),
			trackLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
			trackLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			artistButton.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: Spacing.small),
			artistButton.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
			artistButton.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			slider.topAnchor.constraint(equalTo: artistButton.bottomAnchor, constant: Spacing.medium),

			currentTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: Spacing.small),
			currentTimeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),

			durationTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.topAnchor),
			durationTimeLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			playPauseButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: Spacing.large),
			playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: Spacing.medium),

			shuffleButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			shuffleButton.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			repeatButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			repeatButton.leadingAnchor.constraint(equalTo: slider.leadingAnchor),

			previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -Spacing.medium),

			addRemoveButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: Spacing.medium),
			addRemoveButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
		])
	}
}

extension PlayerViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("1")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("2")
		lastPlayerState = nil
		viewModel?.network.appRemote.delegate = nil
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		lastPlayerState = nil
		clearResources()
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = LogInViewController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}
}

extension PlayerViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
		if playerState.track.uri != self.lastPlayerState?.track.uri {
			self.lastPlayerState = playerState
			self.viewModel?.getPoster(for: playerState.track)
			self.viewModel?.getPlayerState()
			if isRepeat {
				self.viewModel?.repeatMode(.track)
			}
		}
		self.vc?.playerStateDidChange(playerState)
	}
}
