import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';




class PokemonDetails extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetails({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final List stats = pokemon['stats'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF2D3E3F),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(pokemon['name'].toString().toUpperCase()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: pokemon['image'] ?? '',
              height: 200,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 150, color: Colors.white54),
            ),
            const SizedBox(height: 20),
            Text(
              pokemon['name'].toString().toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 28),
            ),
            const SizedBox(height: 20),
            ...stats.map((stat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stat['stat']['name'].toString().toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text(stat['base_stat'].toString(),
                        style: const TextStyle(color: Colors.tealAccent, fontSize: 18)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 40),
            ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () async {
        final userBox = Hive.box('userBox');
        String username = userBox.get('username', defaultValue: '');
        print(username);
        
        final response = await http.post(
          Uri.parse('http://192.168.57.54:5000/capture'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'pokemon': pokemon['name'].toString().toLowerCase(),
            'details': pokemon, // Optional: send full details if needed
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pokémon Captured!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Capture failed: ${response.statusCode}')),
          );
        }
      },
      child: const Text('Capture Pokémon', style: TextStyle(fontSize: 18)),
    )
          ],
        ),
      ),
    );
  }
}
