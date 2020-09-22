//
//  SwitchView.swift
//  InteractiveSwitch
//
//  Created by Julia Nikitina on 21.09.2020.
//  Copyright © 2020 Julia Nikitina. All rights reserved.
//

import UIKit

final class InteractiveSwitch: UIControl {
    
    private var isOn: Bool = false {
        didSet {
            guard isOn != oldValue else { return }
            updateState()
        }
    }
    
    
    private var onLabel: UILabel!
    private var offLabel: UILabel!
    private var toggleViewConstraint: NSLayoutConstraint!
    
    private lazy var togglView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.pin(to: [.top, .bottom], of: self, offset: 5)
        view.setWidth(50)
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
    
    private func setup() {
        backgroundColor = .red
        
        setTap()
        setLabels()
        setToggleConstraint()
        
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
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
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
        toggleViewConstraint = togglView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
        toggleViewConstraint?.isActive = true
    }
    
    @objc private func tapReceived() {
        isOn.toggle()
    }
    
    private func updateState() {
        
        let constant = isOn ? bounds.width - togglView.bounds.width - 5 : 5
        
        self.toggleViewConstraint.constant = CGFloat(constant)

        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = self.isOn ? .green : .red
            self.offLabel.alpha = self.isOn ? 0 : 1
            self.onLabel.alpha = self.isOn ? 1 : 0
            self.layoutIfNeeded()
        }
    }
    
    
}

extension InteractiveSwitch {
    
    private enum Constants {
        static let isOn = "I'm on!"
        static let isOff = "I'm off!"
    }
    
}

