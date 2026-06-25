// dart:html is intentional — this file is only compiled for web via the
// conditional import in document_picker.dart, and a native <input type="file">
// is the most reliable way to browse documents on the web.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

/// Web: open the OS file browser via a hidden <input type="file"> and return
/// the selected file's bytes + name. Accepts PDFs and images.
Future<({Uint8List bytes, String name})?> pickDocument() async {
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,.jpg,.jpeg,.png,.webp,.heic,image/*'
    ..multiple = false
    // Hidden but present in the DOM — a detached or visible input can fail to
    // open the picker on some browsers (notably iOS Safari).
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.opacity = '0';
  html.document.body?.append(input);
  // click() must run synchronously inside the tap so the browser keeps the
  // user-gesture context (otherwise the dialog is blocked).
  input.click();

  // Wait for a file to be chosen. (If the user dismisses the dialog, no change
  // event fires; the next tap simply opens a fresh picker.)
  await input.onChange.first;
  input.remove();

  final files = input.files;
  if (files == null || files.isEmpty) return null;
  final file = files.first;

  final reader = html.FileReader()..readAsArrayBuffer(file);
  await reader.onLoadEnd.first;
  final result = reader.result;
  if (result is! Uint8List) return null;
  return (bytes: result, name: file.name);
}
