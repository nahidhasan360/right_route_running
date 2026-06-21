import 'dart:io';

void main() {
  final dir = Directory('lib/views');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  int filesUpdated = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    String original = content;

    // Replace EdgeInsets.symmetric(horizontal: 20.w) -> 15.w
    content = content.replaceAll(
      'EdgeInsets.symmetric(horizontal: 20.w)',
      'EdgeInsets.symmetric(horizontal: 15.w)'
    );

    // Replace EdgeInsets.symmetric(horizontal: 18.w) -> 15.w
    content = content.replaceAll(
      'EdgeInsets.symmetric(horizontal: 18.w)',
      'EdgeInsets.symmetric(horizontal: 15.w)'
    );

    // Replace EdgeInsets.all(20.w) -> EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w)
    content = content.replaceAll(
      'EdgeInsets.all(20.w)',
      'EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w)'
    );

    // Specific case from history_screen
    content = content.replaceAll(
      'EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w, bottom: 20.w)',
      'EdgeInsets.only(top: 20.h, left: 15.w, right: 15.w, bottom: 20.w)'
    );

    if (content != original) {
      file.writeAsStringSync(content);
      filesUpdated++;
      print('Updated: ${file.path}');
    }
  }

  print('Total files updated: $filesUpdated');
}
