import 'package:flutter/material.dart';

class Item {
  Item(this.name, {this.category = 'Food', this.quantity = 1, this.note = ''});

  String name;
  bool bought = false;
  String category;
  int quantity;
  String note;
}

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = <Item>[
    Item('Milk', category: 'Drinks', quantity: 2),
    Item('Bread', category: 'Food'),
    Item('Rice', category: 'Food'),
  ];

  final controller = TextEditingController();
  String selectedCategory = 'Food';
  String filter = 'All';

  static const categories = ['Food', 'Drinks', 'Home'];

  List<Item> get visibleItems {
    var list = items.where((item) {
      if (filter == 'To buy' && item.bought) return false;
      if (filter == 'Bought' && !item.bought) return false;
      return true;
    }).toList();

    if (filter == 'All') {
      final left = list.where((i) => !i.bought).toList();
      final done = list.where((i) => i.bought).toList();
      list = [...left, ...done];
    }
    return list;
  }

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Type an item first')),
        );
      return;
    }

    final normalized = text.toLowerCase();
    final existing = items.firstWhere(
          (i) => i.name.trim().toLowerCase() == normalized,
      orElse: () => Item(''),
    );

    if (existing.name.isNotEmpty) {
      setState(() => existing.quantity += 1);
      final display = existing.name;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$display is already on the list: now ×${existing.quantity}'),
          ),
        );
    } else {
      setState(() => items.add(Item(text, category: selectedCategory)));
    }
    controller.clear();
  }

  void deleteItem(Item item) {
    final index = items.indexOf(item);
    if (index == -1) return;
    final removed = items[index];

    setState(() => items.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() => items.insert(index, removed));
            },
          ),
        ),
      );
  }

  void changeQuantity(Item item, int delta) {
    setState(() {
      final next = item.quantity + delta;
      if (next < 1) return;
      item.quantity = next;
    });
  }

  void openDetails(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsScreen(item: item)),
    );
    setState(() {});
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Drinks':
        return Icons.local_drink;
      case 'Home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  Color categoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Drinks':
        return Colors.blue;
      case 'Home':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showing = visibleItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear bought items',
            onPressed: () {
              final bought = items.where((i) => i.bought).toList();
              if (bought.isEmpty) return;
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear bought items?'),
                  content: Text('Remove ${bought.length} bought item(s)?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        setState(() => items.removeWhere((i) => i.bought));
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'New item',
                          prefixIcon: Icon(Icons.add_shopping_cart),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: addItem,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Category:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: categories
                            .map(
                              (c) => ButtonSegment(
                            value: c,
                            label: Text(c),
                            icon: Icon(categoryIcon(c), size: 16),
                          ),
                        )
                            .toList(),
                        selected: {selectedCategory},
                        onSelectionChanged: (s) {
                          setState(() => selectedCategory = s.first);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['All', 'To buy', 'Bought'].map((label) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: filter == label,
                        onSelected: (_) {
                          setState(() => filter = label);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: showing.isEmpty
                ? Center(
              child: Text(
                items.isEmpty ? 'Your list is empty' : 'Nothing here',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: showing.length,
              itemBuilder: (context, index) {
                final item = showing[index];
                return Dismissible(
                  key: ObjectKey(item),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteItem(item),
                  child: Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.bought
                            ? Icons.check_circle
                            : categoryIcon(item.category),
                        color: item.bought
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.bought
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: item.bought ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        item.note.isEmpty
                            ? item.category
                            : '${item.category} · ${item.note}',
                        style: TextStyle(
                          fontSize: 13,
                          color: categoryColor(item.category),
                        ),
                      ),
                      onTap: () {
                        setState(() => item.bought = !item.bought);
                      },
                      onLongPress: () => openDetails(item),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            onPressed: item.quantity > 1
                                ? () => changeQuantity(item, -1)
                                : null,
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            onPressed: () => changeQuantity(item, 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => deleteItem(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController noteController;
  late String category;

  static const cats = ['Food', 'Drinks', 'Home'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    category = widget.item.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void save() {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    widget.item.name = newName;
    widget.item.note = noteController.text.trim();
    widget.item.category = category;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (e.g. 1 litre bottle)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: cats.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  onSelected: (_) => setState(() => category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}