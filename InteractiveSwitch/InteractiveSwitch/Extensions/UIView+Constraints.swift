//
//  UIView+Constraints.swift
//  HabitHelp
//
//  Created by Julia Nikitina on 04.09.2020.
//  Copyright © 2020 Julia Nikitina. All rights reserved.
//

import UIKit

enum Edge {
    case top, bottom, leading, trailing
}

enum Axe {
    case x, y
}

extension UIView {
    
    func add(to parentView: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -insets.right),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: insets.left)
        ])
    }
    
    func pin(to edges: [Edge], of parentView: UIView, offset: CGFloat, withSafeArea: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false
        if !parentView.subviews.contains(self) {
            parentView.addSubview(self)
        }
        
        var constraints = [NSLayoutConstraint]()
        if edges.contains(.top) {
            let anchor = withSafeArea ?
                parentView.safeAreaLayoutGuide.topAnchor :
                parentView.topAnchor

            constraints.append(
                topAnchor.constraint(equalTo: anchor, constant: offset)
            )
        }
        if edges.contains(.bottom) {
            let anchor = withSafeArea ?
                parentView.safeAreaLayoutGuide.bottomAnchor :
                parentView.bottomAnchor

            constraints.append(
                bottomAnchor.constraint(equalTo: anchor, constant: -offset)
            )
        }
        if edges.contains(.leading) {
            let anchor = withSafeArea ?
                parentView.safeAreaLayoutGuide.leadingAnchor :
                parentView.leadingAnchor
            constraints.append(
                leadingAnchor.constraint(equalTo: anchor, constant: offset)
            )
        }
        if edges.contains(.trailing) {
            let anchor = withSafeArea ?
                parentView.safeAreaLayoutGuide.trailingAnchor :
                parentView.trailingAnchor
            constraints.append(
                trailingAnchor.constraint(equalTo: anchor, constant: -offset)
            )
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func addToCenter(of parentView: UIView, excluding axes: [Axe] = []) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        var constraints = [NSLayoutConstraint]()
        if axes.contains(.x) {
            constraints = [
                centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ]
        } else if axes.contains(.y) {
            constraints = [
                centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
            ]
        } else {
            constraints = [
                centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func addToCenter(of parentView: UIView, excluding axe: Axe? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        var constraints = [NSLayoutConstraint]()
        if let axe = axe {
            switch axe {
            case .x:
                constraints = [
                    centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
                ]
            case .y:
                constraints = [
                    centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
                ]
            }
        } else {
            constraints = [
                centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func setSize(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    
}
