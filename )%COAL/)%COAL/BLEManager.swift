//
//  BLEManager.swift
//  >COAL
//
//  Created by Martin Pavlov on 5/30/18.
//  Copyright © 2018 11A. All rights reserved.
//

class BLEManager: NSObject, BLEManagable {
    
    fileprivate var shouldStartScanning = false
    
    private var centralManager: CBCentralManager?
    private var isCentralManagerReady: Bool {
        get {
            guard let centralManager = centralManager else {
                return false
            }
            return centralManager.state != .poweredOff && centralManager.state != .unauthorized && centralManager.state != .unsupported
        }
    }
    
    fileprivate var connectingPeripheral: CBPeripheral?
    fileprivate var connectedPeripheral: CBPeripheral?
    
    fileprivate var delegates: [Weak<AnyObject>] = []
    fileprivate func bleDelegates() -> [BLEManagerDelegate] {
        return delegates.flatMap { $0.object as? BLEManagerDelegate }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
        startScanning()
    }
    
    func startScanning() {
        guard let centralManager = centralManager, isCentralManagerReady == true else {
            return
        }
        
        if centralManager.state != .poweredOn {
            shouldStartScanning = true
        } else {
            shouldStartScanning = false
            centralManager.scanForPeripherals(withServices: [BLEConstants.TemperatureService], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func stopScanning() {
        shouldStartScanning = false
        centralManager?.stopScan()
    }
    
    func addDelegate(_ delegate: BLEManagerDelegate) {
        delegates.append(Weak(object: delegate))
    }
    
    func removeDelegate(_ delegate: BLEManagerDelegate) {
        if let index = delegates.index(where: { $0.object === delegate }) {
            delegates.remove(at: index)
        }
    }
}
