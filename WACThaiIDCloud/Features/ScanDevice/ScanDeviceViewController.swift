//
//  ScanDeviceViewController.swift
//  WACThaiIDCloud
//
//  Created by Thananchai Pinyo on 27/7/2565 BE.
//

import UIKit
import Foundation
import SmartCardIO
import ACSSmartCardIO

enum TypeReader {
    case acr
    case mbr20
}

class ScanDeviceViewController: UIViewController, MPayBleLibDelegate {
    
    @IBOutlet weak var stateScanBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityScan: UIActivityIndicatorView!
    
    var typeReader: TypeReader? = .acr
    
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    var smPayBleLib = MPayBleLib()
    var selectedItem: CBPeripheral?
    
    /// The Bluetooth terminal manager
    let manager = BluetoothSmartCard.shared.manager
    var terminals = [CardTerminal]()
    var terminal: CardTerminal?
    var firstRun = true
    
    deinit {
        print("deinit ScanDeviceViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.smPayBleLib.delegate = self
        self.manager.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.activityScan.isHidden = true
        self.tableView.tableFooterView = UIView()
//        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        self.selectReaderType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
//        peripherals = []
        terminals = []
        self.tableView.reloadData()
    }
    
    func selectReaderType() {
        
        let typeAction0 = UIAlertAction(
            title: "Reader MBR-20",
            style: .default) { (action) in
                self.typeReader = .mbr20
                self.activityScan.isHidden = false
                self.activityScan.startAnimating()
//                self.peripherals = []
//                self.smPayBleLib = MPayBleLib()
                self.smPayBleLib.mPayBle_StopSearching()
                self.smPayBleLib.mPayBle_DisconnectDevice()
                self.smPayBleLib.mPayBle_SearchDevice()
                self.stateScanBtn.setTitle("Scanning", for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.smPayBleLib.mPayBle_StopSearching()
                    self.activityScan.stopAnimating()
                    self.activityScan.isHidden = true
                    self.stateScanBtn.setTitle("Scan", for: .normal)
                    print("Scanning stop")
                }
        }
        
        let typeAction1 = UIAlertAction(
            title: "Reader ACR",
            style: .default) { (action) in
                self.typeReader = .acr
                self.activityScan.isHidden = false
                self.activityScan.startAnimating()
                self.manager.startScan(terminalType: .acr3901us1)
                self.stateScanBtn.setTitle("Scanning", for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.manager.stopScan()
                    self.activityScan.stopAnimating()
                    self.activityScan.isHidden = true
                    self.stateScanBtn.setTitle("Scan", for: .normal)
                    print("Scanning stop")
                }
        }
        
        let typeAction2 = UIAlertAction(
            title: "Cancal",
            style: .cancel) { (action) in
   
        }
        
        let alert = UIAlertController(title: "Select a reader",
                                      message: "",
                                      preferredStyle: .actionSheet)

        alert.addAction(typeAction0)
        alert.addAction(typeAction1)
        alert.addAction(typeAction2)

        self.present(alert, animated: true)
    }
    
    func selectOptionType() {
        let typeAction0 = UIAlertAction(
            title: "About Us",
            style: .default) { (action) in
                self.showAlertAboutUs()
        }
        
        let typeAction1 = UIAlertAction(
            title: "Log Out",
            style: .default) { (action) in
                let story = UIStoryboard(name: "Main", bundle:nil)
                let vc = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
        }
        
        let typeAction2 = UIAlertAction(
            title: "Cancal",
            style: .cancel) { (action) in
   
        }
        
        let alert = UIAlertController(title: "Select Option",
                                      message: "",
                                      preferredStyle: .actionSheet)

        alert.addAction(typeAction0)
        alert.addAction(typeAction1)
        alert.addAction(typeAction2)

        self.present(alert, animated: true)
    }
    
    func onMPayBleResponse_Error(_ iErrorCode: Int32, message sMessage: String!) {
        print("error sMessage: ", sMessage as Any)
    }
    
    func onMPayBleResponse_UpdateState(_ iStateCode: Int32, message sMessage: String!) {
        print("UpdateState sMessage: ", sMessage as Any)
    }
    
    func onMPayBleResponse_GetDevice(_ bSucceed: Bool, peripheral: CBPeripheral!) {
        if bSucceed {
            print("Discovered \(peripheral.name ?? "")")
            if peripheral.name != nil {
                if !self.peripherals.contains(where: { $0.name == peripheral.name }) {
                    self.peripherals.append(peripheral)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func onMPayBleResponse_IsConnected(_ bSucceed: Bool) {
        print("IsConnected: ", bSucceed)
        if bSucceed {
//            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
//            vc?.peripheral = selectedItem!
//            vc?.smPayBleLib = self.smPayBleLib
//            vc?.typeReader = self.typeReader
//            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func actionStateScanBtn(_ sender: Any) {
        print("scan Start")
        selectReaderType()
    }
    
    @IBAction func actionOptionBtn(_ sender: Any) {
        selectOptionType()
    }
    
}

extension ScanDeviceViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeReader {
        case .acr:
            return terminals.count
        case .mbr20:
            return peripherals.count
        default:
            return 0
        }
    }
   
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListScanCell", for: indexPath) as! ListScanCell
        switch typeReader {
        case .acr:
            let terminal = terminals[indexPath.row]
            cell.deviceNameLabel?.text = terminal.name
            return cell
        case .mbr20:
            let peripheral = peripherals[indexPath.row]
            cell.deviceNameLabel?.text = peripheral.name
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch typeReader {
        case .acr:
            let terminal = terminals[indexPath.row]
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
            vc?.terminal = terminal
            vc?.manager = manager
            vc?.typeReader = self.typeReader
            self.navigationController?.pushViewController(vc!, animated: true)
        case .mbr20:
            let peripheral = peripherals[indexPath.row]
            print("Details : ", peripheral.name as Any)
            self.selectedItem = peripheral
            self.smPayBleLib.mPayBle_DisconnectDevice()
            if self.smPayBleLib.mPayBle_ConnectDevice(peripheral) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
                vc?.peripheral = selectedItem!
                vc?.smPayBleLib = self.smPayBleLib
                vc?.typeReader = self.typeReader
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            self.smPayBleLib.mPayBle_StopSearching()
        default:
            break
        }
        self.activityScan.stopAnimating()
        self.activityScan.isHidden = true
        self.stateScanBtn.setTitle("Scan", for: .normal)
    }
}

// MARK: - BluetoothTerminalManagerDelegate
extension ScanDeviceViewController: BluetoothTerminalManagerDelegate {

    func bluetoothTerminalManagerDidUpdateState(
        _ manager: BluetoothTerminalManager) {

        var message = ""

        switch manager.centralManager.state {

        case .unknown, .resetting:
            message = "The update is being started. Please wait until Bluetooth is ready."

        case .unsupported:
            message = "This device does not support Bluetooth low energy."

        case .unauthorized:
            message = "This app is not authorized to use Bluetooth low energy."

        case .poweredOff:
            if !firstRun {
                message = "You must turn on Bluetooth in Settings in order to use the reader."
            }

        default:
            break
        }

        if !message.isEmpty {

            // Show the alert.
            let alert = UIAlertController(title: "Bluetooth",
                                          message: message,
                                          preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(defaultAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }

        firstRun = false
    }

    func bluetoothTerminalManager(_ manager: BluetoothTerminalManager,
                                  didDiscover terminal: CardTerminal) {
        print("terminal: ", terminal.name)
        if !terminals.contains(
            where: { $0 === terminal }) {

            terminals.append(terminal)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            print("Setting the master key (" + terminal.name
                + ")...")
            do {
                try manager.setMasterKey(
                    terminal: terminal,
                    masterKey: Hex.toByteArray(hexString: "FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"))
            } catch {
                print("Error: "
                    + error.localizedDescription)
            }
        }
    }
}

extension ScanDeviceViewController: CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManager( _ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "")")
        if peripheral.name != nil {
            if !self.peripherals.contains(where: { $0.name == peripheral.name }) {
                self.peripherals.append(peripheral)
            }
        }
        self.tableView.reloadData()
    }
    
    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        switch central.state {
         case .unknown:
            print("central.state is .unknown")
         case .resetting:
            print("central.state is .resetting")
         case .unsupported:
            print("central.state is .unsupported")
         case .unauthorized:
            print("central.state is .unauthorized")
         case .poweredOff:
            print("central.state is .poweredOff")
         case .poweredOn:
            print("central.state is .poweredOn")
            self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        @unknown default:
          fatalError()
        }
    }
    
    func centralManager( central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to ", peripheral.name!)
    }

    func centralManager( _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
}
