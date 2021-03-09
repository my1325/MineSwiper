//
//  NSCollection+Extensions.swift
//  MineSwiper
//
//  Created by my on 2021/3/8.
//  Copyright © 2021 MZ. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

@objc protocol NSCollectionViewMouseDelegate: NSObjectProtocol {
    @objc optional func collectionView(_ collectionView: NSCollectionView, shouldRecognizeMouseEventAt indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: NSCollectionView, didRecognizeMouseDownAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: NSCollectionView, didRecognizeMouseUpAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: NSCollectionView, didRecognizeRightMouseUpAt indexPath: IndexPath)
}

extension NSCollectionView {
    
    fileprivate var mouseDelegateIdentifier: UnsafeRawPointer {
        let delegateIdentifier = ObjectIdentifier(NSCollectionViewMouseDelegate.self)
        let integerIdentifier = Int(bitPattern: delegateIdentifier)
        let identifier = UnsafeRawPointer(bitPattern: integerIdentifier)!
        return identifier
    }
    
    fileprivate var mouseGestureRecognizerIdentifier: UnsafeRawPointer {
        let delegateIdentifier = ObjectIdentifier(MSMagicGestureRecognizer.self)
        let integerIdentifier = Int(bitPattern: delegateIdentifier)
        let identifier = UnsafeRawPointer(bitPattern: integerIdentifier)!
        return identifier
    }
    
    var mouseDelegate: NSCollectionViewMouseDelegate? {
        get { return objc_getAssociatedObject(self, mouseDelegateIdentifier) as? NSCollectionViewMouseDelegate }
        set {
            objc_setAssociatedObject(self, mouseDelegateIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var mouseGestureRecognizer: MSMagicGestureRecognizer? {
        var _gestureRecognzier = objc_getAssociatedObject(self, mouseGestureRecognizerIdentifier) as? MSMagicGestureRecognizer
        if _gestureRecognzier == nil {
            _gestureRecognzier = MSMagicGestureRecognizer(target: self, action: #selector(handleMagicGestureRecognizer))
            _gestureRecognzier?.magicDelegate = self
            self.addGestureRecognizer(_gestureRecognzier!)
            objc_setAssociatedObject(self, mouseGestureRecognizerIdentifier, _gestureRecognzier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return _gestureRecognzier
    }
    
    var isEnableMouseGestureRecognize: Bool {
        get {
            return mouseGestureRecognizer?.isEnabled ?? false
        } set {
            mouseGestureRecognizer?.isEnabled = newValue
        }
    }
}

extension NSCollectionView: MSMagicGestureRecognizerDelegate {

    @objc func handleMagicGestureRecognizer() {}

    private func magicGestureRecognizerCanRecognizeIndexPath(_ indexPath: IndexPath) -> Bool {
        return mouseDelegate?.collectionView?(self, shouldRecognizeMouseEventAt: indexPath) ?? true
    }
    
    func magicGestureRecognizerMouseDown(_ gestureRecognizer: MSMagicGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        if let indexPath = self.indexPathForItem(at: location), magicGestureRecognizerCanRecognizeIndexPath(indexPath) {
            mouseDelegate?.collectionView?(self, didRecognizeMouseDownAt: indexPath)
        }
    }
    
    func magicGestureRecognizerMouseUp(_ gestureRecognizer: MSMagicGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        if let indexPath = self.indexPathForItem(at: location), magicGestureRecognizerCanRecognizeIndexPath(indexPath) {
            mouseDelegate?.collectionView?(self, didRecognizeMouseUpAt: indexPath)
        }
    }
    
    func magicGestureRecognizerRightMouseUp(_ gestureRecognizer: MSMagicGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        if let indexPath = self.indexPathForItem(at: location), magicGestureRecognizerCanRecognizeIndexPath(indexPath) {
            mouseDelegate?.collectionView?(self, didRecognizeRightMouseUpAt: indexPath)
        }
    }
}

internal final class MouseDelegateProxy: DelegateProxy<NSCollectionView, NSCollectionViewMouseDelegate>, DelegateProxyType, NSCollectionViewMouseDelegate {
    
    static func registerKnownImplementations() {
        register(make: { MouseDelegateProxy(target: $0) })
    }
    
    static func currentDelegate(for object: NSCollectionView) -> NSCollectionViewMouseDelegate? {
        return object.mouseDelegate
    }
    
    static func setCurrentDelegate(_ delegate: NSCollectionViewMouseDelegate?, to object: NSCollectionView) {
        object.mouseDelegate = delegate
    }
    
    weak var target: NSCollectionView?
    init(target: NSCollectionView) {
        self.target = target
        super.init(parentObject: target, delegateProxy: MouseDelegateProxy.self)
    }
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

extension Reactive where Base: NSCollectionView {
    
    var mouseDelegate: MouseDelegateProxy {
        return MouseDelegateProxy.proxy(for: base)
    }
    
    var mouseDown: ControlEvent<IndexPath> {
        let source = self.mouseDelegate.methodInvoked(#selector(NSCollectionViewMouseDelegate.collectionView(_:didRecognizeMouseDownAt:))).map({
            return try castOrThrow(IndexPath.self, $0[1])
        })
        return ControlEvent(events: source)
    }
    
    var mouseUp: ControlEvent<IndexPath> {
        let source = self.mouseDelegate.methodInvoked(#selector(NSCollectionViewMouseDelegate.collectionView(_:didRecognizeMouseUpAt:))).map({
            return try castOrThrow(IndexPath.self, $0[1])
        })
        return ControlEvent(events: source)
    }
    
    var rightMouseUp: ControlEvent<IndexPath> {
        let source = self.mouseDelegate.methodInvoked(#selector(NSCollectionViewMouseDelegate.collectionView(_:didRecognizeRightMouseUpAt:))).map({
            return try castOrThrow(IndexPath.self, $0[1])
        })
        return ControlEvent(events: source)
    }
}
