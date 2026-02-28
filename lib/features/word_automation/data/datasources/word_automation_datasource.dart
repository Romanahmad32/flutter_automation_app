import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class WordAutomationDatasource {
  Future<String> fillOutTemplate(String path,Map<String,String> values);
}

@Injectable(as: WordAutomationDatasource)
class ApiWordAutomationDatasource implements WordAutomationDatasource {
  final Dio _dio;

  ApiWordAutomationDatasource(this._dio);

  @override
  Future<String> fillOutTemplate(String path,Map<String,String> values) async {
    try {
      print('Sending request with values: $values');
      final response = await _dio.post(
        '/api/WordAutomation/replaced-document',
        data: {
          'filePath': path,
          'replacePatterns': values,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      final responseData = response.data as Map<String, dynamic>;
      print('Received response: $responseData');

      return responseData['outputFilePath'];
    } on DioException catch (e) {
      throw Exception('Komisch es scheint als wäre etwas schief gegangen : $e');
    }
  }
}
