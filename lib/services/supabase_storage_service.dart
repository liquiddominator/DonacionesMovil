import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucket = 'transparencia-bucket';

  /// Sube un archivo al bucket con una ruta específica (por ejemplo: usuarios/usuario1.jpg)
  Future<String?> uploadFile({
    required File file,
    required String storagePath, // ruta dentro del bucket (ej. usuarios/123.jpg)
  }) async {
    final bucketRef = _client.storage.from(_bucket);

    try {
      final result = await bucketRef.upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      if (result.isNotEmpty) {
        return bucketRef.getPublicUrl(storagePath);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error al subir archivo a Supabase: $e');
      return null;
    }
  }

  /// Elimina un archivo dado su ruta en el bucket
  Future<bool> deleteFile(String storagePath) async {
    final bucketRef = _client.storage.from(_bucket);

    try {
      await bucketRef.remove([storagePath]);
      return true;
    } catch (e) {
      print('❌ Error al eliminar archivo de Supabase: $e');
      return false;
    }
  }

  /// Obtiene la URL pública de un archivo ya existente
  String getPublicUrl(String storagePath) {
    return _client.storage.from(_bucket).getPublicUrl(storagePath);
  }
}