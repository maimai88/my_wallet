class AccountEntity {
  final int id;
  final String name;
  final String type;
  final double balance;
  final double spent;
  final bool _liability;

  AccountEntity(this.id, this.name, this.type, this.balance, this.spent, this._liability);

  get isLiability => _liability;
}