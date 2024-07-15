//
//  PlayerViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

final class PlayerViewController: UIViewController {

	var viewModel: PlayerViewModel?
//	private var playerState: SPTAppRemotePlayerState?
	private var uri: String
	private var timer: Timer?
	private var currentTime: Double = 0
	private var durationTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
		return imageView
	}()

	private lazy var label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var slider: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.widthAnchor.constraint(equalToConstant: 300).isActive = true
		slider.thumbTintColor = UIColor.init(cgColor: (CGColor(red: 0, green: 0, blue: 0, alpha: 0.7))) // button
		slider.tintColor = UIColor.init(cgColor: (CGColor(red: 0, green: 0, blue: 0, alpha: 0.7))) // used value
//		slider.value = 0
		slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
		return slider
	}()


	init(_ uri: String) {
		self.uri = uri
		super.init(nibName: nil, bundle: nil)
		self.viewModel = PlayerViewModel(self)
		self.viewModel?.playMusic(uri)
		self.viewModel?.getPlayerState()

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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		viewModel?.network.appRemote.delegate = nil
		lastPlayerState = nil
	}

	func bindViewModel() {
		self.viewModel?.trackPoster.bind { img in
			DispatchQueue.main.async {
				guard let image = img else { return }
				self.imageView.image = image
			}
		}

		self.viewModel?.playerState.bind { playerState in
			if playerState?.track.uri == self.uri {
				guard let playerState = playerState else { return }

				self.lastPlayerState = playerState
				//			self.currentTime = Double(playerState.playbackPosition / 10000)
				print(playerState.track.duration)
				DispatchQueue.main.async {
					self.durationTime = Double(playerState.track.duration / 1000)
					print(self.durationTime)
					print(playerState.track.name)
					self.slider.maximumValue = Float(self.durationTime)
					self.slider.minimumValue = 0
				}
			} else {
				self.viewModel?.getPlayerState()
			}
		}
	}

	func startTimer() {
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
	}

	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	@objc func updateSlider() {
		guard let playerState = lastPlayerState else { return }
		if !playerState.isPaused {
			currentTime += 0.1 // Увеличиваем текущее время на 100 миллисекунд (0.1 секунды)
			if currentTime >= self.durationTime {
				stopTimer()
				currentTime = self.durationTime
			}
			slider.value = Float(currentTime)
			print(currentTime)
//			print(self.slider.maximumValue)
		}
	}

	@objc func sliderValueChanged(_ sender: UISlider) {
		currentTime = Double(sender.value)
	}

	func update(playerState: SPTAppRemotePlayerState) {
//		if lastPlayerState?.track.uri != playerState.track.uri {
//			fetchArtwork(for: playerState.track)
//		}
//		lastPlayerState = playerState
//		trackLabel.text = playerState.track.name
//
//		let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
//		if playerState.isPaused {
//			playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
//		} else {
//			playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
//		}
	}
}

extension PlayerViewController {
	func setup() {
		view.addSubview(slider)

		NSLayoutConstraint.activate([
			slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			slider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
//		viewModel?.network.appRemote.delegate = nil
//		let vc = LogInViewController()
//		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("3")
		lastPlayerState = nil
//		viewModel?.network.appRemote.delegate = nil
//		let vc = LogInViewController()
//		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
	}
}
