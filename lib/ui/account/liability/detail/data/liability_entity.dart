class LiabilityEntity {
  final int id;
  final String name;
  final DateTime created;
  final String type;
  final double initialBalance;
  final double balance;

  LiabilityEntity(this.id, this.name, this.created, this.type, this.initialBalance, this.balance);
}