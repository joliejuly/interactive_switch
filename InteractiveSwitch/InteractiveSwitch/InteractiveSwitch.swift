//
//  SwitchView.swift
//  InteractiveSwitch
//
//  Created by Julia Nikitina on 21.09.2020.
//  Copyright © 2020 Julia Nikitina. All rights reserved.
//

import UIKit

final class InteractiveSwitchWithAnimator: InteractiveSwitch {

    override func setup(shouldActivateToggleConstraints: Bool = true) {
        super.setup(shouldActivateToggleConstraints: false)
        
        toggleLayer.frame = CGRect(x: 5, y: 5, width: 50, height: self.bounds.height - 10)
        toggleLayer.cornerRadius = toggleLayer.frame.height * 0.25
        toggleLayer.backgroundColor = UIColor.white.cgColor

        layer.addSublayer(toggleLayer)
    }
    
    override func animateToggleView(to position: CGFloat) {
        let animator = AlphaAnimator { [weak self] updatedValue in
            self?.toggleLayer.frame.origin.x = updatedValue
        }
        animator.animate(toggleLayer.frame.origin.x, toValue: position)
        #warning("почему дефолтная анимация CALayer выглядит рваной?")
        // toggleLayer.frame.origin.x = position
    }
    
    override func animate(duration: Double, onAlpha: CGFloat, offAlpha: CGFloat) {
        let onAnimator = AlphaAnimator { [weak self] updatedValue in
            self?.onLabel.alpha = updatedValue
            self?.greenView.alpha = updatedValue
        }
        
        let offAnimator = AlphaAnimator { [weak self] updatedValue in
            self?.offLabel.alpha = updatedValue
            self?.redView.alpha = updatedValue
        }
        offAnimator.animate(self.offLabel.alpha, toValue: offAlpha)
        offAnimator.animate(self.redView.alpha, toValue: offAlpha)
        onAnimator.animate(self.onLabel.alpha, toValue: onAlpha)
        onAnimator.animate(self.greenView.alpha, toValue: onAlpha)
    }
}

class InteractiveSwitch: UIControl {
    
    private var isOn: Bool = false {
        didSet {
            updateState()
        }
    }

    fileprivate var onLabel: UILabel!
    fileprivate var offLabel: UILabel!
    fileprivate var toggleViewConstraint: NSLayoutConstraint!
    
    fileprivate var endTogglePosition: CGFloat {
        var toggleWidth = togglView.bounds.width
        toggleWidth = toggleWidth == 0 ? toggleLayer.frame.width : toggleWidth
        return bounds.width - toggleWidth - 5
    }
    
    fileprivate let toggleLayer = CALayer()
    
    fileprivate lazy var togglView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var redView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = bounds.height * 0.25
        view.add(to: self)
        return view
    }()
    
    fileprivate lazy var greenView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = bounds.height * 0.25
        view.add(to: self)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.25
        togglView.layer.cornerRadius = togglView.bounds.height * 0.25
    }
    
    fileprivate func animateToggleView(to position: CGFloat) {
        toggleViewConstraint?.constant = position
    }
    
    fileprivate func animate(duration: Double, onAlpha: CGFloat, offAlpha: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
            self.offLabel.alpha = offAlpha
            self.redView.alpha = offAlpha
            self.onLabel.alpha = onAlpha
            self.greenView.alpha = onAlpha
        }
    }
    
    fileprivate func setup(shouldActivateToggleConstraints: Bool = true) {
        backgroundColor = .red
        
        setTap()
        setPan()
        setBackViews()
        setLabels()
        
        if shouldActivateToggleConstraints {
            setToggleConstraint()
        }
    }
    
    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    private func setTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapReceived))
        addGestureRecognizer(tap)
    }
    
    private func setPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panReceived))
        self.addGestureRecognizer(pan)
    }
    
    private func setBackViews() {
        greenView.alpha = 0
        redView.alpha = 1
    }
    
    private func setLabels() {
        onLabel = makeLabel(text: Constants.isOn)
        offLabel = makeLabel(text: Constants.isOff)
        
        [onLabel, offLabel].forEach {
            $0.addToCenter(of: self, excluding: .x)
        }
        onLabel.pin(to: [.leading], of: self, offset: 16)
        offLabel.pin(to: [.trailing], of: self, offset: 16)
        
        onLabel.alpha = 0
    }
    
    private func setToggleConstraint() {
        
        togglView.pin(to: [.top, .bottom], of: self, offset: 5)
        togglView.setWidth(50)
        
        toggleViewConstraint = togglView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
        toggleViewConstraint?.isActive = true
        bringSubviewToFront(togglView)
    }
    
    @objc private func tapReceived() {
        isOn.toggle()
    }
    
    @objc private func panReceived(sender: UIPanGestureRecognizer) {
        
        defer { sender.setTranslation(.zero, in: togglView) }
        
        let velocity = sender.velocity(in: togglView).x
        
        // set swipe
        let velocityCoefficient = abs(velocity) > 700 ? velocity : 0
        
        let positionChange = sender.translation(in: togglView).x
        let normalizedPositionChange = (positionChange + velocityCoefficient) * 1.2
        
        
        var currentPosition = toggleViewConstraint?.constant ?? togglView.frame.origin.x
        currentPosition = currentPosition == 0 ? toggleLayer.frame.origin.x : currentPosition
        
        
        let onAlpha = (currentPosition + positionChange) / endTogglePosition
        let offAlpha = (endTogglePosition - (currentPosition + positionChange) ) / endTogglePosition
        
        switch sender.state {
        case .changed, .began:
            var newPosition: CGFloat
            if currentPosition + normalizedPositionChange >= endTogglePosition {
                newPosition = endTogglePosition
            } else if currentPosition + normalizedPositionChange <= 5 {
                newPosition = 5
            } else {
                newPosition = currentPosition + normalizedPositionChange
            }
            animateToggleView(to: newPosition)
            animate(duration: 0.1, onAlpha: onAlpha, offAlpha: offAlpha)

        case .ended:
            let isOn = onAlpha >= offAlpha
            self.isOn = isOn
        default:
            break
        }
    }
    
    private func updateState() {
        
        let constant = isOn ? endTogglePosition : 5
        toggleViewConstraint?.constant = CGFloat(constant)
        toggleLayer.frame.origin.x = constant

        animate(duration: 0.3, onAlpha: isOn ? 1 : 0, offAlpha: isOn ? 0 : 1)
    }
}

extension InteractiveSwitch {
    
    private enum Constants {
        static let isOn = "I'm on!"
        static let isOff = "I'm off!"
    }
}

