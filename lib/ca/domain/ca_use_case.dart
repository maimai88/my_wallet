import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ca/domain/ca_default_response.dart';
export 'package:my_wallet/ca/domain/ca_default_response.dart';

import 'package:rxdart/rxdart.dart';
export 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart';
export 'package:flutter/foundation.dart';

import 'package:flutter/scheduler.dart';
import 'dart:async';

/// Free flow, use your repo as you wish in your own usecase, and return data as you need
class CleanArchitectureUseCase<T extends CleanArchitectureRepository> {
  final T repo;

  CleanArchitectureUseCase(this.repo);
  Map<String, StreamSubscription> _streamSubscription = {};

  void execute<T>(Future<T> task, onNext<T> next, onError error) {
    if(task != null) {
    final subscriptionKey = DateTime.now().millisecondsSinceEpoch.toRadixString(12);
      StreamSubscription subscription = Observable.fromFuture(task).listen((data) => next(data), onError: (e, stacktrace) {
        debugPrintStack(label: "Task failed", maxFrames: 30);

        if(error != null) {
          if(e is Exception) {
            error(e);
          } else {
            error(Exception(e.toString()));
          }
        }
      }, onDone: () => clearSubscription(subscriptionKey));

      _streamSubscription.putIfAbsent(subscriptionKey, () => subscription);
    } else {
      debugPrint("task is null: $task ${this.toString()}");
    }
  }

  void clearSubscription(String key) {
    print("clear subscription $key");
    StreamSubscription subscription = _streamSubscription.remove(key);

    if(subscription != null) {
      subscription.cancel();
    }
  }
}
