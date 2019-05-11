class TransferEntity {
  final AccountEntity fromAccount;
  final List<AccountEntity> toAccounts;

  TransferEntity(this.fromAccount, this.toAccounts);
}

class AccountEntity {
  final int id;
  final String name;
  final double balance;

  AccountEntity(this.id, this.name, this.balance);
}