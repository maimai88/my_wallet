import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

class BudgetSlider extends CustomPaint {
  BudgetSlider(
    BuildContext context, {
    double primaryValue = 0.0,
    double primaryMax = 0.0,
    String primaryLabel = "",
    String primaryIndicatorLine1 = "",
    String primaryIndicatorLine2 = "",
    Color primaryTextColor = AppTheme.darkBlue,
    double secondaryValue = 0.0,
    double secondaryMax = 0.0,
    String secondaryLabel = "",
    Color secondaryTextColor = AppTheme.white,
    double sliderWidth = 0.0,
    double sliderHeight = 0.0,
    Color activeColor = AppTheme.white,
    double indicatorArrowHeight = 10.0,
    double indicatorHeight = 40.0,
    double indicatorWidth = 80.0,
    Size size = Size.zero,
  }) : super(
          painter: _BudgetSliderPainter(context,
              primaryValue: primaryValue,
              primaryMax: primaryMax,
              primaryLabel: primaryLabel,
              primaryIndicatorLine1: primaryIndicatorLine1,
              primaryIndicatorLine2: primaryIndicatorLine2,
              primaryTextColor: primaryTextColor,
              secondaryMax: secondaryMax,
              secondaryValue: secondaryValue,
              secondaryLabel: secondaryLabel,
              secondaryTextColor: secondaryTextColor,
              sliderWidth: sliderWidth,
              sliderHeight: sliderHeight,
              activeColor: activeColor,
              indicatorArrowHeight: indicatorArrowHeight,
              indicatorHeight: indicatorHeight,
              indicatorWidth: indicatorWidth),
          size: size,
        ) {
    assert(size != null);
  }
}

class _BudgetSliderPainter extends CustomPainter {
  final BuildContext context;

  // primary bar
  final double primaryValue;
  final double primaryMax;
  final String primaryLabel;
  final String primaryIndicatorLine1;
  final String primaryIndicatorLine2;

  final double secondaryValue;
  final double secondaryMax;
  final String secondaryLabel;

  Color inactiveColor;
  final Color activeColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final indicatorWidth;
  final indicatorHeight;
  final indicatorArrowHeight;

  final sliderHeight;
  final sliderWidth;

  _BudgetSliderPainter(this.context,
      {this.primaryValue,
      this.primaryMax,
      this.primaryLabel,
      this.primaryIndicatorLine1,
      this.primaryIndicatorLine2,
      this.primaryTextColor,
      this.secondaryValue,
      this.secondaryMax,
      this.secondaryLabel,
      this.secondaryTextColor,
      this.activeColor,
      this.sliderHeight,
      this.sliderWidth,
      this.indicatorWidth,
      this.indicatorHeight,
      this.indicatorArrowHeight}) {
    inactiveColor = activeColor.withOpacity(0.7);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    var top = (size.height - sliderHeight) / 2;
    var bottom = top + sliderHeight;
    var fontSize = Theme.of(context).textTheme.title.fontSize;

    var sliderRect = ui.Rect.fromLTRB(0, top, sliderWidth, bottom);

    _drawSlider(canvas, size, sliderRect, fontSize);
    _drawSecondaryIndicator(canvas, size, sliderRect);
  }

  void _drawSlider(ui.Canvas canvas, ui.Size size, ui.Rect sliderRect, double fontSize) {
    var progressRatio = primaryMax == 0 ? 0 : primaryValue / primaryMax;

    // draw slider
    ui.Paint sliderBackground = new ui.Paint()
      ..color = inactiveColor
      ..strokeCap = ui.StrokeCap.round
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;
    ui.Paint sliderProgress = new ui.Paint()
      ..color = activeColor
      ..strokeCap = ui.StrokeCap.round
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;
    final progressRadius = ui.Radius.circular(10.0);

    canvas.drawRRect(ui.RRect.fromRectAndRadius(sliderRect, progressRadius), sliderBackground);

    var progressWidth = sliderRect.width * progressRatio;
    canvas.drawRRect(ui.RRect.fromRectAndRadius(ui.Rect.fromLTRB(sliderRect.left, sliderRect.top, progressWidth, sliderRect.bottom), progressRadius), sliderProgress);

    // draw primary label => max primary
    drawText(canvas, primaryLabel, sliderRect, primaryTextColor, ui.TextAlign.right);

    // draw expenses indicator
    var indicatorBottom = sliderRect.top - indicatorArrowHeight;
    var indicatorTop = indicatorBottom - indicatorHeight;
    var indicatorLeft = progressWidth - indicatorWidth / 2;
    var indicatorRight = indicatorLeft + indicatorWidth;
    final indicatorRect = ui.Rect.fromLTRB(indicatorLeft, indicatorTop, indicatorRight, indicatorBottom);
    canvas.drawRRect(ui.RRect.fromRectAndRadius(indicatorRect, progressRadius), sliderProgress);

    // create little arrow path
    final arrowWidth = indicatorWidth / 4;
    ui.Path path = new ui.Path()
      ..moveTo(indicatorLeft + indicatorWidth / 2 - arrowWidth / 2, indicatorBottom)
      ..lineTo(indicatorLeft + indicatorWidth / 2, indicatorBottom + indicatorArrowHeight)
      ..lineTo(indicatorLeft + indicatorWidth / 2 + arrowWidth / 2, indicatorBottom);
    canvas.drawPath(path, sliderProgress);

    // draw primary indicator string
    if (primaryIndicatorLine2 == null || primaryIndicatorLine2.isEmpty) {
      drawText(canvas, primaryIndicatorLine1, indicatorRect, primaryTextColor, ui.TextAlign.center);
    } else {
      draw2LinesText(
          canvas,
          primaryIndicatorLine1,
          primaryIndicatorLine2,
          indicatorRect,
          primaryTextColor,
          ui.TextAlign.center,
          fontSize);
    }
  }

