import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarlenmodas/core/consts.dart';
import 'package:jarlenmodas/core/error_helper.dart';
import 'package:jarlenmodas/services/user/user_service.dart';
import 'package:jarlenmodas/utils/auth_exception.dart';
import 'package:jarlenmodas/utils/loading_util.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  final _userService = UserService();

  final FormGroup form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(validators: [Validators.required]),
  });

  Future<void> _login() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    final email = form.control('email').value.trim();
    final password = form.control('password').value.trim();

    LoadingUtil.showLoading(context);
    try {
      final user = await _userService.login(email, password);

      if (user == null) {
        if (mounted) {
          ErroHelper.showMessage(
            context,
            "E-mail ou senha inválidos.",
            isError: true,
          );
        }
        return;
      }

      if (mounted) {
        context.goNamed('home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        LoadingUtil.hideLoading(context);
        ErroHelper.showMessage(context, e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        LoadingUtil.hideLoading(context);
        ErroHelper.showMessage(
          context,
          "Erro inesperado: ${e.toString()}",
          isError: true,
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConsts.pathBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppConsts.borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    AppConsts.pathLogoEnterprise,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 24.0),
                  ReactiveForm(
                    formGroup: form,
                    child: Column(
                      children: <Widget>[
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'E-mail é obrigatório',
                            ValidationMessage.email: (error) =>
                                'Informe um e-mail válido',
                          },
                        ),
                        const SizedBox(height: 16.0),
                        ReactiveTextField<String>(
                          formControlName: 'password',
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'Senha é obrigatória',
                          },
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
