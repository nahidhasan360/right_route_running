import 'dart:io';

Future<void> replaceInFile(String path, String from, String to) async {
  final file = File(path);
  if (!await file.exists()) return;
  String content = await file.readAsString();
  if (content.contains(from)) {
    content = content.replaceFirst(from, to);
    await file.writeAsString(content);
    print('Updated $path');
  } else {
    print('Pattern not found in $path');
  }
}

void main() async {
  // 1. get_started_screen.dart
  await replaceInFile(
    'lib/views/authentication/get_started_screen/get_started_screen.dart',
    'SizedBox(height: 80.h),',
    'SizedBox(height: 20.h),',
  );

  // 2. enter_email_screen.dart
  await replaceInFile(
    'lib/views/authentication/enter_email_screen/enter_email_screen.dart',
    'SizedBox(height: 15.h),',
    'SizedBox(height: 20.h),',
  );

  // 3. login_account.dart
  await replaceInFile(
    'lib/views/authentication/login_account/login_account.dart',
    'SizedBox(height: 21.h),',
    'SizedBox(height: 20.h),',
  );

  // 4. account_screen.dart
  await replaceInFile(
    'lib/views/home/account_screen/account_screen.dart',
    '''        child: Column(
          children: [
            SizedBox(height: 50.h),''',
    '''        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),''',
  );
  // and close SafeArea
  await replaceInFile(
    'lib/views/home/account_screen/account_screen.dart',
    '''          ],
        ),
      ),
      bottomNavigationBar: CustomNavbar(),''',
    '''          ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(),''',
  );

  // 5. contact_support.dart
  await replaceInFile(
    'lib/views/account/contact_support.dart',
    '''        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),''',
    '''        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),''',
  );
  await replaceInFile(
    'lib/views/account/contact_support.dart',
    '''              children: [
                SizedBox(height: 40.h),''',
    '''              children: [
                SizedBox(height: 20.h),''',
  );
  // close SafeArea
  await replaceInFile(
    'lib/views/account/contact_support.dart',
    '''        ),
      ),
      bottomNavigationBar: CustomNavbar(),''',
    '''          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(),''',
  );

  // 6. history_screen.dart
  await replaceInFile(
    'lib/views/home/history_screen/history_screen.dart',
    'padding: EdgeInsets.all(20.w),',
    'padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w, bottom: 20.w),',
  );

  // 7. team_manager.dart
  await replaceInFile(
    'lib/views/home/team_manager/team_manager.dart',
    '''                // ✅ toolbarHeight — physical pixel, no ScreenUtil needed here
                toolbarHeight: 144,''',
    '''                // Updated to match 20.h top margin across all screens ((152 - 112) / 2 = 20)
                toolbarHeight: 152.h,''',
  );

  print('Finished standardizing logo heights.');
}
