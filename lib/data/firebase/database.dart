import 'dart:async';

import 'package:my_wallet/data/local/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/fb_common.dart';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';

const _data = "data";

DocumentReference _firestore;

bool _isInit = false;
bool _isDbSetup = false;

FirebaseApp _app;

Map<String, StreamSubscription> subs = {};

Future<void> init(FirebaseApp app, {String homeProfile}) async {
  if (_isInit) return;

  _isInit = true;
  if(_app != null) _app = app;

  if (homeProfile != null && homeProfile.isNotEmpty) await setupDatabase(homeProfile);
}

Future<void> dispose() {
  return _lock.synchronized(() {
    _unsubscribe();
  });
}

Future<void> resume() {
  return _lock.synchronized(() => _addSubscriptions());
}

Future<void> setupDatabase(final String homeKey) async {
  return _lock.synchronized(() async {
    if (_isDbSetup) return;

    _isDbSetup = true;

    _firestore = (await firestore(_app)).collection(_data).document(homeKey);

    DocumentSnapshot snapShot;
    try {
        snapShot = await _firestore.get();
    } catch (e) {
      debugPrint("timeout on homekey data");
    }

    if(snapShot == null || snapShot.documentID == null || snapShot.documentID.isEmpty) {
      debugPrint("drop all table");
      // drop database
      await db.dropAllTables();
    }

    await _addSubscriptions();
  });
}

Future<void> _addSubscriptions() async {
  for(String table in allTables) {
    subs.putIfAbsent(table, () => _firestore.collection(table).snapshots().listen((f) async {
      if(f.documentChanges != null && f.documentChanges.length > 0) {
        final batchIdentifier = db.startTransaction();
        f.documentChanges.forEach((change) async {
          if(change == null) return;
          if(change.document == null) return;

          //print("Change ${change.type} with ID ${change.document.documentID} in table $table");
          switch(change.type) {
            case DocumentChangeType.added: await _onAdded(table, change.document, batchIdentifier); break;
            case DocumentChangeType.modified: await _onModified(table, change.document, batchIdentifier); break;
            case DocumentChangeType.removed: await _onRemoved(table, change.document, batchIdentifier); break;
          }
        });
        await db.execute(batchIdentifier: batchIdentifier);
      }
    }));
  }
}

Future<void> _onAdded(String table, DocumentSnapshot document, String batchIdentifier) {
  switch (table) {
    case tblAccount: return _onAccountAdded(document, batchIdentifier);
    case tblBudget: return _onBudgetAdded(document, batchIdentifier);
    case tblCategory: return _onCategoryAdded(document, batchIdentifier);
    case tblDischargeOfLiability: return _onDischargeOfLiabilityAdded(document, batchIdentifier);
    case tblTransfer: return _onTransferAdded(document, batchIdentifier);
    case tblTransaction: return _onTransactionAdded(document, batchIdentifier);
    case tblUser: return _onUserAdded(document, batchIdentifier);
  }

  throw Exception("Table $table is not defined");
}

Future<void> _onModified(String table, DocumentSnapshot document, String batchIdentifier) {
  switch (table) {
    case tblAccount: return _onAccountChanged(document, batchIdentifier);
    case tblBudget: return _onBudgetChanged(document, batchIdentifier);
    case tblCategory: return _onCategoryChanged(document, batchIdentifier);
    case tblDischargeOfLiability: return _onDischargeOfLiabilityChanged(document, batchIdentifier);
    case tblTransfer: return _onTransferChanged(document, batchIdentifier);
    case tblTransaction: return _onTransactionChanged(document, batchIdentifier);
    case tblUser: return _onUserChanged(document, batchIdentifier);
  }

  throw Exception("Table $table is not defined");
}

Future<void> _onRemoved(String table, DocumentSnapshot document, String batchIdentifier) {
  switch (table) {
    case tblAccount: return _onAccountRemoved(document, batchIdentifier);
    case tblBudget: return _onBudgetRemoved(document, batchIdentifier);
    case tblCategory: return _onCategoryRemoved(document, batchIdentifier);
    case tblDischargeOfLiability: return _onDischargeOfLiabilityRemoved(document, batchIdentifier);
    case tblTransfer: return _onTransferRemoved(document, batchIdentifier);
    case tblTransaction: return _onTransactionRemoved(document, batchIdentifier);
    case tblUser: return _onUserRemoved(document, batchIdentifier);
  }

  throw Exception("Table $table is not defined");
}

