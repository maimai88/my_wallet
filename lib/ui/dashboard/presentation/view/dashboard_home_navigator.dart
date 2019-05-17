import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/presentation/view/no_transition_page_route.dart';

// home navigator
import 'package:my_wallet/ui/home2/presentation/view/home2_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';
import 'package:my_wallet/ui/budget/category/presentation/view/create_category_view.dart';

class HomeNavigator extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey;

  HomeNavigator(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (setting) => createRoute(setting.name),
      initialRoute: '/',
    );
  }

  MaterialPageRoute createRoute(String name) {
    if (name == '/') {
      return NoTransitionPageRoute(
          builder: (context) => MyWalletHome()
      );
    }

    return MaterialPageRoute(
      builder: (context) => _generateWidget(name),
    );
  }

  Widget _generateWidget(name) {
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

    if(name.startsWith(routes.TransactionListCategory)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String categoryId = detail.replaceFirst("${routes.TransactionListCategory}/", "");

        if (categoryId == null || categoryId.isEmpty) break;

        try {
          int id = int.parse(categoryId);
          return TransactionList(title, categoryId: id,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.TransactionListDate)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String date = detail.replaceFirst("${routes.TransactionListDate}/", "");

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

          return TransactionList(title, day: day,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.CreateCategory)) {
      List<String> splits = name.split("/"); //  "$TransferAccount/from:$accountId/name:$accountName";;

      if(splits.length > 1) {
        // get category ID:
        var id = int.parse(splits[1].split(":")[1]);
        // get category name
        var accName = splits[2].split(":")[1];

        return CreateCategory(title: "Edit Category", id: id, name: accName);
      }

      return CreateCategory();
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