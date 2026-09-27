import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class PickedBytes {
  const PickedBytes({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Reads one PDF or text file into memory. Empty means the user cancelled.
Future<List<PickedBytes>> pickDocument() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'txt', 'md'],
  );
  if (file == null) return const [];
  return [PickedBytes(name: file.name, bytes: await file.readAsBytes())];
}
