import Foundation
import UIKit
import Photos

enum PhotoStorage {
    static let maxLongEdge: CGFloat = 1600
    static let jpegQuality: CGFloat = 0.8

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Resizes the image to a max long edge, JPEG-compresses it, and saves it into the
    /// app's Documents directory. Returns the stored file name (not a full path), which is
    /// what gets persisted on `ContentItem.photoFileName` and referenced from markdown.
    @discardableResult
    static func saveCompressed(_ image: UIImage) throws -> String {
        let resized = resized(image, maxLongEdge: maxLongEdge)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else {
            throw PhotoStorageError.encodingFailed
        }
        let fileName = "\(UUID().uuidString).jpg"
        let url = documentsDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func loadImage(fileName: String) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }

    static func deleteImage(fileName: String) {
        let url = documentsDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    /// Saves the untouched original into the user's Photos library so that iCloud Photos
    /// (if enabled) backs it up. FlowConte does not manage this copy or its sync.
    static func saveOriginalToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }

    private static func resized(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let longEdge = max(image.size.width, image.size.height)
        guard longEdge > maxLongEdge else { return image }
        let scale = maxLongEdge / longEdge
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum PhotoStorageError: Error {
    case encodingFailed
}