  void _drawSecondaryIndicator(ui.Canvas canvas, ui.Size size, ui.Rect sliderRect) {
    ui.Paint dayIndicator = new ui.Paint()
      ..color = activeColor
      ..strokeCap = ui.StrokeCap.round
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..isAntiAlias = true;

    var daysRatio = secondaryMax > 0 ? secondaryValue / secondaryMax : 0;
    var indicatorPosition = daysRatio * sliderRect.width;
    canvas.drawLine(ui.Offset(indicatorPosition, sliderRect.top - 10), ui.Offset(indicatorPosition, sliderRect.bottom + 10), dayIndicator);

    final textRect = ui.Rect.fromLTRB(indicatorPosition - 60, sliderRect.bottom + 10, indicatorPosition + 60, sliderRect.bottom + 20);
    drawText(canvas, secondaryLabel, textRect, secondaryTextColor, ui.TextAlign.center);
  }

  void drawText(ui.Canvas canvas, String text, ui.Rect boundary, Color color, ui.TextAlign textAlign) {
    final textPainter = new Paint()..color = color;

    final ui.Size size = boundary.size;

    final paragraphStyle = new ui.ParagraphStyle(
      textAlign: textAlign,
    );
    final paragraphBuilder = new ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(new ui.TextStyle(foreground: textPainter))
      ..addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(new ui.ParagraphConstraints(width: size.width / 2));

    var dx = 0.0;
    var dy = 0.0;

    switch (textAlign) {
      case ui.TextAlign.center:
        dx = size.width * 0.25;
        dy = size.height * 0.33;
        break;
      case ui.TextAlign.right:
      case ui.TextAlign.end:
        dx = size.width * 0.48;
        dy = size.height * 0.33;
        break;
      case ui.TextAlign.left:
      case ui.TextAlign.start:
      case ui.TextAlign.justify:
        dx = 0.0;
        dy = size.height * 0.33;
        break;
    }

    ui.Offset offset = new ui.Offset(dx, dy);

    canvas.save();
    canvas.translate(boundary.left, boundary.top);
    canvas.drawParagraph(paragraph, offset);
    canvas.restore();
  }

  void draw2LinesText(ui.Canvas canvas, String firstLineText, String secondLineText, ui.Rect boundary, ui.Color color, ui.TextAlign textAlign, double fontSize) {
    final textPainter = new ui.Paint()..color = color;

    final ui.Size size = boundary.size;

    final paragraphStyle = new ui.ParagraphStyle(
      textAlign: textAlign,
    );
    final primaryParagraphBuilder = new ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(new ui.TextStyle(foreground: textPainter, fontSize: fontSize))
      ..addText(firstLineText);
    final primaryParagraph = primaryParagraphBuilder.build();
    primaryParagraph.layout(new ui.ParagraphConstraints(width: size.width));

    final secondaryParagraphBuilder = new ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(new ui.TextStyle(foreground: textPainter, fontSize: fontSize * 0.6))
      ..addText(secondLineText);
    final secondaryParagraph = secondaryParagraphBuilder.build();
    secondaryParagraph.layout(new ui.ParagraphConstraints(width: size.width));

    ui.Offset primaryLine = new ui.Offset(0.0, size.height * 0.05);
    ui.Offset secondaryLine = new ui.Offset(0.0, size.height * 0.6);

    canvas.save();
    canvas.translate(boundary.left, boundary.top);
    canvas.drawParagraph(primaryParagraph, primaryLine);
    canvas.drawParagraph(secondaryParagraph, secondaryLine);
    canvas.restore();
  }
}
