import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:invoiceninja_flutter/data/models/serializers.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';

class AuthRepository {
  final WebClient webClient;

  const AuthRepository({
    this.webClient = const WebClient(),
  });

  Future<LoginResponseData> login(
      {String email,
      String password,
      String url,
      String secret,
      String platform,
      String oneTimePassword}) async {
    final credentials = {
      'token_name': 'invoice-ninja-$platform-app',
      'api_secret': secret,
      'email': email,
      'password': password,
      'one_time_password': oneTimePassword,
    };

    url = formatApiUrlMachine(url) + '/login';

    return sendRequest(url: url, data: credentials);
  }

  Future<LoginResponseData> oauthLogin(
      {String token, String url, String secret, String platform}) async {
    final credentials = {
      'token_name': 'invoice-ninja-$platform-app',
      'api_secret': secret,
      'token': token,
      'provider': 'google',
    };

    url = formatApiUrlMachine(url) + '/oauth_login';

    return sendRequest(url: url, data: credentials);
  }

  Future<LoginResponseData> refresh(
      {String url, String token, String platform}) async {
    final credentials = {
      'token_name': 'invoice-ninja-$platform-app',
    };

    url = formatApiUrlMachine(url) + '/refresh';

    return sendRequest(url: url, data: credentials, token: token);
  }

  Future<LoginResponseData> sendRequest(
      {String url, dynamic data, String token}) async {
    url += '?include=tax_rates,users,custom_payment_terms&include_static=true';

    final dynamic response =
        await webClient.post(url, token ?? '', json.encode(data));

    final LoginResponse loginResponse =
        serializers.deserializeWith(LoginResponse.serializer, response);

    if (loginResponse.error != null) {
      throw loginResponse.error.message;
    }

    return loginResponse.data;
  }
}
