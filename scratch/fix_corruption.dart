import 'dart:io';

void main() async {
  final dir = Directory('lib/views/account');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Fix patterns like 2.w0.w -> 20.w
    // Example: \.w([0-9]+)\.w -> the first digit was separated
    final wRegex = RegExp(r'\.w([0-9]+(?:\.[0-9]+)?)\.w');
    if (wRegex.hasMatch(content)) {
      content = content.replaceAllMapped(wRegex, (m) => '${m.group(1)}.w');
      modified = true;
    }

    final hRegex = RegExp(r'\.h([0-9]+(?:\.[0-9]+)?)\.h');
    if (hRegex.hasMatch(content)) {
      content = content.replaceAllMapped(hRegex, (m) => '${m.group(1)}.h');
      modified = true;
    }

    final spRegex = RegExp(r'\.sp([0-9]+(?:\.[0-9]+)?)\.sp');
    if (spRegex.hasMatch(content)) {
      content = content.replaceAllMapped(spRegex, (m) => '${m.group(1)}.sp');
      modified = true;
    }

    final rRegex = RegExp(r'\.r([0-9]+(?:\.[0-9]+)?)\.r');
    if (rRegex.hasMatch(content)) {
      content = content.replaceAllMapped(rRegex, (m) => '${m.group(1)}.r');
      modified = true;
    }
    
    // Also fix height: 1.h -> height: 1 (if it was a TextStyle line height that got wrongly caught)
    // Actually, line height was <= 3.0 so it was skipped. But wait, `height: 1.h` is seen in diff!
    // diff showed: height: 1.h in TextStyle. That means height: 1 wasn't skipped?
    // In my script I did `value <= 3.0` skip, but wait, if it was `height: 1`, my script parses `1.0` <= `3.0` and skips it.
    // Why did `height: 1.h` appear? Because `height: 1` -> oh wait! If it was already `height: 1.h` maybe? No, diff says `- height: 1,` `+ height: 1.h,`!
    // If value == 1.0, it should have been skipped! Wait, did my script not skip it?
    // Let me just fix it manually if there are only a few.

    if (modified) {
      await file.writeAsString(content);
      print('Fixed \${file.path}');
    }
  }
}
