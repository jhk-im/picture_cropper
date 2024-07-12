import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picture_cropper/src/common/enums.dart';
import 'package:picture_cropper/src/widgets/crop/camera_crop_guideline.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';

void main() {
  testWidgets('CameraCropGuideline renders correctly',
      (WidgetTester tester) async {
    final cropAreaItem = CropAreaItem(
      leftTopX: 10.0,
      leftTopY: 10.0,
      rightTopX: 100.0,
      rightTopY: 10.0,
      rightBottomX: 100.0,
      rightBottomY: 100.0,
      leftBottomX: 10.0,
      leftBottomY: 100.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CameraCropGuideline(
            cropGuideLineType: CropGuideLineType.qr,
            cropAreaItem: cropAreaItem,
            radius: 10.0,
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );

    expect(find.byType(CameraCropGuideline), findsOneWidget);

    expect(find.byType(ClipPath), findsOneWidget);

    final clipPathWidget = tester.widget<ClipPath>(find.byType(ClipPath));
    expect(clipPathWidget.clipper, isA<CropAreaClipper>());

    final cropAreaClipper = clipPathWidget.clipper as CropAreaClipper;
    expect(cropAreaClipper.item, cropAreaItem);
    expect(cropAreaClipper.radius, 10.0);

    final containerWidget = tester.widget<Container>(find.descendant(
        of: find.byType(ClipPath), matching: find.byType(Container)));
    expect(containerWidget.color, Colors.black.withOpacity(0.5));
  });

  testWidgets('CameraCropGuideline hides guideline when type is clear',
      (WidgetTester tester) async {
    final cropAreaItem = CropAreaItem(
      leftTopX: 10.0,
      leftTopY: 10.0,
      rightTopX: 100.0,
      rightTopY: 10.0,
      rightBottomX: 100.0,
      rightBottomY: 100.0,
      leftBottomX: 10.0,
      leftBottomY: 100.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CameraCropGuideline(
            cropGuideLineType: CropGuideLineType.clear,
            cropAreaItem: cropAreaItem,
            radius: 10.0,
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // 비동기 작업이 완료될 때까지 대기

    expect(find.byType(ClipPath), findsNothing);
  });
}
