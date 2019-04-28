import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/view/newhome_data_view.dart';
import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/presenter/newhome_presenter.dart';

import 'package:my_wallet/resources.dart' as R;

class NewHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewHomeState();
  }
}

class _NewHomeState extends CleanArchitectureView<NewHome, NewHomePresenter> implements NewHomeDataView {
  _NewHomeState() : super(NewHomePresenter());

  final TextEditingController _hostEmailController = TextEditingController();
  final TextEditingController _homeNameController = TextEditingController();
  final GlobalKey<RoundedButtonState> _joinHomeState = GlobalKey();
  final GlobalKey<RoundedButtonState> _createHomeState = GlobalKey();

  bool _creatingHome = false;
  bool _joiningHome = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(R.string.join_a_home, style: Theme.of(context).textTheme.headline.apply(color: AppTheme.darkBlue)),
            margin: EdgeInsets.all(30.0),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: AppTheme.darkBlue.withOpacity(0.2)
            ),
            child: TextField(
              controller: _hostEmailController,
              decoration: InputDecoration.collapsed(
                hintText: R.string.enter_your_host_email_address,
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey),
              ),
              style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
            ),
          ),
          RoundedButton(
            key: _joinHomeState,
            onPressed: _joinAHome,
            child: Text(R.string.request_to_join_this_home),
            color: AppTheme.darkBlue,
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0,),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 1.0,
                    color: AppTheme.blueGrey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(R.string.or, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
                ),
                Expanded(
                  child: Container(
                    height: 1.0,
                    color: AppTheme.blueGrey,
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(R.string.create_a_new_home, style: Theme.of(context).textTheme.headline.apply(color: AppTheme.darkBlue)),
            margin: EdgeInsets.all(30.0),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: AppTheme.darkBlue.withOpacity(0.2)
            ),
            child: TextField(
              controller: _homeNameController,
              decoration: InputDecoration.collapsed(
                hintText: R.string.enter_your_home_name,
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey),
              ),
              style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
            ),
          ),
          RoundedButton(
            key: _createHomeState,
            onPressed: _createProfile,
            child: Text(R.string.create_home),
            color: AppTheme.darkBlue,
          ),
        ],
      ),
    );
  }

  void _createProfile() {
    if (_creatingHome) return;

    _creatingHome = true;
    _createHomeState.currentState.process();

    presenter.createHomeProfile(_homeNameController.text);
  }

  @override
  void onHomeCreated(bool result) {
    _creatingHome = false;
    _createHomeState.currentState.stop();

    Navigator.pushReplacementNamed(context, routes.MyHome);
  }

  @override
  void onHomeCreateFailed(Exception e) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text(R.string.failed_to_create_home),
              content: Text(R.string.create_home_error(_homeNameController.text, e.toString())),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(R.string.try_again),
                )
              ],
            )
    );
  }

  void _joinAHome() {
    if(_joiningHome) return;

    _joiningHome = true;
    _joinHomeState.currentState.process();
    presenter.joinHomeWithHost(_hostEmailController.text);
  }

  @override
  void onJoinSuccess(bool result) {
    _joiningHome = false;
    _joinHomeState.currentState.stop();

    Navigator.pushReplacementNamed(context, routes.MyHome);
  }

  @override
  void onJoinFailed(Exception e) {
    debugPrint(e.toString());
    _joiningHome = false;
    _joinHomeState.currentState.stop();

    showDialog(context: context,
    builder: (context) => AlertDialog(
      title: Text(R.string.failed_to_join_home),
      content: Text(R.string.join_home_error(_hostEmailController.text, e.toString())),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(R.string.try_again),
        )
      ],
    ));
  }
}