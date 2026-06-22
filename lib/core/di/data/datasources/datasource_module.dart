import 'package:automation_app/core/theme/data/local_theme_preferences_datasource.dart';
import 'package:automation_app/features/form_template_setup/data/datasources/local_form_template_datasource.dart';
import 'package:automation_app/features/mandanten/data/datasources/local_mandant_datasource.dart';
import 'package:automation_app/features/settings/data/datasources/local_kanzlei_settings_datasource.dart';
import 'package:automation_app/features/zentralruf_reply/data/datasources/local_vorgaenge_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

@module
abstract class DatasourceModule {
  @preResolve
  Future<LocalThemePreferencesDatasource> get localThemePreferencesDatasource =>
      LocalThemePreferencesDatasourceImpl.create(PathProviderWindows());

  @preResolve
  Future<LocalFormTemplateDatasource> get localFormTemplateDatasource =>
      LocalFormTemplateDatasourceImpl.create(PathProviderWindows());

  @preResolve
  Future<LocalKanzleiSettingsDatasource> get localKanzleiSettingsDatasource =>
      LocalKanzleiSettingsDatasourceImpl.create(PathProviderWindows());

  @preResolve
  Future<LocalVorgaengeDatasource> get localVorgaengeDatasource =>
      LocalVorgaengeDatasourceImpl.create(PathProviderWindows());

  @preResolve
  Future<LocalMandantDatasource> get localMandantDatasource =>
      LocalMandantDatasourceImpl.create(PathProviderWindows());
}
