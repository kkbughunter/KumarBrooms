import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumarbrooms/shared/widgets/auth_layout.dart';

void main() {
  testWidgets('authentication layout renders its content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthLayout(
          title: 'Welcome back',
          subtitle: 'Sign in to continue.',
          child: TextField(),
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to continue.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
