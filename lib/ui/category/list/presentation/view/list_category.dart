import 'package:my_wallet/ui/category/list/presentation/presenter/list_category_presenter.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/category/list/presentation/view/list_category_data_view.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:intl/intl.dart';

class CategoryList extends StatefulWidget {
  final String _title;
  final bool returnValue;

  CategoryList(this._title, {this.returnValue = false});

  @override
  State<StatefulWidget> createState() {
    return _CategoryListState();
  }
}

class _CategoryListState
    extends CleanArchitectureView<CategoryList, ListCategoryPresenter>
    implements CategoryListDataView, observer.DatabaseObservable {
  _CategoryListState() : super(ListCategoryPresenter());

  final _iconSize = 45.0;
  final tables = [observer.tableCategory];
  final _nf = NumberFormat("\$#,###.##");

  List<CategoryListItemEntity> _categories = [];

  var isEditMode = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);
    _loadCategories();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  @override
  void onDatabaseUpdate(String table) {
    presenter.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: widget._title,
        actions: <Widget>[
          FlatButton(
            child: Text(isEditMode ? "Done" : "Edit"),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          )
        ],
      ),
      body: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (_, index) => Container(
                color: index % 2 == 0 && index < _categories.length
                    ? AppTheme.blueGrey.withOpacity(0.2)
                    : AppTheme.white,
                child: ListTile(
                    leading: Container(
                      width: _iconSize,
                      height: _iconSize,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Icon(
                                  Icons.monetization_on,
                                  color: Color(AppTheme.hexToInt(
                                      _categories[index].colorHex)),
                                  size: _iconSize,
                                ),
                                heightFactor: _categories[index].remainFactor,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            width: _iconSize,
                            height: _iconSize,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Color(AppTheme.hexToInt(
                                        _categories[index].colorHex)),
                                    width: 1.0)),
                          )
                        ],
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(
                        context,
                        routes.TransactionList(_categories[index].name,
                            categoryId: _categories[index].categoryId)),
                    title: Text(
                      _categories[index].name,
                      style: TextStyle(color: AppTheme.darkBlue),
                    ),
                    trailing: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(children: [
                          TextSpan(
                            text: _nf.format(_categories[index].spent),
                            style: TextStyle(color: AppTheme.darkBlue),
                          ),
                          TextSpan(
                            text:
                                "\n(${_nf.format(_categories[index].budget)})",
                            style: TextStyle(
                                color: _categories[index].budget >= 0
                                    ? AppTheme.tealAccent
                                    : AppTheme.red),
                          )
                        ]))
                    //Text(_nf.format(_homeEntities[index].transaction), style: TextStyle(color: _homeEntities[index].transaction > _homeEntities[index].budget ? AppTheme.red : AppTheme.darkBlue),),
                    )),
          ),
      floatingActionButton: isEditMode
          ? RoundedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, routes.CreateCategory)
                      .then((value) {
                    if (value != null) _loadCategories();
                  }),
              child: Text(("Create Category"),),
              color: AppTheme.pinkAccent,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _loadCategories() {
    presenter.loadCategories();
  }

  void onCategoriesLoaded(List<CategoryListItemEntity> value) {
    if (value != null)
      setState(() {
        _categories = value;
      });
  }

  int stageCrossAxisCellCount(String name) {
    if (name.length > 12)
      return 3;
    else if (name.length > 7)
      return 2;
    else
      return 1;
  }

  int stageMainAxisCellCount(String name) {
    return 1;
  }
}
