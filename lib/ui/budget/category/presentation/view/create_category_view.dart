import 'package:my_wallet/ui/budget/category/presentation/presenter/create_category_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/budget/category/presentation/view/create_category_data_view.dart';

import 'package:my_wallet/resources.dart' as R;

class CreateCategory extends StatefulWidget {
  final int id;
  final String name;
  final String title;

  CreateCategory({this.title = R.string.create_category, this.id, this.name});

  @override
  State<StatefulWidget> createState() {
    return _CreateCategoryState();
  }
}

class _CreateCategoryState extends CleanArchitectureView<CreateCategory, CreateCategoryPresenter> implements CreateCategoryDataView {
  _CreateCategoryState() : super(CreateCategoryPresenter());

  String _name;
  CategoryType _type;

  GlobalKey<TransactionTypeState<CategoryType>> _categoryTypeKey = GlobalKey();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    _type = CategoryType.expense;
    _name = widget.name;

    if(widget.id != null) {
      presenter.loadCategoryDetail(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
        actions: <Widget>[
          FlatButton(
            child: Text(R.string.save),
            onPressed: () => presenter.saveCategory(widget.id, _name, _type, 0 /* to be updated with group ID */),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: SelectTransactionType<CategoryType>(
                CategoryType.all,
                _type,
                    (CategoryType data) => data.id,
                    (CategoryType data) => data.name,
                    (CategoryType selected) {
                  _type = selected;
                },
                key: _categoryTypeKey,),
          ),
          DataRowView(
            R.string.category_name,
            _name == null ? R.string.enter_category_name : _name,
            onPress: () => Navigator.push(context, SlidePageRoute(builder: (context) => InputName(R.string.category_name, _onNameChanged, hintText: _name == null ? R.string.enter_category_name : _name))),
          ),
        ],
      ),
    );
  }

  @override
  void onCreateCategorySuccess(int categoryId) {
    Navigator.pop(context, categoryId);
  }

  @override
  void onCreateCategoryError(Exception e) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(R.string.error),
      content: Text(e.toString()),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(R.string.ok),
        )
      ],
    ));
  }

  @override
  void onCategoryDetailLoaded(AppCategory category) {
    setState(() {
      _name = category.name;
      _type = category.categoryType;

      if(_categoryTypeKey.currentContext != null) {
        _categoryTypeKey.currentState.updateSelection(_type);
      }
    });

    debugPrint("category loaded $_name ${_type.name}");
  }

  void _onNameChanged(String name) {
    _name = name;
  }
}