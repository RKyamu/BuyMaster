import 'package:flutter/material.dart';
import 'package:flutter_buymaster_user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_buymaster_user_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_buymaster_user_app/data/model/response/base/api_response.dart';
import 'package:flutter_buymaster_user_app/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  SplashRepo({@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getConfig() async {
    try {
      var token = sharedPreferences.getString(AppConstants.TOKEN);
      var url = token != null ? 1 : "";
      final response = await dioClient.get("${AppConstants.CONFIG_URI}$url");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  void initSharedData() async {
    if (!sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      sharedPreferences.setStringList(AppConstants.CART_LIST, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.SEARCH_ADDRESS)) {
      sharedPreferences.setStringList(AppConstants.SEARCH_ADDRESS, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.INTRO)) {
      sharedPreferences.setBool(AppConstants.INTRO, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.CURRENCY)) {
      sharedPreferences.setString(AppConstants.CURRENCY, '');
    }
  }

  String getCurrency() {
    return sharedPreferences.getString(AppConstants.CURRENCY) ?? '';
  }

  void setCurrency(String currencyCode) {
    sharedPreferences.setString(AppConstants.CURRENCY, currencyCode);
  }

  void disableIntro() {
    sharedPreferences.setBool(AppConstants.INTRO, false);
  }

  bool showIntro() {
    return sharedPreferences.getBool(AppConstants.INTRO);
  }
}
