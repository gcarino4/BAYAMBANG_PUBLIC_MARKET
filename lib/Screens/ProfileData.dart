import 'package:flutter/material.dart';

class ApiResponseProvider with ChangeNotifier {
  ApiResponseData? _apiResponseData;

  ApiResponseData? get apiResponseData => _apiResponseData;

  void setApiResponseData(ApiResponseData data) {
    _apiResponseData = data;
    notifyListeners();
  }
}

class ApiResponseData {
  final String userId;
  final String username;
  final String companyCode;
  final String branchCode;
  final String companyName;
  final String branchName;

  ApiResponseData({
    required this.userId,
    required this.username,
    required this.companyCode,
    required this.branchCode,
    required this.companyName,
    required this.branchName,
  });
}