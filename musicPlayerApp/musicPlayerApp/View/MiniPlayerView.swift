//
//  MiniPlayerView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 18.07.2024.
//

import UIKit

class MiniPlayerView: UIView {

	var playPauseTappedDelegate: ((Bool) -> Void)?
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
		label.text = "Artis"
		return label
	}()

	lazy var playPauseButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
		startAlbumImageRotation()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func handleTap() {
		NotificationCenter.default.post(name: .miniPlayerTapped, object: nil)
	}

	@objc private func playPauseTapped() {
		let newImage = isPlaying ? UIImage(systemName: "play.fill") : UIImage(systemName: "pause.fill")
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
		let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotation.toValue = NSNumber(value: Double.pi * 2)
		rotation.duration = 10 // Duration of one full rotation
		rotation.isCumulative = true
		rotation.repeatCount = .infinity
		albumImageView.layer.add(rotation, forKey: "rotationAnimation")
	}

	private func stopAlbumImageRotation() {
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
			playPauseButton.widthAnchor.constraint(equalToConstant: 24),
			playPauseButton.heightAnchor.constraint(equalToConstant: 24),
		])
	}
}

