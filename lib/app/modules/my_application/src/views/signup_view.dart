// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../authentication/domain/user_credencial_entity.dart';
import '../authentication/presenter/controller/auth_store.dart';
import '../common/errors/errors_messagens.dart';
import '../common/messages/messages_app.dart';
import '../components/form_field_login.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _userLoginController = TextEditingController();
  final _userNameController = TextEditingController();
  final _userPasswordController = TextEditingController();
  final _userConfirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false; // Variável para controlar a exibição da senha
  bool _showConfirmPassword = false; // Variável para controlar a exibição da confirmação de senha

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final AuthStore authStore = Modular.get<AuthStore>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // authStore.userSignOut();
          Modular.to.pop();
        },
        label: const Text('Voltar'),
        // backgroundColor: Colors.black,
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.lock_person_rounded,
                      size: size.height * 0.2,
                    ),
                    SizedBox(height: size.height * 0.008),
                    const Text(
                      'My App Login - Sign Up',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: size.height * 0.04),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'E-mail do Usuário',
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      controller: _userLoginController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: size.height * 0.01),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nome do Usuário',
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ), 
                      controller: _userNameController,
                    ),
                    SizedBox(height: size.height * 0.01),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // Alternar a exibição da senha
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showPassword,
                      controller: _userPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Confirmação de Senha',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // Alternar a exibição da confirmação de senha
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showConfirmPassword,
                      controller: _userConfirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a confirmação de senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    ScopedListener<AuthStore, UserCredentialApp?>(
                      store: authStore,
                      onError: (context, error) =>
                          MessagesApp.showCustom(context, error.toString()),
                      onState: (context_, state) => Modular.to.pop(),
                      child: Container(
                        width: size.width * 0.75,
                        height: size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_userPasswordController.text.trim() !=
                                  _userConfirmPasswordController.text.trim()) {
                                MessagesApp.showCustom(
                                    context, MessagesError.passwordMismatch);
                                return;
                              }
                              authStore.userSignUp(
                                email: _userLoginController.text.trim(),
                                password: _userPasswordController.text.trim(),
                                name: _userNameController.text.trim(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            // shape: const StadiumBorder(),
                            // backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
