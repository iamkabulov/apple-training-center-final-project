//
//  TabbarExtension.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 23.07.2024.
//

import UIKit

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
