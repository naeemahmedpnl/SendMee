

import 'package:sendme/utils/constant/api_base_url.dart';

class ImageUrlUtils {
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Convert backslashes to forward slashes
    final normalizedPath = imagePath.replaceAll('\\', '/');
    
    // Remove any leading slash to prevent double slashes
    final cleanPath = normalizedPath.startsWith('/') 
        ? normalizedPath.substring(1) 
        : normalizedPath;
    
    // Combine with base URL
    return '${Constants.apiBaseUrl}/${cleanPath}';
  }
}