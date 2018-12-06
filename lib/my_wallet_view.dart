import 'package:my_wallet/app_theme.dart' as theme;
import 'package:flutter/material.dart';
import 'package:my_wallet/database/data.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyWalletAppBar extends AppBar {
  MyWalletAppBar(
      {String title,
        String subTitle,
        List<Widget> actions,
        Widget leading}) : super(
      title: subTitle == null ? Text("$title", style: TextStyle(color: Colors.white),)
    : Column(
        children: <Widget>[
          Text("$title", style: TextStyle(color: Colors.white),),
          Text("$subTitle", style: TextStyle(color: Colors.white, fontSize: 14.0),)
        ],
      ),
      actions: actions,
      backgroundColor: theme.darkBlue,
      centerTitle: true,
      leading: leading,);
}

class MyWalletSliverAppBar extends SliverAppBar {
  MyWalletSliverAppBar(
      {String title,
        String subTitle,
        List<Widget> actions,
        Widget leading}
      ) : super(
    title: Text("$title", style: TextStyle(color: Colors.white),),
    actions: actions,
    leading: leading
  );
}

class SelectTransactionType extends StatefulWidget {
  final TransactionType _type;
  final ValueChanged<TransactionType> _onChanged;

  SelectTransactionType(this._type, this._onChanged);

  @override
  State<StatefulWidget> createState() {
    return _TransactionTypeState();
  }
}
class _TransactionTypeState extends State<SelectTransactionType> with TickerProviderStateMixin {
  TransactionType _type;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _type = widget._type;
    _tabController = TabController(length: TransactionType.all.length, vsync: this);

    _tabController.addListener(_onTabValueChanged);
    _tabController.index = _type.id;

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Container(
        child: TabBar(
          isScrollable: true,
          tabs: TransactionType.all.map((f) => Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(f.name,
              style: TextStyle(color: _type == f ? Colors.white : theme.darkBlue, fontSize: 16.0),),
          )).toList(),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: theme.pinkAccent, //_type == TransactionType.Income ? theme.darkGreen : theme.pinkAccent,
          ),
          controller: _tabController,
        ),
      ),
    );
  }

  void _onTabValueChanged() {
    setState(() {
      _type = TransactionType.all[_tabController.index];
    });
    widget._onChanged(_type);
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }
}

class NumberInputPad extends StatefulWidget {
  final Function(String, String) _onValueChanged;
  final String _number;
  final String _decimal;

  NumberInputPad(this._onValueChanged, this._number, this._decimal);

  @override
  State<StatefulWidget> createState() {
    return _NumberInputPadState();
  }
}

class _NumberInputPadState extends State<NumberInputPad> {
  String number = "";
  String decimal = "";
  bool isDecimal = false;

  @override
  void initState() {
    super.initState();

    number = widget._number;
    decimal = widget._decimal;

    if(number == null) number = "";
    if(decimal == null) decimal = "";

    isDecimal = decimal.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    final numbers = ["1", "2", "3", "C", "4", "5", "6", "7", "8", "9", "0", "."];
    final size = 100.0;

    return Container(
      child: StaggeredGridView.countBuilder(
        shrinkWrap: true,
        primary: false,
        crossAxisCount: 4,
        itemCount: numbers.length,
        itemBuilder: (BuildContext context, int index) => _createButton(numbers[index], _onButtonClick, width: size, height: size),
        staggeredTileBuilder: (int index) => new StaggeredTile.count(_isDoubleWidth(index) ? 2 : 1, _isDoubleHeight(index) ? 3 : 1),
        crossAxisSpacing: 0.3,
      ),
    );
  }

  Widget _createButton(String title, ValueChanged<String> f, {double width, double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.3),
          color: theme.darkBlue
      ),
      child: FlatButton(onPressed: () => f(title), child: Text(title, style: TextStyle(fontSize: 24.0), textAlign: TextAlign.center,)),
    );
  }

  bool _isDoubleHeight(int index) {
    return index == 3;
  }

  bool _isDoubleWidth(int index) {
    return index == 10 || index == 11;
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
        if (isDecimal) {
          if (decimal.length < 2) decimal += value;
        } else {
          if (number.length < 12) number += value;
        }
        break;
      case "C":
        if (isDecimal && decimal.isNotEmpty)
          decimal = decimal.substring(0, decimal.length - 1);
        else if (number.isNotEmpty) {
          number = number.substring(0, number.length - 1);
          isDecimal = false;
        } else {
          isDecimal = false;
        }
        break;
      case ".":
        isDecimal = true;
        break;
    }

    widget._onValueChanged(number, decimal);
  }
}