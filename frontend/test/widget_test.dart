import 'package:flutter_test/flutter_test.dart';
import 'package:canis_odd_music/app.dart';

void main() {
  testWidgets('Music app renders its home screen', (tester) async {
    await tester.pumpWidget(const CanisOddMusicApp());

    expect(find.text('Latest releases'), findsOneWidget);
    expect(find.text('Sound from Teso.\nMade to be heard.'), findsOneWidget);
  });
}
