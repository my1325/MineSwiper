//
//  NSView+Extensions.swift
//  MineSwiper
//
//  Created by my on 2021/3/9.
//  Copyright © 2021 MZ. All rights reserved.
//

import Cocoa

extension NSView {
    public func addConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: self.superview,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        self.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(width: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: width)
        self.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(height: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        self.superview?.addConstraint(constraint)
    }
    
    public func updateConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        for constraint in self.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? NSView == self) ||
            (constraint.firstAttribute == attribute && constraint.secondItem as? NSView == self) {
                constraint.constant = constant
                break
            }
        }
    }
    
    public func updateConstraint(forWidth width: CGFloat) {
        for constraint in self.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? NSView == self {
                constraint.constant = width
            }
        }
    }
    
    public func updateConstraint(forHeight height: CGFloat) {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? NSView == self {
                constraint.constant = height
            }
        }
    }
}

