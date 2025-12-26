import 'package:flutter/material.dart';

class SearchCharactersPage extends StatefulWidget {
  const SearchCharactersPage({super.key});

  @override
  State<SearchCharactersPage> createState() => _SearchCharactersPageState();
}

class _SearchCharactersPageState extends State<SearchCharactersPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Search characters page"));
  }
}
