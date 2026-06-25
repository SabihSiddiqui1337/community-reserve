// dart:html is intentional — this file is only compiled for web via the
// conditional import in document_picker.dart, and a native <input type="file">
// is the most reliable way to browse documents on the web.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

/// Web: open the OS file browser via a hidden <input type="file"> and return
/// the selected file's bytes + name. Accepts PDFs and images; images are
/// downscaled + re-encoded as JPEG so uploads are fast (phone photos are
/// several MB → a few hundred KB).
Future<({Uint8List bytes, String name})?> pickDocument() async {
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,.jpg,.jpeg,.png,.webp,.heic,image/*'
    ..multiple = false
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.opacity = '0';
  html.document.body?.append(input);
  // click() must run synchronously inside the tap so the browser keeps the
  // user-gesture context (otherwise the dialog is blocked).
  input.click();

  await input.onChange.first;
  input.remove();

  final files = input.files;
  if (files == null || files.isEmpty) return null;
  final file = files.first;

  final reader = html.FileReader()..readAsArrayBuffer(file);
  await reader.onLoadEnd.first;
  final result = reader.result;
  if (result is! Uint8List) return null;

  // Compress images to keep the upload quick. PDFs pass through untouched.
  if (file.type.startsWith('image/')) {
    final compressed = await _compressImage(result);
    if (compressed != null) {
      return (bytes: compressed, name: _withJpgExt(file.name));
    }
  }
  return (bytes: result, name: file.name);
}

/// Downscale to [maxDim] on the longest edge and re-encode as JPEG via a canvas.
/// Returns null on any failure so the caller falls back to the original bytes.
Future<Uint8List?> _compressImage(
  Uint8List bytes, {
  int maxDim = 1600,
  num quality = 0.82,
}) async {
  String? objectUrl;
  try {
    objectUrl = html.Url.createObjectUrlFromBlob(html.Blob([bytes]));
    final img = html.ImageElement(src: objectUrl);
    await img.onLoad.first;

    final w = img.naturalWidth;
    final h = img.naturalHeight;
    if (w == 0 || h == 0) return null;
    final longest = w > h ? w : h;
    final scale = longest > maxDim ? maxDim / longest : 1.0;
    final tw = (w * scale).round();
    final th = (h * scale).round();

    final canvas = html.CanvasElement(width: tw, height: th);
    canvas.context2D.drawImageScaled(img, 0, 0, tw, th);

    final blob = await canvas.toBlob('image/jpeg', quality);
    final r = html.FileReader()..readAsArrayBuffer(blob);
    await r.onLoadEnd.first;
    final out = r.result;
    return out is Uint8List ? out : null;
  } catch (_) {
    return null;
  } finally {
    if (objectUrl != null) html.Url.revokeObjectUrl(objectUrl);
  }
}

String _withJpgExt(String name) {
  final dot = name.lastIndexOf('.');
  final base = dot > 0 ? name.substring(0, dot) : name;
  return '$base.jpg';
}
