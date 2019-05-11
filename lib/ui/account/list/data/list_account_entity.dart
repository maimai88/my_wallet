class AccountEntity {
  final int id;
  final String name;
  final DateTime created;
  final double balance;
  final double spent;
  final bool _liability;

  AccountEntity(this.id, this.name, this.created, this.balance, this.spent, this._liability);

  get isLiability => _liability;
}