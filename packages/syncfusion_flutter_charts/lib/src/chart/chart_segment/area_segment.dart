import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/src/chart/common/common.dart';
import '../chart_series/series.dart';
import '../common/renderer.dart';
import '../common/segment_properties.dart';
import '../utils/helper.dart';
import 'chart_segment.dart';

/// Creates the segments for area series.
///
/// This generates the area series points and has the [calculateSegmentPoints] override method
/// used to customize the area series segment point calculation.
///
/// It gets the path, stroke color and fill color from the `series` to render the segment.
///
class AreaSegment extends ChartSegment {
  late SegmentProperties _segmentProperties;
  bool _isInitialize = false;

  /// Gets the color of the series.
  @override
  Paint getFillPaint() {
    _setSegmentProperties();
    fillPaint = Paint();
    if (_segmentProperties.series.gradient == null) {
      if (_segmentProperties.color != null) {
        fillPaint!.color = _segmentProperties.color!;
        fillPaint!.style = PaintingStyle.fill;
      }
    } else {
      fillPaint = (_segmentProperties.pathRect != null)
          ? getLinearGradientPaint(
              _segmentProperties.series.gradient!,
              _segmentProperties.pathRect!,
              SeriesHelper.getSeriesRendererDetails(
                      _segmentProperties.seriesRenderer)
                  .stateProperties
                  .requireInvertedAxis)
          : fillPaint;
    }
    assert(_segmentProperties.series.opacity >= 0 == true,
        'The opacity value of the area series should be greater than or equal to 0.');
    assert(_segmentProperties.series.opacity <= 1 == true,
        'The opacity value of the area series should be less than or equal to 1.');
    fillPaint!.color = (_segmentProperties.series.opacity < 1 == true &&
            fillPaint!.color != Colors.transparent)
        ? fillPaint!.color.withOpacity(_segmentProperties.series.opacity)
        : fillPaint!.color;
    _segmentProperties.defaultFillColor = fillPaint;
    setShader(_segmentProperties, fillPaint!);
    return fillPaint!;
  }

  /// Gets the border color of the series.
  @override
  Paint getStrokePaint() {
    _setSegmentProperties();
    final Paint _strokePaint = Paint();
    _strokePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = _segmentProperties.series.borderWidth;
    if (_segmentProperties.series.borderGradient != null) {
      _strokePaint.shader = _segmentProperties.series.borderGradient!
          .createShader(_segmentProperties.strokePath!.getBounds());
    } else if (_segmentProperties.strokeColor != null) {
      _strokePaint.color = _segmentProperties.series.borderColor;
    }
    _segmentProperties.series.borderWidth == 0
        ? _strokePaint.color = Colors.transparent
        : _strokePaint.color;
    _strokePaint.strokeCap = StrokeCap.round;
    _segmentProperties.defaultStrokeColor = _strokePaint;
    return _strokePaint;
  }

  /// Calculates the rendering bounds of a segment.
  @override
  void calculateSegmentPoints() {}

  /// Draws segment in series bounds.
  @override
  void onPaint(Canvas canvas) {
    _setSegmentProperties();
    _segmentProperties.pathRect = _segmentProperties.path.getBounds();
    canvas.drawPath(
        _segmentProperties.path,
        (_segmentProperties.series.gradient == null)
            ? fillPaint!
            : getFillPaint());
    if (strokePaint!.color != Colors.transparent &&
        _segmentProperties.strokePath != null) {
      drawDashedLine(canvas, _segmentProperties.series.dashArray, strokePaint!,
          _segmentProperties.strokePath!);
    }
  }

  /// Method to set segment properties
  void _setSegmentProperties() {
    if (!_isInitialize) {
      _segmentProperties = SegmentHelper.getSegmentProperties(this);
      _isInitialize = true;
    }
  }
}
