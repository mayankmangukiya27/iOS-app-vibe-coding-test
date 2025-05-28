import UIKit

extension UIImage {
    func compressed(maxSizeInMB: Double = 1.0) -> UIImage? {
        let maxSizeInBytes = Int(maxSizeInMB * 1024 * 1024)
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)
        
        while (imageData?.count ?? 0) > maxSizeInBytes && compression > 0.01 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        guard let finalImageData = imageData else { return nil }
        return UIImage(data: finalImageData)
    }
} 