import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'commonbg.dart'; // Your background widget
import 'pokemon_details.dart';
import 'searchPage.dart';  // adjust path if needed

import 'dart:convert';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> {
  int currentIndex = 0;
  List<Map<String, dynamic>> pokemons = [];
  int offset = 0;
  final int limit = 50;
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPokemons();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        fetchPokemons();
      }
    });
  }

  Future<void> fetchPokemons() async {
  if (isLoading) return;

  setState(() => isLoading = true);

  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List results = data['results'];

    if (results.isEmpty) {
      setState(() => isLoading = false);
      return; // No more Pokémon to load
    }

    for (var pokemon in results) {
      final detailRes = await http.get(Uri.parse(pokemon['url']));
      if (detailRes.statusCode == 200) {
        final detailData = json.decode(detailRes.body);
        pokemons.add(detailData);
      }
    }

    offset += limit;
  }

  setState(() => isLoading = false);
}
 

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildHomeList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: pokemons.length + 1,
      itemBuilder: (context, index) {
  if (index == pokemons.length) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : const SizedBox.shrink();
  }
  final pokemon = pokemons[index];
  final imageUrl = pokemon['sprites']?['other']?['official-artwork']?['front_default'];
final name = pokemon['name'] ?? 'Unknown';

return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetails(pokemon: {
          'name': name,
          'image': imageUrl,
          'stats': pokemon['stats'] ?? [],
        }),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.all(8),
    height: 150,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.teal, Color.fromARGB(255, 57, 98, 93)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        if (imageUrl != null)
          Image.network(imageUrl, height: 100, fit: BoxFit.contain)
        else
          const Icon(Icons.image_not_supported,
              size: 100, color: Colors.white54),
        const SizedBox(width: 20),
        Text(name.toString().toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    ),
  ),
);
      }

    );
  }

  @override
  Widget build(BuildContext context) {
    // Select the child widget based on currentIndex
    Widget currentPage;
    switch (currentIndex) {
      case 0:
        currentPage = buildHomeList();
        break;
      case 1:
        currentPage = const Search();  // Your Search widget imported above
        break;
      case 2:
        currentPage = const Center(child: Text('Profile Page')); // Placeholder
        break;
      default:
        currentPage = buildHomeList();
    }

    return bg(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      child: currentPage,
    );
  }
}