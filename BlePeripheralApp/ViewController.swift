//
//  ViewController.swift
//  BlePeripheralApp
//
//  Created by Christian Lorenzo on 2/9/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    private var peripheralManager: CBPeripheralManager!
    private var service: CBUUID!
    private let value = "AD34E"
    
    @IBOutlet weak var readValueLabel: UILabel!
    @IBOutlet weak var writeValueLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        startAdvertising()
    }
    
    ///Delegates for BLE states: BLE On/Off, or any other states
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
        @unknown default:
            print("Unknown State")
        }
    }
    
    ///If the Bluetooth is ON, we need to add services and characteristics to the peripheral application which it exposes to the client device while advertising:
    func addServices() {
        let valueData = value.data(using: .utf8)
        
        //1.- Create instance of CBmutableCharacteristic
        let myChar1 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.notify, .write, .read], value: nil, permissions: [.readable, .writeable])
        
        let myChar2 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.read], value: valueData, permissions: [.readable])
        
        //2.- Create instance of CBMutableService
        service = CBUUID(nsuuid: UUID())
        let myService = CBMutableService(type: service, primary: true)
        
        //3.- Add characteristics to the service
        myService.characteristics = [myChar1, myChar2]
        
        //4.- Add service to the peripheralManager
        peripheralManager.add(myService)
        
        //5.- Start advertising
        startAdvertising()
        print("This is my UUID: \(String(describing: service))")
    }
    
    func startAdvertising() {
        messageLabel.text = "Advertising Data"
        
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "BlePeripheralApp", CBAdvertisementDataServiceUUIDsKey: [service]])
        print("Started Advertising")
    }
    
    ///PeripheralManager has delegate methods to respond to read, write and notify. Whenever a value is written to device the didReceiveWrite() method get called.
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        messageLabel.text = "Writing Data"
        if let value = requests.first?.value {
            writeValueLabel.text = value.hexEncodedString()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        messageLabel.text = "Data getting Read"
        readValueLabel.text = value
    }


}

/// Extensions: extension of data to convert the received value of type Data to HexString type.

extension Data {
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhX"
        return map { String(format: format, $0) }.joined()
    }
    
}

