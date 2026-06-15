
import 'package:agendapf/presentation/views/calendar.dart';
import 'package:agendapf/presentation/views/register.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height / 100;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image(image: AssetImage("images/ifpr_logo.png")),
            ),
          ),
          Container(
            height: size * 80,
            width: size * 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login Usuário",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),

                  Row(
                    children: [
                      Text("Não tem uma conta?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    "E-mail:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  ),

                  SizedBox(height: 20),

                  Text("Senha:", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      suffixIcon: GestureDetector(
                        child: Icon(
                          _showPassword == false
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _showPassword == false ? true : false,
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CalendarPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
