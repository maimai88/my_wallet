import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/user/detail/presentation/view/detail_data_view.dart';

import 'package:my_wallet/resources.dart' as R;

class UserDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserDetailState();
  }
}

class _UserDetailState extends CleanArchitectureView<UserDetail, UserDetailPresenter> implements UserDetailDataView {
  _UserDetailState() : super(UserDetailPresenter());

  UserDetailEntity _user;

  @override
  init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.height * 0.25;

    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: R.string.your_profile,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SizedBox(
                height: iconSize,
                width: iconSize,
                child: CircleAvatar(
                  backgroundColor: _user == null || _user.color == null ? AppTheme.white : Color(_user.color),
//                  child: _user != null
//                      ? _user.photoUrl == null || _user.photoUrl.isEmpty ? IconButton(icon: Icon(Icons.camera_alt, color: AppTheme.blueGrey,), onPressed: _openCameraOptionSelection,) : Icon(Icons.face, color: AppTheme.darkBlue,)
//                      : Text(""),
                child: Image.asset(R.asset.nartus),
                ),
              ),
            ),
          ),
          Center(child: Text(_user != null ? _user.displayName : "", style: Theme.of(context).textTheme.headline,),),
          Center(child: Text(_user != null ? _user.email : "", style: Theme.of(context).textTheme.title,),),
          DataRowView(R.string.home, _user != null && _user.homeName != null ? _user.homeName : "", color: AppTheme.white,),
          DataRowView(R.string.host, _user != null && _user.hostDisplayName != null ? _user.hostDisplayName : "", color: AppTheme.white,),
          DataRowView(R.string.host_email, _user != null && _user.hostEmail != null ? _user.hostEmail : "", color: AppTheme.white,)
        ],
      ),
    );
  }

  void _openCameraOptionSelection() {
//    showModalBottomSheet(
//        context: context,
//        builder: (context) => BottomSheet(
//            onClosing: _onBottomSheetClosing,
//            builder: (context) => SizedBox(
//              height: 150,
//              child: Center(child: Text("hahaha", style: TextStyle(color: AppTheme.darkBlue),),),
//            )
//        )
//    );
  }

  @override
  void onUserLoaded(UserDetailEntity user) {
    if(user != null) {
      setState(() => _user = user);
    }
  }
}
