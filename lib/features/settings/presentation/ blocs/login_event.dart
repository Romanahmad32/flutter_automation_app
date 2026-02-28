import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable{

}
class LoginSubmitted extends LoginEvent{
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
