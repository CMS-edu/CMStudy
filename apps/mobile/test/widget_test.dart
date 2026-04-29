import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cmstudy_mobile/src/app.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CmStudyApp());
    await tester.pumpAndSettle();

    expect(find.text('CMStudy'), findsOneWidget);
    expect(find.text('로그인'), findsWidgets);
  });
}
