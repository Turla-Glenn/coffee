// drawer_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:coffee/update_delete_screen.dart';

class DrawerScreen extends StatelessWidget {
  final VoidCallback onMenuRefresh;

  const DrawerScreen({Key? key, required this.onMenuRefresh}) : super(key: key);

  Future<void> _addMenuItem(
      String name, String description, double price, String imagePath, BuildContext context) async {
    Map<String, String> data = {
      'name': name,
      'description': description,
      'price': price.toString(),
    };

    var uri = Uri.parse('http://192.168.100.155/flutter/create_menu.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(data);

    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu item added successfully'),
        ),
      );
      onMenuRefresh(); // Trigger menu refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add menu item'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown[400],
            ),
            child: Text(
              'Coffee Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Add Menu Item'),
            onTap: () {
              Navigator.pop(context);
              _showAddMenuItemDialog(context);
            },
          ),
          ListTile(
            title: Text('Update and Delete'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateDeleteScreen(onMenuRefresh: onMenuRefresh)),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMenuItemDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    final picker = ImagePicker();
    XFile? pickedFile;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Menu Item'),
              content: SingleChildScrollView(
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
                        final XFile? file =
                        await picker.pickImage(source: ImageSource.gallery);
                        if (file != null) {
                          setState(() {
                            pickedFile = file;
                          });
                        }
                      },
                      child: Text('Pick Image'),
                    ),
                    pickedFile != null
                        ? Image.file(File(pickedFile!.path))
                        : SizedBox(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String name = nameController.text;
                    String description = descriptionController.text;
                    double price =
                        double.tryParse(priceController.text) ?? 0.0;
                    String imagePath = pickedFile?.path ?? '';

                    if (name.isNotEmpty &&
                        description.isNotEmpty &&
                        price > 0 &&
                        imagePath.isNotEmpty) {
                      _addMenuItem(
                          name, description, price, imagePath, context);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields'),
                        ),
                      );
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
