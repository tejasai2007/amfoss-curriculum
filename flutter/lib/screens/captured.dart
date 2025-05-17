import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'commonbg.dart';
import 'trade.dart';
import 'pokemon_details.dart';
import 'dart:convert';

class CapturedPokemonsPage extends StatefulWidget {
  const CapturedPokemonsPage({super.key});

  @override
  State<CapturedPokemonsPage> createState() => _CapturedPokemonsPageState();
}

class _CapturedPokemonsPageState extends State<CapturedPokemonsPage> {
  List<Map<String, dynamic>> pokemons = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCapturedPokemons();
  }

  Future<void> fetchCapturedPokemons() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final box = Hive.box('userBox');
      final username = box.get('username') ?? 'default_username';

      final response = await http.post(
        Uri.parse('http://192.168.57.54:5000/captured'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List captured = data['captured'] ?? [];

        List<Map<String, dynamic>> detailedPokemons = [];

        for (var pokeEntry in captured) {
          final name = pokeEntry['pokemon'];
          final detailRes = await http.get(
            Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
          );

          if (detailRes.statusCode == 200) {
            final detailData = json.decode(detailRes.body);
            detailedPokemons.add(detailData);
          }
        }

        setState(() {
          pokemons = detailedPokemons;
        });
      } else {
        setState(() {
          error = 'Failed to fetch captured Pokémon (status code ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching captured Pokémon: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildPokemonList() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (error != null) {
    return Center(child: Text(error!));
  }

  if (pokemons.isEmpty) {
    return const Center(child: Text('No captured Pokémon found.'));
  }

  return ListView.builder(
    itemCount: pokemons.length,
    itemBuilder: (context, index) {
      final pokemon = pokemons[index];
      final name = pokemon['name'] ?? 'Unknown';
      final imageUrl = pokemon['sprites']?['other']?['official-artwork']?['front_default'];

      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PokemonDetails(
                pokemon: {
                  'name': name,
                  'image': imageUrl,
                  'stats': pokemon['stats'] ?? [],
                  // add other needed details here
                },
              ),
            ),
          );
        },
        child: ListTile(
          leading: imageUrl != null
              ? Image.network(imageUrl, width: 60, height: 60)
              : const Icon(Icons.image_not_supported),
          title: Text(name.toString().toUpperCase()),
        
        ),
      );
    },
  );
}




@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Captured Pokémon"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Trade()));
          },
          child: const Text("Trade"),
        )
      ],
    ),
    body: bg(
      child: buildPokemonList(),
    ),
  );
}

}

  
