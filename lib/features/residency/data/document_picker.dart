// Lets the resident browse and pick a residency document (PDF, image, …) from
// their device/computer. Web uses a native `<input type="file">` (any file
// type, 100% reliable on web); native uses image_picker. `pickDocument()`
// returns a `({Uint8List bytes, String name})?` (null if dismissed). The right
// implementation is chosen at compile time.
export 'document_picker_io.dart'
    if (dart.library.html) 'document_picker_web.dart';
