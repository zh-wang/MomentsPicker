//
//  Observable.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/03/01.
//
//

import Foundation

class Observable<T> {
    
    typealias WillSetObserver = (currentValue: T?, tobeValue: T?) -> ()
    typealias DidSetObserver = (oldValue: T?, currentValue: T?) -> ()
    typealias Observer = (pre: WillSetObserver?, post: DidSetObserver?)
    
    private var observers = Dictionary<String, Observer>()
    
    private var observableProperty: T? {
        willSet(newValue) {
            for (_, observer) in observers {
                observer.pre?(currentValue: observableProperty, tobeValue: newValue)
            }
        }
        didSet{
            for (_, observer) in observers {
                observer.post?(oldValue: oldValue, currentValue: observableProperty)
            }
        }
    }
    
    init(value: T?) {
        self.observableProperty = value
    }
    
    func updateValue(value: T) {
        self.observableProperty = value
    }
    
    func getValue() -> T? {
        return observableProperty
    }
    
    func addObserver(identifier: String, observer: Observer) {
        observers[identifier] = observer
    }
    
    func addObserverPost(identifier: String, didSetObserver: DidSetObserver) {
        observers[identifier] = (nil, didSetObserver)
    }
    
    func removeObserver(identifer: String) {
        observers.removeValueForKey(identifer)
    }
    
    func removeAllObserver() {
        observers.removeAll(keepCapacity: false)
    }

}