// ####################################################################################################
// private helper
Map<String, dynamic> _AccountToMap(Account acc) {
  return {
    fldName: acc.name,
    fldType: acc.type.id,
    fldInitlaBalance: acc.initialBalance,
    fldCreated: acc.created.millisecondsSinceEpoch,
    fldCurrency: acc.currency
  };
}

Account _snapshotToAccount(DocumentSnapshot snapshot) {
  var initialBalance = snapshot.data[fldInitlaBalance];
  var created = snapshot.data[fldCreated];

  return Account
    (_toId(snapshot),
    snapshot.data[fldName],
    double.parse("${initialBalance == null ? '0' : initialBalance}"),
    snapshot.data[fldType] == null ? null : AccountType.all[snapshot.data[fldType]],
    snapshot.data[fldCurrency],
    created == null ? null : DateTime.fromMillisecondsSinceEpoch(created),);
}

Map<String, dynamic> _CategoryToMap(AppCategory cat) {
  return {fldName: cat.name, fldColorHex: cat.colorHex, fldType: cat.categoryType.id};
}

Map<String, dynamic> _UserToMap(User user, {int color}) {
  return {fldUuid: user.uuid, fldEmail: user.email, fldDisplayName: user.displayName, fldPhotoUrl: user.photoUrl, fldColor: color != null ? color : user.color};
}

Map<String, dynamic> _BudgetToMap(Budget budget) {
  return {
    fldCategoryId: budget.categoryId,
    fldAmount: budget.budgetPerMonth,
    fldStart: budget.budgetStart.millisecondsSinceEpoch,
    fldEnd: budget.budgetEnd != null ? budget.budgetEnd.millisecondsSinceEpoch : null};
}

Budget _snapshotToBudget(DocumentSnapshot snapshot) {
  return Budget(
      _toId(snapshot),
      snapshot.data[fldCategoryId],
      snapshot.data[fldAmount] == null ? null : snapshot.data[fldAmount] * 1.0,
      snapshot.data[fldStart] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldStart]),
      snapshot.data[fldEnd] != null ? DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldEnd]) : null);
}


AppCategory _snapshotToCategory(DocumentSnapshot snapshot) {
  return AppCategory(
      _toId(snapshot),
      snapshot.data[fldName],
      snapshot.data[fldColorHex],
      CategoryType.all[snapshot.data[fldType] == null ? 0 : snapshot.data[fldType]],
      group: snapshot.data[fldGroup] != null ? int.parse(snapshot.data[fldGroup]) : null
  );
//      snapshot.data[fldBalance] != null ? double.parse("${snapshot.data[fldBalance]}") : null);
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {fldDateTime: trans.dateTime.millisecondsSinceEpoch, fldAccountId: trans.accountId, fldCategoryId: trans.categoryId, fldAmount: trans.amount, fldDesc: trans.desc, fldType: trans.type.id, fldUuid: trans.userUid};
}

AppTransaction _snapshotToTransaction(DocumentSnapshot snapshot) {
  return AppTransaction(
      _toId(snapshot),
      snapshot.data[fldDateTime] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
      snapshot.data[fldAccountId],
      snapshot.data[fldCategoryId],
      snapshot.data[fldAmount] == null ? null : double.parse("${snapshot.data[fldAmount]}"),
      snapshot.data[fldDesc],
      snapshot.data[fldType] == null ? null : TransactionType.all[snapshot.data[fldType]],
      snapshot.data[fldUuid]);
}

Map<String, dynamic> _TransferToMap(Transfer transfer) {
  return {
    fldTransferId: transfer.id,
    fldTransferFrom: transfer.fromAccount,
    fldTransferTo: transfer.toAccount,
    fldAmount: transfer.amount,
    fldDateTime: transfer.transferDate.millisecondsSinceEpoch,
    fldUuid: transfer.userUuid
  };
}

