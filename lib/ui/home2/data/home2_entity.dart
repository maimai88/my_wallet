export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/data.dart';

import 'package:my_wallet/ui/home2/data/expenses_entity.dart';
export 'package:my_wallet/ui/home2/data/expenses_entity.dart';

import 'package:my_wallet/ui/home2/data/chart_title_entity.dart';
export 'package:my_wallet/ui/home2/data/chart_title_entity.dart';

class HomeEntity {
  final double totalOverview;
  final ChartTitleEntity chartTitleEntity;
  final List<ExpenseEntity> expenseEntity;

  HomeEntity(this.totalOverview, this.chartTitleEntity, this.expenseEntity);
}