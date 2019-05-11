import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/no_transition_page_route.dart';

// account navigator
import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_view.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';
import 'package:my_wallet/ui/account/liability/payment/presentation/view/payment_view.dart';
import 'package:my_wallet/ui/account/liability/detail/presentation/view/liability_view.dart';
import 'package:my_wallet/ui/account/transfer/presentation/view/transfer_view.dart';

class AccountNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  AccountNavigator(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return Navigator(
        onGenerateRoute: (setting) => createRoute(setting.name)
    );
  }

  MaterialPageRoute createRoute(String name) {
    if (name == '/') {
      return NoTransitionPageRoute(builder: (context) => ListAccounts());
    }

    return MaterialPageRoute(
      maintainState: true,
      builder: (context) => _generateAccountRoute(name)
    );
  }

  Widget _generateAccountRoute(String name) {
    if(name.startsWith(routes.Accounts)) {
      do {
        String data = name.replaceFirst("${routes.Accounts}/", "");

        if(data == null) break;
        if(data.isEmpty) break;

        List<String> splits = data.split(":");

        String strAccId = splits[0];
        String accName = splits[1];

        try {
          int _accountId = int.parse(strAccId);
          return AccountDetail(_accountId, accName);
        } catch(e) {}
      } while(false);
    }

    if(name == routes.AddAccount) {
      return CreateAccount();
    }

    if (name.startsWith("${routes.AddTransaction}")) {
      List<String> ids = name.split("/");
      // get all data out
      int transactionId;
      try {
        transactionId = int.parse(ids[1]);

        return AddTransaction(transactionId: transactionId,);
      } catch(e) {
        debugPrint("No transaction ID $name");
      }

      int accountId;
      try {
        accountId = int.parse(ids[2]);

        return AddTransaction(accountId: accountId);
      } catch(e) {
        debugPrint("no account ID $name");
      }

      int categoryId;
      try {
        categoryId = int.parse(ids[3]);
        return AddTransaction(categoryId: categoryId);
      } catch(e) {
        debugPrint("no category id $name");
      }

      return AddTransaction();
    }

    if(name.startsWith(routes.TransactionListAccount)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String accountId = detail.replaceFirst("${routes.TransactionListAccount}/", "");

        if (accountId == null || accountId.isEmpty) break;

        try {
          int id = int.parse(accountId);
          return TransactionList(title, accountId: id,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.TransferAccount)) {
      List<String> splits = name.split("/"); //  "$TransferAccount/from:$accountId/name:$accountName";;

      // get account ID:
      var id = int.parse(splits[1].split(":")[1]);
      // get account name
      var accName = splits[2].split(":")[1];

      return AccountTransfer(id, accName);
    }

    if(name.startsWith(routes.Liability)) {
      List<String> splits = name.split("/"); //  "$TransferAccount/from:$accountId/name:$accountName";;

      // get account ID:
      var id = int.parse(splits[1].split(":")[1]);
      // get account name
      var accName = splits[2].split(":")[1];

      return LiabilityView(id, accName);
    }

    if(name.startsWith(routes.Pay)) {
      List<String> splits = name.split("/"); //  "$TransferAccount/from:$accountId/name:$accountName";;

      // get account ID:
      var id = int.parse(splits[1].split(":")[1]);
      // get account name
      var accName = splits[2].split(":")[1];

      return PayLiability(id, accName);
    }

    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: "Coming Soon",
      ),
      body: Center(
        child: Text("Unknown page $name", style: TextStyle(color: AppTheme.darkBlue),),
      ),
    );
  }
}