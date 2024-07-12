import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picture_cropper/src/widgets/crop/crop_control_point.dart';

void main() {
  testWidgets('CropControlPoint renders default point shape',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropControlPoint(),
        ),
      ),
    );

    expect(find.byType(CropControlPoint), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    final centerWidget = tester.widget<Center>(find.descendant(
        of: find.byType(CropControlPoint), matching: find.byType(Center)));
    final innerContainer = centerWidget.child as Container;
    expect(innerContainer.color, Colors.white);
  });

  testWidgets('CropControlPoint renders top-left point shape',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropControlPoint(
            pointShape: 1,
            color: Colors.red,
          ),
        ),
      ),
    );

    expect(find.byType(CropControlPoint), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    final containerWidget =
        tester.widget<Container>(find.byType(Container).last);
    expect(containerWidget.child, isNot(isA<Center>()));
  });

  testWidgets('CropControlPoint renders top-right point shape',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropControlPoint(
            pointShape: 2,
            color: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.byType(CropControlPoint), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    final containerWidget =
        tester.widget<Container>(find.byType(Container).last);
    expect(containerWidget.child, isNot(isA<Center>()));
  });

  testWidgets('CropControlPoint renders bottom-right point shape',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropControlPoint(
            pointShape: 3,
            color: Colors.green,
          ),
        ),
      ),
    );

    expect(find.byType(CropControlPoint), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    final containerWidget =
        tester.widget<Container>(find.byType(Container).last);
    expect(containerWidget.child, isNot(isA<Center>()));
  });

  testWidgets('CropControlPoint renders bottom-left point shape',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CropControlPoint(
            pointShape: 4,
            color: Colors.yellow,
          ),
        ),
      ),
    );

    expect(find.byType(CropControlPoint), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    final containerWidget =
        tester.widget<Container>(find.byType(Container).last);
    expect(containerWidget.child, isNot(isA<Center>()));
  });
}
