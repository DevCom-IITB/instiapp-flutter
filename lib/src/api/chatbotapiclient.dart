import 'dart:async';
import 'package:InstiApp/src/api/response/chat_bot_response.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ChatBotApi {
  ChatBotApi(this._dio);
  String? baseUrl = "https://gymkhana.iitb.ac.in/chatbot/";
  final Dio _dio;

  Future<ChatBotResponse> getAnswers(
    String query,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'data': query};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(_dio.options, '/',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final val = json.decode(_result.data!);
    final value = ChatBotResponse.fromJson(val);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
