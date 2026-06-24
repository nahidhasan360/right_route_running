import 'dart:io';
import 'package:flutter/widgets.dart';

void main() async {
  final file = File('assets/icons/Map-Pin-orange.png');
  final bytes = await file.readAsBytes();
  final image = await decodeImageFromList(bytes);
  print('Width: \${image.width}, Height: \${image.height}');
}
