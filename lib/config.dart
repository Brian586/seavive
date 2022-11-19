import 'package:flutter/material.dart';
import 'package:seavive/models/account.dart';

class SeaVive with ChangeNotifier {
  Account? _account;
  String googleMapsAPIKey = "AIzaSyDRNAIsgCHZwvTjGEoJFBwVAM9V4Z3rh4g";

  Account get account => _account!;

  switchUser(Account acc) {
    _account = acc;

    notifyListeners();
  }
}
