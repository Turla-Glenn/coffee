// drawer_and_update_delete_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DrawerAndUpdateDeleteScreen extends StatelessWidget {
  final VoidCallback onMenuRefresh;

  const DrawerAndUpdateDeleteScreen({Key? key, required this.onMenuRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update and Delete Menu Items'),
      ),
      body: UpdateDeleteBody(onMenuRefresh: onMenuRefresh),
    );
  }
}

class UpdateDeleteBody extends StatefulWidget {
  final VoidCallback onMenuRefresh;

  const UpdateDeleteBody({Key? key, required this.onMenuRefresh}) : super(key: key);

  @override
  _UpdateDeleteBodyState createState() => _UpdateDeleteBodyState();
}

class _UpdateDeleteBodyState extends State<UpdateDeleteBody> {
  Future<List<dynamic>?> fetchMenuItems() async {
    final response = await http.get(Uri.parse('http://192.168.100.155/flutter/fetch_menu.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: fetchMenuItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: Failed to load menu items'));
        } else {
          List<dynamic> menuItems = snapshot.data!;
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              var item = menuItems[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editMenuItem(context, item);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteMenuItem(context, item);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  void _editMenuItem(BuildContext context, dynamic item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMenuItemScreen(item: item)),
    );

    if (result == true) {
      widget.onMenuRefresh();
    }
  }

  void _deleteMenuItem(BuildContext context, dynamic item) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this menu item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://192.168.100.155/flutter/delete_menu.php'),
                  body: {'id': item['id'].toString()},
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menu item deleted successfully'),
                    ),
                  );

                  widget.onMenuRefresh();
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete menu item'),
                    ),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      widget.onMenuRefresh();
    }
  }
}

class EditMenuItemScreen extends StatefulWidget {
  final dynamic item;

  const EditMenuItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _EditMenuItemScreenState createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final picker = ImagePicker();
  XFile? pickedFile;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item['name'];
    descriptionController.text = widget.item['description'];
    priceController.text = widget.item['price'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    pickedFile = file;
                  });
                }
              },
              child: Text('Change Image'),
            ),
            pickedFile != null ? Image.file(File(pickedFile!.path)) : SizedBox(),
            ElevatedButton(
              onPressed: () {
                _updateMenuItem();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateMenuItem() async {
    String name = nameController.text;
    String description = descriptionController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;

    final response = await http.post(
      Uri.parse('http://192.168.100.155/flutter/update_menu.php'),
      body: {
        'id': widget.item['id'].toString(),
        'name': name,
        'description': description,
        'price': price.toString(),
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu item updated successfully'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update menu item'),
        ),
      );

      Navigator.pop(context, false);
    }
  }
}
