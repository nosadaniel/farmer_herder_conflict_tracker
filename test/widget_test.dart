import 'package:farmer_herder_conflict_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and shows the static shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ConflictTrackerApp()),
    );
    await tester.pump();

    expect(find.text('Conflict Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byIcon(Icons.keyboard), findsOneWidget);
  });
}
