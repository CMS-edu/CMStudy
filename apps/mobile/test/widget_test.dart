import 'package:flutter_test/flutter_test.dart';

import 'package:cmstudy_mobile/src/app.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    await tester.pumpWidget(const CmStudyApp());

    expect(find.text('CMStudy'), findsOneWidget);
    expect(find.text('로그인'), findsWidgets);
  });
}
