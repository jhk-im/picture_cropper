import 'package:example/widgets/custom_slider.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final double renderBoxWidth;
  final double renderBoxHeight;
  final double currentScaleValue;
  final double currentRotateValue;
  final Offset currentOffset;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotateChanged;
  final ValueChanged<Offset> onOffsetChanged;

  const CustomBottomSheet({
    super.key,
    required this.renderBoxWidth,
    required this.renderBoxHeight,
    required this.currentScaleValue,
    required this.currentRotateValue,
    required this.currentOffset,
    required this.onScaleChanged,
    required this.onRotateChanged,
    required this.onOffsetChanged,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  late double _scaleValue;
  late double _rotateValue;
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _scaleValue = widget.currentScaleValue;
    _rotateValue = widget.currentRotateValue;
    _offset = widget.currentOffset;
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                const SizedBox(width: 80, child: Text('Scale')),
                Expanded(
                  child: CustomSlider(
                    value: _scaleValue,
                    min: 0.3,
                    max: 1.7,
                    onChanged: (value) {
                      setState(() {
                        _scaleValue = value;
                      });
                      widget.onScaleChanged(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 80, child: Text('Rotate')),
                Expanded(
                  child: CustomSlider(
                    value: _rotateValue,
                    min: -3.15,
                    max: 3.15,
                    onChanged: (value) {
                      setState(() {
                        _rotateValue = value;
                      });
                      widget.onRotateChanged(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 80, child: Text('OffsetX')),
                Expanded(
                  child: CustomSlider(
                    value: _offset.dx,
                    min: -widget.renderBoxWidth,
                    max: widget.renderBoxWidth,
                    onChanged: (value) {
                      setState(() {
                        _offset = Offset(value, _offset.dy);
                      });
                      widget.onOffsetChanged(_offset);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 80, child: Text('OffsetY')),
                Expanded(
                  child: CustomSlider(
                    value: _offset.dy,
                    min: -widget.renderBoxHeight,
                    max: widget.renderBoxHeight,
                    onChanged: (value) {
                      setState(() {
                        _offset = Offset(_offset.dx, value);
                      });
                      widget.onOffsetChanged(_offset);
                    },
                  ),
                ),
              ],
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}
