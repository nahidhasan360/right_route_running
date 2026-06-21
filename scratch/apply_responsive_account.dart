import 'dart:io';

void main() async {
  final dir = Directory('lib/views/account');
  if (!dir.existsSync()) {
    print('Directory not found');
    return;
  }

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // 1. Convert height: X to height: X.h
    // Avoid double .h like height: X.h.h and avoid decimals like height: 1.5
    final heightRegex = RegExp(r'(height:\s*)([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)(?!.*\)?)');
    content = content.replaceAllMapped(heightRegex, (match) {
      final valueStr = match.group(2)!;
      final value = double.tryParse(valueStr);
      // If it's small (<= 3), it's likely a line height inside TextStyle. Skip it!
      if (value != null && value <= 3.0) {
        return match.group(0)!; // Keep original
      }
      modified = true;
      return '${match.group(1)}$valueStr.h';
    });

    // 2. Convert width: X to width: X.w
    final widthRegex = RegExp(r'(width:\s*)([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)');
    content = content.replaceAllMapped(widthRegex, (match) {
      modified = true;
      return '${match.group(1)}${match.group(2)}.w';
    });

    // 3. Convert fontSize: X to fontSize: X.sp
    final fontSizeRegex = RegExp(r'(fontSize:\s*)([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)');
    content = content.replaceAllMapped(fontSizeRegex, (match) {
      modified = true;
      return '${match.group(1)}${match.group(2)}.sp';
    });

    // 4. Convert radius/EdgeInsets/SizedBox that are hardcoded.
    // e.g. EdgeInsets.all(X) -> EdgeInsets.all(X.w)
    final edgeInsetsAllRegex = RegExp(r'(EdgeInsets\.all\()([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)');
    content = content.replaceAllMapped(edgeInsetsAllRegex, (match) {
      modified = true;
      return '${match.group(1)}${match.group(2)}.w';
    });

    final edgeInsetsSymRegex = RegExp(r'(horizontal:\s*|vertical:\s*|left:\s*|right:\s*|top:\s*|bottom:\s*)([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)');
    content = content.replaceAllMapped(edgeInsetsSymRegex, (match) {
      modified = true;
      final prefix = match.group(1)!;
      final val = match.group(2)!;
      if (prefix.contains('vertical') || prefix.contains('top') || prefix.contains('bottom')) {
        return '$prefix$val.h';
      } else {
        return '$prefix$val.w';
      }
    });

    // radius: BorderRadius.circular(X) -> BorderRadius.circular(X.r)
    final radiusRegex = RegExp(r'(BorderRadius\.circular\()([0-9]+(?:\.[0-9]+)?)(?!\.h|\.w|\.sp|\.r)');
    content = content.replaceAllMapped(radiusRegex, (match) {
      modified = true;
      return '${match.group(1)}${match.group(2)}.r';
    });
    
    // Add import if missing and modified
    if (modified && !content.contains('flutter_screenutil.dart')) {
      content = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n$content";
    }

    if (modified) {
      await file.writeAsString(content);
      print('Updated ${file.path}');
    }
  }
  print('Done applying ScreenUtil');
}
