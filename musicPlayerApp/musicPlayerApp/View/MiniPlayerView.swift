//
//  MiniPlayerView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 18.07.2024.
//

import UIKit

class MiniPlayerView: UIView {

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 40
			static let width: CGFloat = 40
		}
		static let small: CGFloat = 2
		static let medium: CGFloat = 8
		static let large: CGFloat = 20
	}

	var playPauseTappedDelegate: ((Bool) -> Void)?
	private let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .default)
	private lazy var pauseImage = UIImage(systemName: "pause.fill", withConfiguration: self.buttonConfiguration)
	private lazy var playImage = UIImage(systemName: "play.fill", withConfiguration: self.buttonConfiguration)
	var handler: (() -> Void)?

	private var currentRotationAngle: CGFloat = 0
	private var isAnimationPaused = false
	private var isPlaying = true
	private lazy var albumImageView: UIImageView = {
		return ImageViewBuilder()
			.setContentMode(.scaleAspectFill)
			.setImage(named: "stpGreenIcon")
			.setCornerRadius(20)
			.setClipsToBounds(true)
			.build()
	}()

	private lazy var songTitleLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 14, weight: .bold))
			.setText("Song")
			.build()
	}()

	private lazy var artistNameLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 12))
			.setTextColor(.systemGray)
			.setText("Artist")
			.build()
	}()

	private lazy var playPauseButton: UIButton = {
		return ButtonBuilder()
			.setImage(self.pauseImage, for: .normal)
			.setTintColor(.black)
			.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
			.build()
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.systemGray3.withAlphaComponent(0.97)
		setupView()
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension MiniPlayerView {
	@objc private func handleTap() {
		NotificationCenter.default.post(name: .miniPlayerTapped, object: nil)
	}

	@objc private func playPauseTapped() {
		let newImage = isPlaying ? playImage : pauseImage
		playPauseButton.setImage(newImage, for: .normal)

		if !isPlaying {
			startAlbumImageRotation()
			self.isPlaying = true
		} else {
			stopAlbumImageRotation()
			handler?()
			self.isPlaying = false
		}
		playPauseTappedDelegate?(self.isPlaying)
	}

	private func startAlbumImageRotation() {
		if albumImageView.layer.animation(forKey: "rotate") == nil {
			let rotation = CABasicAnimation(keyPath: "transform.rotation")
			rotation.fromValue = self.currentRotationAngle
			rotation.toValue = CGFloat.pi * 2
			rotation.duration = 10
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
		let newImage = self.isPlaying ? pauseImage : playImage
		playPauseButton.setImage(newImage, for: .normal)
	}

	private func setupView() {
		addSubview(albumImageView)
		addSubview(songTitleLabel)
		addSubview(artistNameLabel)
		addSubview(playPauseButton)

		NSLayoutConstraint.activate([
			albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.large),
			albumImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			albumImageView.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			albumImageView.heightAnchor.constraint(equalToConstant: Spacing.Size.height),

			songTitleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: Spacing.medium),
			songTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -Spacing.small),
			songTitleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -Spacing.medium),

			artistNameLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
			artistNameLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: Spacing.small),
			artistNameLabel.trailingAnchor.constraint(equalTo: songTitleLabel.trailingAnchor),

			playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.large),
			playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			playPauseButton.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			playPauseButton.heightAnchor.constraint(equalToConstant: Spacing.Size.height),
		])
	}
}

