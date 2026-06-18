import 'package:automation_app/core/general_classes/failures/failure.dart';
import 'package:automation_app/core/general_classes/usecases/use_case.dart';
import 'package:automation_app/features/settings/data/datasources/local_kanzlei_settings_datasource.dart';
import 'package:automation_app/features/settings/domain/entities/kanzlei_settings.dart';
import 'package:automation_app/features/settings/domain/repositories/kanzlei_settings_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: KanzleiSettingsRepository)
class KanzleiSettingsRepositoryImpl implements KanzleiSettingsRepository {
  final LocalKanzleiSettingsDatasource _localDatasource;

  KanzleiSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<Either<Failure, KanzleiSettings>> getSettings() async {
    try {
      final settings = await _localDatasource.loadSettings();
      return Right(settings);
    } catch (e) {
      return Left(LocalFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, KanzleiSettings>> saveSettings(
      KanzleiSettings settings,) async {
    try {
      final saved = await _localDatasource.saveSettings(settings);
      return Right(saved);
    } catch (e) {
      return Left(LocalFailure(message: e.toString()));
    }
  }
}
