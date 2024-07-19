//
//  PlayerViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

final class PlayerViewController: UIViewController {

	var viewModel: PlayerViewModel?
	private var vc: MusicBarController?
	var isRepeatHandler: ((Bool) -> Void)?
	var isShuffleHandler: ((Bool) -> Void)?
	private var isPaused = false
	private var item: SPTAppRemoteContentItem?
	private var timer: Timer?
	private var currentTime: Double = 0
	private var durationTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var isShuffled = false
	private var isRepeat = false

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
		return imageView
	}()

	private lazy var trackLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var artistLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var slider: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.widthAnchor.constraint(equalToConstant: 300).isActive = true
		slider.thumbTintColor = .black// button
		slider.tintColor = .black // used value
		//		slider.value = 0
		slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
		let configuration = UIImage.SymbolConfiguration(pointSize: 12)
		let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)
		slider.setThumbImage(image, for: .normal)
		return slider
	}()

	private lazy var currentTimeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var durationTimeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var playPauseButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
		button.tintColor = .black

		button.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
		return button
	}()

	private lazy var nextButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
		button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configuration), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
		return button
	}()

	private lazy var previousButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
		button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configuration), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
		return button
	}()

	private lazy var shuffleButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
		button.setImage(UIImage(systemName: "shuffle", withConfiguration: configuration), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(didTapShuffleButton), for: .touchUpInside)
		return button
	}()

	private lazy var repeatButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
		button.setImage(UIImage(systemName: "repeat", withConfiguration: configuration), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(didTapRepeatButton), for: .touchUpInside)
		return button
	}()

//	private lazy var closeButton: UIButton = {
//		let button = UIButton()
//		button.translatesAutoresizingMaskIntoConstraints = false
//		let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
//		button.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
//		button.tintColor = .black
//		button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
//		return button
//	}()


	init(item: SPTAppRemoteContentItem) {
		self.item = item
		super.init(nibName: nil, bundle: nil)
		self.viewModel = PlayerViewModel(self)
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		self.viewModel?.subscribeToState()
		self.viewModel?.playMusic(item)
		self.viewModel?.getPoster(for: item)
		self.viewModel?.getPlayerState()
//		closeButton.isHidden = true
	}

	init(playerState: SPTAppRemotePlayerState, currentTime: Double, vc: MusicBarController, isRepeat: Bool, isShuffled: Bool) {
		super.init(nibName: nil, bundle: nil)
		self.vc = vc
		self.viewModel = PlayerViewModel(self)
		self.lastPlayerState = playerState
		self.currentTime = currentTime
		self.setCurrentTime(currentTime)
		self.slider.value = Float(currentTime)
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		self.viewModel?.subscribeToState()
		self.viewModel?.getPoster(for: playerState.track)
		self.isPaused = playerState.isPaused
		self.isRepeat = isRepeat
		self.isShuffled = isShuffled
		self.viewModel?.getPlayerState()
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
	}

	func bindViewModel() {
		self.viewModel?.trackPoster.bind { [weak self] img in
			DispatchQueue.main.async {
				guard let image = img else { return }
				self?.imageView.image = image
			}
		}

		self.viewModel?.playerState.bind { playerState in
			if playerState?.track.uri == self.lastPlayerState?.track.uri {
				guard let playerState = playerState else { return }
				self.lastPlayerState = playerState

				DispatchQueue.main.async {
					self.durationTime = Double(playerState.track.duration / 1000)
					self.trackLabel.text = playerState.track.name
					self.artistLabel.text = playerState.track.artist.name
					self.slider.maximumValue = Float(self.durationTime)
					self.durationTimeLabel.text = self.formatTime(self.durationTime)
					self.slider.minimumValue = 0
					self.startTimer()
					self.update()
				}
			} else {
				self.viewModel?.getPlayerState()
			}
		}
	}

	func upToDate(currentTime: Double) {
		self.currentTime += currentTime
		self.slider.value = Float(currentTime)
	}

	func startTimer() {
		if timer != nil {
			// Если таймер уже запущен, ничего не делаем
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
				self.currentTime += 1 // Увеличиваем текущее время на 100 миллисекунд (0.1 секунды)
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
		let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
		if isShuffled {
			self.shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: configuration), for: .normal)
			self.isShuffled = false
		} else {
			self.shuffleButton.setImage(UIImage(systemName: "infinity", withConfiguration: configuration), for: .normal)
			self.isShuffled = true
		}
		self.isShuffleHandler?(self.isShuffled)
		self.viewModel?.shuffle(self.isShuffled)
	}

	@objc func didTapRepeatButton(_ button: UIButton) {
		guard self.lastPlayerState != nil else { return }
		let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
		if isRepeat {
			self.repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: configuration), for: .normal)
			self.viewModel?.repeatMode(.off)
			self.isRepeat = false
		} else {
			self.repeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: configuration), for: .normal)
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

	// Установка длительности трека и перезапуск таймера
	func setCurrentTime(_ duration: Double) {
		currentTimeLabel.text = formatTime(currentTime)
	}

	func update() {
		let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)

		if isPaused {
			DispatchQueue.main.async {
				self.playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
			}
		} else {
			DispatchQueue.main.async {
				self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)

			}
		}


		let configurationSmall = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
		if isRepeat {
			self.repeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: configurationSmall), for: .normal)
		} else {
			self.repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: configurationSmall), for: .normal)
		}

		if isShuffled {
			self.shuffleButton.setImage(UIImage(systemName: "infinity", withConfiguration: configurationSmall), for: .normal)
		} else {
			self.shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: configurationSmall), for: .normal)
		}
	}
}

extension PlayerViewController {
	func setup() {
		view.addSubview(slider)
		view.addSubview(currentTimeLabel)
		view.addSubview(durationTimeLabel)
		view.addSubview(trackLabel)
		view.addSubview(imageView)
		view.addSubview(artistLabel)
		view.addSubview(playPauseButton)
		view.addSubview(nextButton)
		view.addSubview(previousButton)
		view.addSubview(shuffleButton)
		view.addSubview(repeatButton)
//		view.addSubview(closeButton)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
			imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			trackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
			trackLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
			trackLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			artistLabel.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: 10),
			artistLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
			artistLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			slider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 10),

			currentTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 4),
			currentTimeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),

			durationTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.topAnchor),
			durationTimeLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			playPauseButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20),
			playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20),

			shuffleButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			shuffleButton.trailingAnchor.constraint(equalTo: slider.trailingAnchor),

			repeatButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			repeatButton.leadingAnchor.constraint(equalTo: slider.leadingAnchor),

			previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
			previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20),

//			closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
//			closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
		])
	}
}

extension PlayerViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("1")
		viewModel?.subscribeToState()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("2")
		lastPlayerState = nil
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("3")
		lastPlayerState = nil
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
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