Transfer _snapshotToTransfer(DocumentSnapshot snapshot) {
  return Transfer(
      _toId(snapshot),
      snapshot.data[fldTransferFrom],
      snapshot.data[fldTransferTo],
      snapshot.data[fldAmount],
      snapshot.data[fldDateTime] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
      snapshot.data[fldUuid]
  );
}

Map<String, dynamic> _DischargeOfLiabilityToMap(DischargeOfLiability discharge) {
  return {
    fldDateTime: discharge.dateTime.millisecondsSinceEpoch,
    fldAccountId: discharge.accountId,
    fldLiabilityId: discharge.liabilityId,
    fldCategoryId: discharge.categoryId,
    fldAmount: discharge.amount,
    fldUuid: discharge.userUid
  };
}

DischargeOfLiability _snapshotToDischargeOfLiability(DocumentSnapshot snapshot) {
  return DischargeOfLiability(
    _toId(snapshot),
    snapshot.data[fldDateTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
    snapshot.data[fldLiabilityId],
    snapshot.data[fldAccountId],
    snapshot.data[fldCategoryId],
    snapshot.data[fldAmount],
    snapshot.data[fldUuid]
  );
}

int _toId(DocumentSnapshot snapshot) {
  return int.parse(snapshot.documentID);
}

Future<void> _onAccountAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onAccountRemoved(document, batchIdentifier);
  }
  return db.insertAccount(_snapshotToAccount(document), batchIdentifier: batchIdentifier);
}

Future<void> _onAccountChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onAccountRemoved(document, batchIdentifier);
  }
  return db.updateAccount(_snapshotToAccount(document), batchIdentifier: batchIdentifier);
}

Future<void> _onAccountRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteAccount(_toId(document), batchIdentifier: batchIdentifier);
}

Future<void> _onCategoryAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onCategoryRemoved(document, batchIdentifier);
  }
  return db.insertCategory(_snapshotToCategory(document), batchIdentifier: batchIdentifier);
}

Future<void> _onCategoryChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onCategoryRemoved(document, batchIdentifier);
  }

  return db.updateCategory(_snapshotToCategory(document), batchIdentifier: batchIdentifier);
}

Future<void> _onCategoryRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteCategory(_toId(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransactionAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onTransactionRemoved(document, batchIdentifier);
  }

  return db.insertTransaction(_snapshotToTransaction(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransactionChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onTransactionRemoved(document, batchIdentifier);
  }
  return db.updateTransaction(_snapshotToTransaction(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransactionRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteTransaction(_toId(document), batchIdentifier: batchIdentifier);
}

Future<void> _onUserAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onUserRemoved(document, batchIdentifier);
  }
  return db.insertUser(snapshotToUser(document), batchIdentifier: batchIdentifier);
}

Future<void> _onUserChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onUserRemoved(document, batchIdentifier);
  }
  return db.updateUser(snapshotToUser(document), batchIdentifier: batchIdentifier);
}

Future<void> _onUserRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteUser(document.data[fldUuid], batchIdentifier: batchIdentifier);
}

Future<void> _onBudgetAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onBudgetRemoved(document, batchIdentifier);
  }
  return db.insertBudget(_snapshotToBudget(document), batchIdentifier: batchIdentifier);
}

Future<void> _onBudgetChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    final id = _toId(document);

    if(id != null) return _onBudgetRemoved(document, batchIdentifier);
  }
  return db.updateBudget(_snapshotToBudget(document), batchIdentifier: batchIdentifier);
}

Future<void> _onBudgetRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteBudget(_toId(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransferAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onTransferRemoved(document, batchIdentifier);
  }

  return db.insertTransfer(_snapshotToTransfer(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransferChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onTransferRemoved(document, batchIdentifier);
  }

  return db.updateTransfer(_snapshotToTransfer(document), batchIdentifier: batchIdentifier);
}

Future<void> _onTransferRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteTransfer(_toId(document), batchIdentifier: batchIdentifier);
}

Future<void> _onDischargeOfLiabilityAdded(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onDischargeOfLiabilityRemoved(document, batchIdentifier);
  }

  return db.insertDischargeOfLiability(_snapshotToDischargeOfLiability(document), batchIdentifier: batchIdentifier);
}

