/// [CropAreaItem] includes the coordinate information, scale, and rotation data for cropping and guidelines.
/// It is used only within the package.
class CropAreaItem {
  CropAreaItem({
    this.leftTopX = 0,
    this.leftTopY = 0,
    this.rightTopX = 0,
    this.rightTopY = 0,
    this.rightBottomX = 0,
    this.rightBottomY = 0,
    this.leftBottomX = 0,
    this.leftBottomY = 0,
    //this.scale = 1.0,
    //this.rotate = 0,
  });
  final double leftTopX;
  final double leftTopY;
  final double rightTopX;
  final double rightTopY;
  final double rightBottomX;
  final double rightBottomY;
  final double leftBottomX;
  final double leftBottomY;

  // double scale;
  // double rotate;

  @override
  String toString() {
    return 'CropAreaItem: '
        'leftTopX: $leftTopX, '
        'leftTopY: $leftTopY, '
        'rightTopX: $rightTopX, '
        'rightTopY: $rightTopY, '
        'rightBottomX: $rightBottomX, '
        'rightBottomY: $rightBottomY, '
        'leftBottomX: $leftBottomX, '
        'leftBottomY: $leftBottomY, ';
    //'scale: $scale, '
    //'rotate: $rotate';
  }
}
