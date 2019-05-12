import 'package:flutter/material.dart';
import 'package:my_wallet/resources.dart' as R;

class CardListTile extends StatelessWidget {
  final double _elevation;
  final EdgeInsets _margin;
  final String _cardName;
  final String _cardDescription;
  final String _cardBalance;
  final String _cardSpent;
  final Function _onTap;
  final Color _cardColor;

  CardListTile({
    double elevation = 4.9,
    EdgeInsets margin = const EdgeInsets.all(8.0),
    @required String cardName,
    @required String cardDescription,
    @required String cardBalance,
    @required String cardSpent,
    @required Function onTap,
    @required Color cardColor
  }) : assert(cardColor != null),
        assert(cardName != null),
        assert(cardBalance != null),
        assert(cardSpent != null),
        assert(onTap != null),
        this._elevation = elevation,
        this._margin = margin,
        this._cardName = cardName,
        this._cardDescription = cardDescription == null ? "" : cardDescription,
        this._cardBalance = cardBalance,
        this._cardSpent = cardSpent,
        this._onTap = onTap,
        this._cardColor = cardColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      final width = constraint.maxWidth - _margin.left - _margin.right;
      final height = width / 1.586;

      return InkWell(
        onTap: _onTap,
        child: Card(
          elevation: _elevation,
          margin: _margin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: CustomPaint(
            size: Size(width, height),
            painter: _CardPainter(_cardColor),
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Text(
                      _cardName,
                      style: Theme.of(context).textTheme.display1.apply(fontFamily: R.font.raleway, fontWeightDelta: 2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,),
                  ),
                  Flexible(
                    flex: 1,
                    child: Text(
                      _cardDescription,
                      style: Theme.of(context).textTheme.body1,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Balance", style: Theme.of(context).textTheme.title,),
                            Text(_cardBalance, style: Theme.of(context).textTheme.title)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Spent", style: Theme.of(context).textTheme.title),
                            Text(_cardSpent, style: Theme.of(context).textTheme.title)
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },);
  }
}

class _CardPainter extends CustomPainter {
  final Color _cardColor;

  _CardPainter(this._cardColor);

  @override
  void paint(Canvas canvas, Size size) {
    final cardRect = RRect.fromLTRBR(0.0, 0.0, size.width, size.height, Radius.circular(15.0));
    canvas.drawRRect(
        cardRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(colors: [
            _cardColor,
            _cardColor.withOpacity(0.6),
            _cardColor.withOpacity(0.2)
          ]).createShader(cardRect.outerRect));

    canvas.save();
    canvas.clipRRect(cardRect);
    final paint = Paint()
      ..color = _cardColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final path = Path()
        ..moveTo(0.0, size.height)
        ..quadraticBezierTo(size.width/2, size.height/4, size.width/2, size.height/3*2)
        ..quadraticBezierTo(size.width, size.height/3, size.width, size.height/8)
        ..lineTo(size.width, size.height)
        ..lineTo(0.0, size.height);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}