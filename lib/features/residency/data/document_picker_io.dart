import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Native: pick an image document from the gallery.
Future<({Uint8List bytes, String name})?> pickDocument() async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return (bytes: bytes, name: file.name);
}
