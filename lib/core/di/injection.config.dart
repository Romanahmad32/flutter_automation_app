// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:automation_app/core/general_classes/usecases/use_case.dart'
    as _i223;
import 'package:automation_app/core/network/network_module.dart' as _i194;
import 'package:automation_app/core/router/app_router.dart' as _i842;
import 'package:automation_app/core/theme/presentation/bloc/theme_bloc.dart'
    as _i1049;
import 'package:automation_app/features/test_feature/presentation/%20blocs/login_bloc.dart'
    as _i1017;
import 'package:automation_app/features/word_automation/data/datasources/word_automation_datasource.dart'
    as _i287;
import 'package:automation_app/features/word_automation/data/repositories/api_word_automation_repository.dart'
    as _i530;
import 'package:automation_app/features/word_automation/domain/repositories/word_automation_repository.dart'
    as _i770;
import 'package:automation_app/features/word_automation/domain/usecases/fill_out_template.dart'
    as _i649;
import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart'
    as _i115;
import 'package:automation_app/features/word_automation/presentation/blocs/edited_document_bloc.dart'
    as _i1040;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.factory<_i1040.EditedDocumentBloc>(() => _i1040.EditedDocumentBloc());
    gh.singleton<_i361.Dio>(() => networkModule.dio);
    gh.singleton<_i842.AppRouter>(() => _i842.AppRouter());
    gh.singleton<_i1049.ThemeBloc>(() => _i1049.ThemeBloc());
    gh.singleton<_i1017.LoginBloc>(() => _i1017.LoginBloc());
    gh.factory<_i287.WordAutomationDatasource>(
      () => _i287.ApiWordAutomationDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i770.WordAutomationRepository>(
      () => _i530.ApiWordAutomationRepository(
        gh<_i287.WordAutomationDatasource>(),
      ),
    );
    gh.factory<_i223.UseCase<String, _i649.FillOutTemplateParams>>(
      () => _i649.FillOutTemplate(
        repository: gh<_i770.WordAutomationRepository>(),
      ),
    );
    gh.factory<_i115.DocumentBloc>(
      () => _i115.DocumentBloc(
        gh<_i223.UseCase<String, _i649.FillOutTemplateParams>>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i194.NetworkModule {}
