import 'package:automation_app/features/test_feature/presentation/%20blocs/login_bloc.dart';
import 'package:automation_app/features/test_feature/presentation/%20blocs/login_event.dart';
import 'package:automation_app/features/test_feature/presentation/%20blocs/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)],
    ),
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // e.g., context.go('/dashboard');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
          } else if (state is LoginFailure) {
            // Optional: Manually set a form-level error based on backend response
            form.setErrors({'backend': state.error});
          }
        },
        builder: (context, state) {
          return ReactiveForm(
            formGroup: form,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 3. Bind inputs to control names
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                      'Email must not be empty',
                      ValidationMessage.email: (error) =>
                      'Must be a valid email',
                    },
                  ),
                  const SizedBox(height: 16),

                  ReactiveTextField<String>(
                    formControlName: 'password',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                      'Password is required',
                      ValidationMessage.minLength: (error) =>
                      'Minimum 8 characters',
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Reactive button that disables when form is invalid or BLoC is loading
                  ReactiveFormConsumer(
                    builder: (context, form, child) {
                      final isLoading = state is LoginLoading;

                      return ElevatedButton(
                        onPressed: (form.valid && !isLoading)
                            ? _onSubmit
                            : null,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Submit'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSubmit() {
    final email = form.control('email').value as String;
    final password = form.control('password').value as String;

    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

}
