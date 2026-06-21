import 'dart:io';

void main() async {
  final file = File('lib/core/routes/all_routes.dart');
  String content = await file.readAsString();

  // A safe regex replacement for GetPage(
  content = content.replaceAll(
    'GetPage(',
    'GetPage(\n      transition: Transition.fadeIn,\n      transitionDuration: const Duration(milliseconds: 300),',
  );

  await file.writeAsString(content);
  print('Transitions added successfully.');
}
