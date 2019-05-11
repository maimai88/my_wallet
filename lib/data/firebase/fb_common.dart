import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/common.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

export 'package:synchronized/synchronized.dart';
export 'package:my_wallet/data/data.dart';
export 'package:flutter/services.dart';
export 'package:my_wallet/data/common.dart';

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
