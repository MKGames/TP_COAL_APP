//
//  CentralManager.swift
//  >COAL
//
//  Created by Martin Pavlov on 5/30/18.
//  Copyright © 2018 11A. All rights reserved.
//

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if self.shouldStartScanning {
                self.startScanning()
            }
        } else {
            self.connectingPeripheral = nil
            if let connectedPeripheral = self.connectedPeripheral {
                central.cancelPeripheralConnection(connectedPeripheral)
            }
            self.shouldStartScanning = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.connectingPeripheral = peripheral
        central.connect(peripheral, options: nil)
        self.stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        self.connectingPeripheral = nil
        
        peripheral.discoverServices([BLEConstants.TemperatureService])
        peripheral.delegate = self
        
        self.informDelegatesDidConnect(manager: self)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.connectingPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripheral = nil
        self.startScanning()
        self.informDelegatesDidDisconnect(manager: self)
    }
}
