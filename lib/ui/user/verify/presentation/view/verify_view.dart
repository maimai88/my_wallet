import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/verify/presentation/view/verify_data_view.dart';
import 'package:my_wallet/ui/user/verify/presentation/presenter/verify_presenter.dart';

import 'package:my_wallet/resources.dart' as R;

class RequestValidation extends StatefulWidget {
  final bool isProcessing;

  RequestValidation({this.isProcessing = false});

  @override
  State<StatefulWidget> createState() {
    return _RequestValidationState();
  }
}

class _RequestValidationState extends CleanArchitectureView<RequestValidation, RequestValidationPresenter> implements RequestValidationDataView {
  _RequestValidationState() : super(RequestValidationPresenter());

  GlobalKey<RoundedButtonState> _resendKey = GlobalKey();
  GlobalKey<RoundedButtonState> _revalidateKey = GlobalKey();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: R.string.validate_account,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: widget.isProcessing ? _buildProcessingPage() : _buildRequestPage()
      ),
    );
  }

  Widget _buildRequestPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          R.string.validate_account_message,
          style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
          textAlign: TextAlign.center,
        ),
        RoundedButton(
          key: _resendKey,
          onPressed: _requestValidationEmail,
          child: Text(R.string.send_new_validation_email),
          color: AppTheme.darkBlue,
        ),
        RoundedButton(
          onPressed: _changeEmail,
          child: Text(R.string.change_email_address),
          color: AppTheme.blueGrey,
        )
      ],
    );
  }

  Widget _buildProcessingPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          R.string.validate_email_processing,
          style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
          textAlign: TextAlign.center,
        ),
        RoundedButton(
          key: _revalidateKey,
          onPressed: _checkUserValidation,
          child: Text(R.string.validated),
          color: AppTheme.darkBlue,
        ),
      ],
    );
  }

  void _requestValidationEmail() {
    if(_resendKey.currentContext != null) _resendKey.currentState.process();

    presenter.requestValidationEmail();
  }

  @override
  void onRequestSent(bool result) {
    // show waiting for validation page
    Navigator.pushReplacementNamed(context, routes.ValidationProcessing);
  }

  void _changeEmail() {
    presenter.signOut();
  }

  @override
  void onSignOutSuccess(bool result) {
    Navigator.pushReplacementNamed(context, routes.Login);
  }

  void _checkUserValidation() {
    if(_revalidateKey.currentContext != null) _revalidateKey.currentState.process();
    presenter.checkUserValidation();
  }

  @override
  void onValidationResult(bool validated) {
    if(validated) Navigator.pushReplacementNamed(context, routes.HomeProfile);
    else Navigator.pushReplacementNamed(context, routes.RequestValidation);
  }
}