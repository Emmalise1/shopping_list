import 'package:flutter/material.dart';

class Item {
  Item(this.name, {this.category = 'Other'});

  String name;
  bool bought = false;
  String category;
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
  final items = [
    Item('Milk', category: 'Food'),
    Item('Bread', category: 'Food'),
    Item('Rice', category: 'Food'),
  ];
  final controller = TextEditingController();
  String selectedCategory = 'Food';

  static const categories = ['Food', 'Home', 'Other'];

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }
    setState(() {
      items.add(Item(text, category: selectedCategory));
    });
    controller.clear();
  }

  void deleteItem(int index) {
    final removed = items[index];
    setState(() {
      items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              items.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  void editItem(int index) {
    final item = items[index];
    final editController = TextEditingController(text: item.name);
    String editCategory = item.category;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: editCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => editCategory = v);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final newName = editController.text.trim();
                    if (newName.isEmpty) return;
                    setState(() {
                      item.name = newName;
                      item.category = editCategory;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteAll() {
    if (items.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all?'),
          content: Text('Remove all ${items.length} items from the list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() => items.clear());
                Navigator.pop(context);
              },
              child: const Text('Delete all'),
            ),
          ],
        );
      },
    );
  }

  void clearBought() {
    final boughtCount = items.where((i) => i.bought).length;
    if (boughtCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bought items to clear')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear bought items?'),
          content: Text('Remove $boughtCount bought item(s)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  items.removeWhere((i) => i.bought);
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
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
      case 'Home':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget categoryChip(String category) {
    final color = categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftCount = items.where((item) => !item.bought).length;
    final boughtCount = items.length - leftCount;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text(
              '$leftCount left · $boughtCount bought',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear bought items',
            onPressed: clearBought,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete all',
            onPressed: deleteAll,
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your list is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add an item above to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => deleteItem(index),
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
                      subtitle: categoryChip(item.category),
                      onTap: () {
                        setState(() {
                          item.bought = !item.bought;
                        });
                      },
                      onLongPress: () => editItem(index),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => deleteItem(index),
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