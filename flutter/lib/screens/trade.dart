import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'captured.dart';
import 'register.dart';
import "commonbg.dart";
import 'package:hive_flutter/hive_flutter.dart';

class Trade extends StatefulWidget {
  const Trade({super.key});

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

void handleTrade() async {
  final box = Hive.box('userBox');
  final fromUser = box.get('username');
  final toUser = usernameController.text;
  final pokemonName = passwordController.text;

  final url = Uri.parse('http://192.168.57.54:5000/trade');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'from': fromUser,
      'to': toUser,
      'pokemon': pokemonName,
    }),
  );

  if (response.statusCode == 200) {
    print('Trade successful: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trade successful!')));
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CapturedPokemonsPage()));
  } else {
    print('Trade failed: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trade failed')));
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
                        decoration: const InputDecoration(hintText: 'pokemon name'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: handleTrade,
                      child: const Text('Trade'),
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
