import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import "commonbg.dart";

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleRegister() async {
    final username = usernameController.text;
    final password = passwordController.text;

    print('Username: $username, Password: $password');

    final url = Uri.parse('http://192.168.57.54:5000/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode ==200) {
      print('Success: ${response.body}');
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
              'Register',
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
                      onPressed: handleRegister,
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
