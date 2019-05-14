import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

class NumberInputPad extends StatefulWidget {
  final Function(double) _onValueChanged;
  final double _initialValue;
  final Widget _child;

  NumberInputPad(GlobalKey<NumberInputPadState> key,
  {
    Function(double) onValueChange,
    double initialValue,
    Widget child,
  }) :
        assert(onValueChange != null),
        assert(child != null),
        this._onValueChanged = onValueChange,
        this._initialValue = initialValue ?? 0.0,
        this._child = child,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NumberInputPadState();
  }
}

class NumberInputPadState extends State<NumberInputPad> {
  String _number = "";
  String _decimal = "";
  bool _isDecimal = false;

  GlobalKey _stickyKey = new GlobalKey();

  static final _numbers = [
    "1", "2", "3",
    "4", "5", "6",
    "7", "8", "9",
    ".", "0", "C"];

  static final _column = 3;
  static final _row = _numbers.length/_column;

  @override
  void initState() {
    super.initState();

    _number = widget._initialValue != 0 ? "${widget._initialValue.floor()}" : "";
    _decimal = widget._initialValue != 0 && widget._initialValue - widget._initialValue.floor() != 0 ? "${widget._initialValue - widget._initialValue.floor()}" : "";

    if(_number == null) _number = "";
    if(_decimal == null) _decimal = "";

    _isDecimal = widget._initialValue.floor() != widget._initialValue;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 3,
          child: widget._child,
        ),
        Flexible(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.bgGradient
            ),
            child: SafeArea(
                child: LayoutBuilder(builder: (context, constraint) {
                  final childAspectRatio = (constraint.maxWidth/_column)/(constraint.maxHeight/_row);

                  return SizedBox.fromSize(
                    size: constraint.biggest,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: GridView.count(
                          crossAxisCount: 3,
                      children: _numbers.map((title) => _createButton(title, _onButtonClick)).toList(),
                      childAspectRatio: childAspectRatio,),
                      decoration: BoxDecoration(
                        gradient: AppTheme.bgGradient
                      ),
                    ),
                  );
                })),
          ),
        )
      ],
    );
  }

  Widget _createButton(String title, ValueChanged<String> f, {double width, double height}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 0.3),
      ),
      child: FlatButton(onPressed: () => f(title), child: Text(title, style: TextStyle(fontSize: 24.0), textAlign: TextAlign.center,)),
    );
  }

  void _onButtonClick(String value) {
    switch (value) {
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
      case "0":
        if (_isDecimal) {
          if (_decimal.length < 2) _decimal += value;
        } else {
          if (_number.length < 12) _number += value;
        }
        break;
      case "C":
        if (_isDecimal && _decimal.isNotEmpty)
          _decimal = _decimal.substring(0, _decimal.length - 1);
        else if (_number.isNotEmpty) {
          _number = _number.substring(0, _number.length - 1);
          _isDecimal = false;
        } else {
          _isDecimal = false;
        }
        break;
      case ".":
        _isDecimal = true;
        break;
    }

    var amount = double.parse("${_number == null || _number.isEmpty ? 0 : _number}.${_decimal == null || _decimal.isEmpty ? 0 : _decimal}");
    widget._onValueChanged(amount);
  }
}