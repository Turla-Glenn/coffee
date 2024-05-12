import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Shop',
      theme: ThemeData(
        primaryColor: Colors.brown[100],
        appBarTheme: AppBarTheme(
          color: Colors.brown[400],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
          ),
        ),
      ),
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showRefreshIcon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        actions: [
          if (_showRefreshIcon)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {}); // Trigger manual refresh
              },
            ),
        ],
      ),
      drawer: DrawerScreen(
        onMenuRefresh: () {
          setState(() {}); // Refresh the menu screen's state
        },
      ),
      body: MenuBody(
        onScroll: () {
          setState(() {
            _showRefreshIcon = true;
          });
        },
      ),
    );
  }
}

class MenuBody extends StatefulWidget {
  final VoidCallback onScroll;

  const MenuBody({Key? key, required this.onScroll}) : super(key: key);

  @override
  _MenuBodyState createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        widget.onScroll(); // Trigger when scrolled to the bottom
      }
    });
  }

  Future<List<dynamic>?> refreshMenu() async {
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
      future: refreshMenu(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: Failed to load menu items'));
        } else {
          List<dynamic> menuItems = snapshot.data!;
          return ListView.builder(
            controller: _scrollController,
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              var item = menuItems[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['description']),
                    Text('\$${item['price']}'),
                  ],
                ),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(item['image_url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class DrawerScreen extends StatelessWidget {
  final VoidCallback onMenuRefresh;

  const DrawerScreen({Key? key, required this.onMenuRefresh}) : super(key: key);

  Future<void> _addMenuItem(String name, String description, double price,
      String imagePath, BuildContext context) async {
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
                  children: <Widget>[
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
                    SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          setState(() {});
                        },
                        child: Text(pickedFile != null ? 'Change Image' : 'Add Image'),
                      ),
                    ),
                    pickedFile != null
                        ? Image.file(
                      File(pickedFile!.path),
                      height: 100,
                    )
                        : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String name = nameController.text;
                    String description = descriptionController.text;
                    double price = double.tryParse(priceController.text) ?? 0.0;
                    String imagePath = pickedFile?.path ?? '';
                    _addMenuItem(name, description, price, imagePath, context);
                    Navigator.of(context).pop();
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

class UpdateDeleteScreen extends StatelessWidget {
  final VoidCallback onMenuRefresh;

  const UpdateDeleteScreen({Key? key, required this.onMenuRefresh}) : super(key: key);

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
  Future<void> _editMenuItem(BuildContext context, dynamic item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMenuItemScreen(item: item, onMenuRefresh: widget.onMenuRefresh)),
    );

    if (result == true) {
      widget.onMenuRefresh(); // Trigger menu refresh
    }
  }

  Future<void> _deleteMenuItem(BuildContext context, dynamic item) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
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
        widget.onMenuRefresh(); // Trigger menu refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete menu item'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _fetchMenuItems(),
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['description']),
                    Text('\$${item['price']}'),
                  ],
                ),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(item['image_url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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

  Future<List<dynamic>?> _fetchMenuItems() async {
    final response = await http.get(Uri.parse('http://192.168.100.155/flutter/fetch_menu.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }
}

class EditMenuItemScreen extends StatefulWidget {
  final dynamic item;
  final VoidCallback onMenuRefresh;

  const EditMenuItemScreen({Key? key, required this.item, required this.onMenuRefresh}) : super(key: key);

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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () async {
                  pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                child: Text(pickedFile != null ? 'Change Image' : 'Add Image'),
              ),
            ),
            pickedFile != null
                ? Image.file(
              File(pickedFile!.path),
              height: 100,
            )
                : Container(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateMenuItem(context);
                },
                child: Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMenuItem(BuildContext context) async {
    String name = nameController.text;
    String description = descriptionController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;

    Map<String, String> data = {
      'id': widget.item['id'].toString(),
      'name': name,
      'description': description,
      'price': price.toString(),
    };

    var uri = Uri.parse('http://192.168.100.155/flutter/update_menu.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(data);

    if (pickedFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', pickedFile!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu item updated successfully'),
        ),
      );
      widget.onMenuRefresh(); // Trigger menu refresh
      Navigator.of(context).pop(true); // Signal successful update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update menu item'),
        ),
      );
    }
  }
}
