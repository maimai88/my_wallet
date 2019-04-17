import 'package:my_wallet/data/data.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

export 'package:synchronized/synchronized.dart';
export 'package:my_wallet/data/data.dart';
export 'package:flutter/services.dart';

const tblAccount = "Account";
const tblTransaction = "Transaction";
const tblCategory = "Category";
const tblUser = "User";
const tblBudget = "Budget";
const tblTransfer = "Transfer";
const tblDischargeOfLiability = "DischargeOfLiability";

const fldName = "name";
const fldType = "type";
const fldGroup = "group";
const fldInitlaBalance = "initialBalance";
const fldCreated = "created";
const fldCurrency = "currency";
const fldBalance = "balance";
const fldSpent = "spent";
const fldEarn = "earn";
const fldTransactionType = "transactionType";
const fldColorHex = "colorHex";
const fldDateTime = "dateTime";
const fldAccountId = "accountId";
const fldCategoryId = "categoryId";
const fldAmount = "amount";
const fldDesc = "desc";
const fldEmail = "email";
const fldDisplayName = "displayName";
const fldPhotoUrl = "photoUrl";
const fldUuid = "uuid";
const fldColor = "color";
const fldStart = "start";
const fldEnd = "end";
const fldEmailVerified = "emailVerified";
const fldTransferId = "transferId";
const fldTransferFrom = "fromAccount";
const fldTransferTo = "toAccount";
const fldLiabilityId = "liabilityId";

User snapshotToUser(DocumentSnapshot snapshot) {
  return User(snapshot.data[fldUuid], snapshot.data[fldEmail], snapshot.data[fldDisplayName], snapshot.data[fldPhotoUrl], snapshot.data[fldColor], snapshot.data[fldEmailVerified]);
}

Firestore _firestore;

Future<Firestore> firestore(FirebaseApp app) async {
  if(_firestore == null) {
    _firestore = Firestore(app: app);
    _firestore.settings(timestampsInSnapshotsEnabled: true);
  }

  return _firestore;
}
