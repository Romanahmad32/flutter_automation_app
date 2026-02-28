import 'package:automation_app/core/general_classes/failures/failure.dart';
import 'package:automation_app/core/general_classes/usecases/use_case.dart';
import 'package:automation_app/features/word_automation/data/datasources/word_automation_datasource.dart';
import 'package:automation_app/features/word_automation/domain/repositories/word_automation_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: WordAutomationRepository)
class ApiWordAutomationRepository implements WordAutomationRepository {
  final WordAutomationDatasource datasource;

  ApiWordAutomationRepository(this.datasource);

  @override
  Future<Either<Failure, String>> fillOutTemplate(
    String path,
    Map<String, String> values,
  ) async {
    try {
      final result = await datasource.fillOutTemplate(path, values);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
