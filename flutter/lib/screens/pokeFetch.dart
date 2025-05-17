import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch Pokémon list with images
Future<List<Map<String, dynamic>>> fetchPokemonList() async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1300'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List results = data['results'];

    // Only return name (and optionally URL)
    return results.map<Map<String, dynamic>>((pokemon) => {
      'name': pokemon['name'],
    }).toList();
  } else {
    throw Exception('Failed to load Pokémon');
  }
}
