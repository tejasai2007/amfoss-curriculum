import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'register.dart';
import "commonbg.dart";
import 'package:hive_flutter/hive_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogin() async {
    final username = usernameController.text;
    final password = passwordController.text;

    print('Username: $username, Password: $password');

    final url = Uri.parse('http://192.168.57.54:5000/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode ==200) {
      print('Success: ${response.body}');
      final userBox = Hive.box('userBox');
      userBox.put('username', username);

      Navigator.push(context,
  MaterialPageRoute(builder: (context) => Home()),
);
      // Navigate to another page or show success
    } else {
      print('Login failed: ${response.body}');
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return bg(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 50),
            ),
            Align(
              alignment: const Alignment(0, -0.5),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 74, 150, 133),
                  borderRadius: BorderRadius.circular(25),
                ),
                height: 400,
                width: 400,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(hintText: 'Username'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(hintText: 'Password'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: handleLogin,
                      child: const Text('Login'),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.push(context,
  MaterialPageRoute(builder: (context) => Register()),
);
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
