import 'package:automation_app/features/test_feature/presentation/%20blocs/login_event.dart';
import 'package:automation_app/features/test_feature/presentation/%20blocs/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@singleton
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
