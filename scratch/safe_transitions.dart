import 'dart:io';

void main() async {
  final file = File('lib/core/routes/all_routes.dart');
  String content = await file.readAsString();

  final regex = RegExp(r'^(\s*)GetPage\(', multiLine: true);
  
  content = content.replaceAllMapped(regex, (match) {
    final indent = match.group(1)!;
    return '${indent}GetPage(\n$indent  transition: Transition.fadeIn,\n$indent  transitionDuration: const Duration(milliseconds: 300),';
  });

  await file.writeAsString(content);
  print('Transitions added successfully.');
}
