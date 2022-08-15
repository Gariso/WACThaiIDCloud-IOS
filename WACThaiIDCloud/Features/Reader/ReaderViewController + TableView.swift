import Foundation
import UIKit

extension ReaderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.itemDataState {
        case 0:
            return 6
        case 1:
            return 5
        case 2:
            return 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemDataCell") as? ItemDataCell else { return UITableViewCell()}
        switch self.itemDataState {
        case 0:
            switch indexPath.row {
            case 0:
                cell.configureCell(title: "เลขประจำตัวประชาชน", value: self.nativeCardInfo?.cardNumber ?? "")
            case 1:
                let fullName = "\(self.nativeCardInfo?.thaiTitle ?? "") \(self.nativeCardInfo?.thaiFirstName ?? "") \(self.nativeCardInfo?.thaiLastName ?? "")"
                cell.configureCell(title: "ชื่อ-สกุล", value: fullName)
            case 2:
                let fullName = "\(self.nativeCardInfo?.engTitle ?? "") \(self.nativeCardInfo?.engFirstName ?? "") \(self.nativeCardInfo?.engLastName ?? "")"
                cell.configureCell(title: "Fisrtname-Lastname", value: fullName)
            case 3:
                cell.configureCell(title: "วันเกิด", value: self.nativeCardInfo?.dateOfBirth ?? "")
            case 4:
                cell.configureCell(title: "เพศ", value: self.nativeCardInfo?.sex ?? "")
            case 5:
                let address = self.nativeCardInfo?.address
                let fullAddress = "\(address?.homeNo ?? "") \(address?.soi ?? "") \(address?.trok ?? "") \(address?.moo ?? "") \(address?.road ?? "") \(address?.subDistrict ?? "") \(address?.district ?? "") \(address?.province ?? "") \(address?.postalCode ?? "")"
                cell.configureCell(title: "ที่อยู่", value: fullAddress)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.configureCell(title: "หมายเลข บัตร/คำร้อง", value: self.nativeCardInfo?.bp1No ?? "")
            case 1:
                cell.configureCell(title: "สถานที่ออกบัตร", value: self.nativeCardInfo?.cardIssuePlace ?? "")
            case 2:
                cell.configureCell(title: "รหัสผู้ออกบัตร", value: self.nativeCardInfo?.cardIssueNo ?? "")
            case 3:
                cell.configureCell(title: "วัน เดือน ปี ที่ออกบัตร", value: self.nativeCardInfo?.cardIssueDate ?? "")
            case 4:
                cell.configureCell(title: "วัน เดือน ปี ที่บัตรหมดอายุ", value: self.nativeCardInfo?.cardExpiryDate ?? "")
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.configureCell(title: "รหัสประเภทบัตร", value: self.nativeCardInfo?.cardType ?? "")
            case 1:
                cell.configureCell(title: "Version", value: self.nativeCardInfo?.versionCard ?? "")
            case 2:
                cell.configureCell(title: "Laser ID", value: self.nativeCardInfo?.laserId ?? "")
            case 3:
                cell.configureCell(title: "Chip card ID", value: self.nativeCardInfo?.chipId ?? "")
            case 4:
                cell.configureCell(title: "เลขรหัสกำกับใต้รูป", value: self.nativeCardInfo?.cardPhotoIssueNo ?? "")
            default:
                break
            }
        default:
            break
        }
        return cell
    }
}
