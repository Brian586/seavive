import 'package:flutter/material.dart';
import 'package:seavive/models/account.dart';

class SeaVive with ChangeNotifier {
  Account? _account;

  Account get account => _account!;

  switchUser(Account acc) {
    _account = acc;

    notifyListeners();
  }
}
