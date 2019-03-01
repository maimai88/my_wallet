import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/account/liability/payment/data/payment_repository.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

class PayLiabilityUseCase extends CleanArchitectureUseCase<PayLiabilityRepository> {
  PayLiabilityUseCase() : super(PayLiabilityRepository());

  void loadAccounts(int exceptId, onNext<List<Account>> next, onError error) {
    execute(repo.loadAccountsExceptId(exceptId), next, error);
  }

  void loadCategories(CategoryType type, onNext<List<AppCategory>> next, onError error) {
    execute(repo.loadCategories(type), next, error);
  }

  void savePayment(int liabilityId, Account fromAccount, AppCategory category, double dischargeLiability, double interest, double additionalPayment, DateTime date, onNext<bool> next, onError error) {
    execute(Future(() async {
      if(category == null) throw Exception("Please select category");
      if(fromAccount == null) throw Exception("Please select Transfer account");
      if(dischargeLiability == null || dischargeLiability == 0) throw Exception("Amount to discharge liability is 0");

      // Create a dischargeOfLiability transaction
      var id = await repo.generateDischargeLiabilityId();

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String userUid = sharedPreferences.getString(UserUUID);

      DischargeOfLiability discharge = DischargeOfLiability(id, date, liabilityId, fromAccount.id, category.id, dischargeLiability, userUid);

      await repo.saveDischargeOfLiability(discharge);

      // TODO save interest and additional payment
      if(interest > 0) {
        // save interest as expenses
        AppTransaction interestTransaction = AppTransaction(
            id,
            date,
            fromAccount.id,
            category.id,
            interest,
            "Liability interest",
            TransactionType.expenses,
            userUid);
        await repo.saveInterestTransaction(interestTransaction);
      }

      if(additionalPayment > 0) {
        // save Additional payment as part of Discharge of liability
        var additionalPaymentId = await repo.generateDischargeLiabilityId();

        DischargeOfLiability additionalPaymentOfLiability = DischargeOfLiability(additionalPaymentId, date, liabilityId, fromAccount.id, category.id, additionalPayment, userUid);

        await repo.saveDischargeOfLiability(additionalPaymentOfLiability);
      }

    }), next, error);
  }
}