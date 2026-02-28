import 'package:automation_app/core/general_classes/failures/failure.dart';
import 'package:automation_app/core/general_classes/usecases/use_case.dart';

abstract class WordAutomationRepository {
  Future<Either<Failure, String>> fillOutTemplate(
    String path,
    Map<String, String> values,
  );
}
