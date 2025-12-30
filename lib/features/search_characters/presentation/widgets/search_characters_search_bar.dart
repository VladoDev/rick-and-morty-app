import 'package:flutter/material.dart';

class SearchCharactersSearchBar extends StatefulWidget {
  final String initialValue;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchPressed;

  const SearchCharactersSearchBar({
    super.key,
    required this.initialValue,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSearchPressed,
  });

  @override
  State<SearchCharactersSearchBar> createState() =>
      _SearchCharactersSearchBarState();
}

class _SearchCharactersSearchBarState extends State<SearchCharactersSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SearchCharactersSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isLoading,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Search by name (e.g., Rick)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: widget.isLoading ? null : widget.onSearchPressed,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
