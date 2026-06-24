import 'dart:io';

void main() {
  final files = [
    'lib/views/home/create_new_routes/confirm_your_routes/confirm_controller.dart',
    'lib/views/home/create_new_routes/home_screen_map.dart',
    'lib/views/home/create_new_routes/confirm_your_routes/create_route_after_confirm_route/after_confirm_map.dart',
    'lib/views/home/create_new_routes/drive_screen/drive_controller.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();

    // Remove textField: ' ' and add zIndex
    content = content.replaceAll(
      "textField: ' ',\n            draggable: true,",
      "zIndex: 100,\n            draggable: true,"
    );
    content = content.replaceAll(
      "textField: ' ',\n          draggable: true,",
      "zIndex: 100,\n          draggable: true,"
    );
    content = content.replaceAll(
      "textField: ' ',\n            draggable: false,",
      "zIndex: 100,\n            draggable: false,"
    );

    // Also add zIndex: 1 to pin-orange just in case (only in confirm_controller.dart for waypoints)
    content = content.replaceAll(
      "textAnchor: 'center',\n            draggable: true,",
      "textAnchor: 'center',\n            zIndex: 1,\n            draggable: true,"
    );
    // and for drive_controller wp-pin
    content = content.replaceAll(
      "textHaloBlur: 0.5,\n              draggable: false,",
      "textHaloBlur: 0.5,\n              zIndex: 1,\n              draggable: false,"
    );

    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
