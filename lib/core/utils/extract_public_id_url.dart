String extractPublicIdFromUrl(String url) {
  try {
    // Ejemplo de URL: https://res.cloudinary.com/cloud_name/image/upload/v1234567890/empleados/filename.jpg
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    // Buscar el índice de 'upload' y obtener los segmentos después de la versión
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
      // Omitir 'upload' y la versión (v1234567890), tomar el resto
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicIdWithExtension = publicIdParts.join('/');

      // Remover la extensión del archivo
      final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
      if (lastDotIndex != -1) {
        return publicIdWithExtension.substring(0, lastDotIndex);
      }
      return publicIdWithExtension;
    }
    return '';
  } catch (e) {
    return '';
  }
}