Future<void> _onDischargeOfLiabilityChanged(DocumentSnapshot document, String batchIdentifier) {
  if(document.data == null) {
    var id = _toId(document);

    if(id != null) return _onDischargeOfLiabilityRemoved(document, batchIdentifier);
  }

  return db.updateDischargeOfLiability(_snapshotToDischargeOfLiability(document), batchIdentifier: batchIdentifier);
}

Future<void> _onDischargeOfLiabilityRemoved(DocumentSnapshot document, String batchIdentifier) {
  return db.deleteDischargeOfLiability(_toId(document));
}
// ####################################################################################################
// Account
Lock _lock = Lock();

Future<bool> addAccount(Account acc) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblAccount).document("${acc.id}").setData(_AccountToMap(acc));
    return true;
  });
}

Future<bool> updateAccount(Account acc) async {
  return addAccount(acc);
}

Future<bool> deleteAccount(Account acc) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblAccount).document("${acc.id}").delete();
    return true;
  });
}

// ####################################################################################################
// Transaction
Future<bool> addTransaction(AppTransaction transaction) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblTransaction).document("${transaction.id}").setData(_TransactionToMap(transaction));
    return true;
  });
}

Future<bool> updateTransaction(AppTransaction trans) async {
  return addTransaction(trans);
}

Future<bool> deleteTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblTransaction).document("${trans.id}").delete();
    return true;
  });
}

Future<bool> deleteAllTransaction(List<AppTransaction> transactions) {
  return _lock.synchronized(() async {
    for(AppTransaction transaction in transactions) {
      await _firestore.collection(tblTransaction).document("${transaction.id}").delete();
    }

    return true;
  });
}

// ####################################################################################################
// Category
Future<bool> addCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblCategory).document("${cat.id}").setData(_CategoryToMap(cat));

    return true;
  });
}

Future<bool> updateCategory(AppCategory cat) {
  return addCategory(cat);
}

Future<bool> deleteCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblCategory).document("${cat.id}").delete();

    return true;
  });
}

// ####################################################################################################
// User
Future<bool> addUser(User user, {int color}) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblUser).document(user.uuid).setData(_UserToMap(user, color: color));
    return true;
  });
}

Future<bool> updateUser(User user) {
  return addUser(user);
}

Future<bool> deleteUser(User user) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblUser).document(user.uuid).delete();
    return true;
  });
}

// ####################################################################################################
// Budget
Future<bool> addBudget(Budget budget) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblBudget).document("${budget.id}").setData(_BudgetToMap(budget));
    return true;
  });
}

Future<bool> updateBudget(Budget budget) {
  return addBudget(budget);
}

Future<bool> deleteBudget(int id) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblBudget).document("$id").delete();
    return true;
  });
}

// ####################################################################################################
// Transfer

Future<bool> addTransfer(Transfer transfer) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblTransfer).document("${transfer.id}").setData(_TransferToMap(transfer));
    return true;
  });
}

Future<bool> updateTransfer(Transfer transfer) {
  return addTransfer(transfer);
}

Future<bool> deleteAllTransfer(List<Transfer> transfers) {
  return _lock.synchronized(() async {
    for(Transfer transfer in transfers) {
      await _firestore.collection(tblTransfer).document("${transfer.id}").delete();
    }

    return true;
  });
}

// ####################################################################################################
// Transfer

Future<bool> addDischargeOfLiability(DischargeOfLiability discharge) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblDischargeOfLiability).document("${discharge.id}").setData(_DischargeOfLiabilityToMap(discharge));
    return true;
  });
}

Future<bool> update(DischargeOfLiability discharge) {
  return addDischargeOfLiability(discharge);
}

Future<bool> deleteDischargeOfLiability(DischargeOfLiability discharge) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblDischargeOfLiability).document("${discharge.id}").delete();
  });
}

// ####################################################################################################
// other reference task
Future<bool> removeReference() async {
  return _lock.synchronized(() async {
    _unsubscribe();
    _isDbSetup = false;
  });
}

void _unsubscribe() {
  if(subs != null) subs.forEach((key, value) async {
    await value.cancel();
  });

  subs = {};
}



