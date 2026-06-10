import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utilities for image processing and optimization.
class ImageUtils {
  ImageUtils._();

  /// Maximum allowed image file size in bytes (500 KB).
  static const int maxImageFileSize = 500 * 1024;

  /// Maximum image dimension (width or height) in pixels.
  static const int maxImageDimension = 1024;

  /// JPEG quality for compressed images (0-100).
  static const int jpegQuality = 85;

  /// Check if image bytes exceed maximum allowed size.
  static bool isImageTooLarge(Uint8List bytes) {
    return bytes.length > maxImageFileSize;
  }

  /// Compress and resize image to ensure it fits in protocol limits.
  ///
  /// Returns compressed image bytes, or null if compression failed.
  /// Reduces image quality and dimensions to fit within protocol payload limits.
  static Uint8List? compressImage(Uint8List imageBytes) {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize if necessary
      var processed = image;
      if (image.width > maxImageDimension || image.height > maxImageDimension) {
        processed = img.copyResizeCropSquare(
          image,
          size: maxImageDimension,
        );
      }

      // Encode as JPEG with quality setting
      final compressed = img.encodeJpg(processed, quality: jpegQuality);

      // If still too large, try reducing quality further
      if (compressed.length > maxImageFileSize) {
        return img.encodeJpg(processed, quality: 75);
      }

      return Uint8List.fromList(compressed);
    } catch (e) {
      return null;
    }
  }

  /// Format bytes to human-readable size string.
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
