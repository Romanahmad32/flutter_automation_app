import 'package:automation_app/core/general_classes/failures/failure.dart';
import 'package:automation_app/core/general_classes/usecases/use_case.dart';
import 'package:automation_app/features/word_automation/domain/repositories/word_automation_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: UseCase<String, FillOutTemplateParams>)
class FillOutTemplate implements UseCase<String, FillOutTemplateParams> {
  final WordAutomationRepository repository;

  FillOutTemplate({required this.repository});

  @override
  Future<Either<Failure, String>> call(FillOutTemplateParams params) async {
    return repository.fillOutTemplate(params.path, params.data);
  }
}

class FillOutTemplateParams {
  final String path;
  final Map<String, String> data;

  const FillOutTemplateParams({required this.path, required this.data});
}
