//
//  MiniPlayerView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 18.07.2024.
//

import UIKit

class MiniPlayerView: UIView {

	var playPauseTappedDelegate: ((Bool) -> Void)?
	private let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .default)
	private var currentRotationAngle: CGFloat = 0
	private var isAnimationPaused = false
	private var isPlaying = true
	lazy var albumImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.image = UIImage(named: "stpGreenIcon")
		imageView.layer.cornerRadius = 20
		imageView.clipsToBounds = true
		return imageView
	}()

	lazy var songTitleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		label.text = "Song"
		return label
	}()

	lazy var artistNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = .systemGray
		label.text = "Artis"
		return label
	}()

	lazy var playPauseButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "pause.fill",
								withConfiguration: self.buttonConfiguration),
						for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		backgroundColor = UIColor.systemGray3.withAlphaComponent(0.97)
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func handleTap() {
		NotificationCenter.default.post(name: .miniPlayerTapped, object: nil)
	}

	@objc private func playPauseTapped() {
		let playingImage = UIImage(systemName: "play.fill", withConfiguration: self.buttonConfiguration)
		let pausedImage = UIImage(systemName: "pause.fill", withConfiguration: self.buttonConfiguration)
		let newImage = isPlaying ? playingImage : pausedImage
		playPauseButton.setImage(newImage, for: .normal)

		if !isPlaying {
			startAlbumImageRotation()
			self.isPlaying = true
		} else {
			stopAlbumImageRotation()
			self.isPlaying = false
		}
		playPauseTappedDelegate?(self.isPlaying)
	}

	private func startAlbumImageRotation() {
		if albumImageView.layer.animation(forKey: "rotate") == nil {
			let rotation = CABasicAnimation(keyPath: "transform.rotation")
			rotation.fromValue = self.currentRotationAngle
			rotation.toValue = CGFloat.pi * 2
			rotation.duration = 10 // Duration of one full rotation
			rotation.isRemovedOnCompletion = false
			rotation.repeatCount = .infinity
			albumImageView.layer.add(rotation, forKey: "rotationAnimation")
		}
	}

	private func stopAlbumImageRotation() {
		if let presentationLayer = albumImageView.layer.presentation() {
			let currentRotation = presentationLayer.value(forKeyPath: "transform.rotation.z") as! CGFloat
			albumImageView.layer.transform = CATransform3DMakeRotation(currentRotation, 0, 0, 1)
			self.currentRotationAngle = currentRotation
		}
		albumImageView.layer.removeAnimation(forKey: "rotationAnimation")
	}

	func setTrack(name: String, artist: String, isPaused: Bool) {
		self.songTitleLabel.text = name
		self.artistNameLabel.text = artist
		if isPaused {
			stopAlbumImageRotation()
		} else {
			startAlbumImageRotation()
		}
	}

	func setPoster(_ img: UIImage) {
		self.albumImageView.image = img
	}

	func setPlayerState(_ value: Bool) {
		self.isPlaying = !value
		let playingImage = UIImage(systemName: "play.fill", withConfiguration: self.buttonConfiguration)
		let pausedImage = UIImage(systemName: "pause.fill", withConfiguration: self.buttonConfiguration)
		let newImage = self.isPlaying ? pausedImage : playingImage
		playPauseButton.setImage(newImage, for: .normal)
	}

	private func setupView() {
		backgroundColor = .gray
		addSubview(albumImageView)
		addSubview(songTitleLabel)
		addSubview(artistNameLabel)
		addSubview(playPauseButton)

		NSLayoutConstraint.activate([
			albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			albumImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			albumImageView.widthAnchor.constraint(equalToConstant: 40),
			albumImageView.heightAnchor.constraint(equalToConstant: 40),

			songTitleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 8),
			songTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
			songTitleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),

			artistNameLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
			artistNameLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 2),
			artistNameLabel.trailingAnchor.constraint(equalTo: songTitleLabel.trailingAnchor),

			playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			playPauseButton.widthAnchor.constraint(equalToConstant: 40),
			playPauseButton.heightAnchor.constraint(equalToConstant: 40),
		])
	}
}

