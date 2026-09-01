// Fallback file saver for non-web environments.

void saveFileBytes(List<int> bytes, String filename, String mimeType) {
  // No-op for non-web platforms without IO access
}
