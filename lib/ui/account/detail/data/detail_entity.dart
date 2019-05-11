class AccountDetailEntity {
  final int id;
  final String name;
  final DateTime created;
  final String type;
  final double balance;
  final double spent;
  final double earn;

  AccountDetailEntity(this.id, this.name, this.created, this.type, this.balance, this.spent, this.earn);
}