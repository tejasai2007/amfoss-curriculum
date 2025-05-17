import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'pokemon_details.dart'; // <-- Add this if in separate file

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  List<Map<String, dynamic>> filteredPokemons = [];
  String query = '';
  bool isLoading = false;

  Future<Map<String, dynamic>?> fetchPokemonByName(String name) async {
    final url = 'https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}';
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return {
          'name': data['name'],
          'image': data['sprites']['other']['official-artwork']['front_default'],
          'stats': data['stats'],
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching Pokémon: $e');
      return null;
    }
  }

  void updateSearch(String input) async {

    setState(() {
      query = input;
      filteredPokemons = [];
      isLoading = true;
    });

    if (input.length < 2) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final data = await fetchPokemonByName(input);
    setState(() {
      filteredPokemons = data != null ? [data] : [];
      isLoading = false;
    });
  }

  void openDetails(Map<String, dynamic> pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetails(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: updateSearch,
            decoration: InputDecoration(
              hintText: 'Search Pokémon...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredPokemons.isEmpty
                  ? const Center(child: Text('No Pokémon found'))
                  : ListView.builder(
                      itemCount: filteredPokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = filteredPokemons[index];
                        return ListTile(
                          title: Text(pokemon['name'].toString().toUpperCase()),
                          onTap: () => openDetails(pokemon),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
