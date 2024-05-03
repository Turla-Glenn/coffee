import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      theme: ThemeData(
        primaryColor: Colors.brown[100], // Beige
        appBarTheme: AppBarTheme(
          color: Colors.brown[400], // Brown
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(Colors.brown[400]!), // Dark Brown
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
  Future<List<dynamic>?> fetchMenu() async {
    final response =
    await http.get(Uri.parse('http://192.168.100.155/flutter/fetch_menu.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: fetchMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error: Failed to load menu items'));
          } else {
            List<dynamic> menuItems = snapshot.data!;
            List<dynamic> primaryItems =
            menuItems.take(5).toList(); // Get first 5 items as primary items
            List<dynamic> remainingItems =
            menuItems.skip(5).toList(); // Get remaining items

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carousel section for primary items
                SizedBox(
                  height: 200,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.7,
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                    items: primaryItems.map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      item['image_url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  item['description'],
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '\$${item['price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),

                // List of remaining items
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: remainingItems.length,
                  itemBuilder: (context, index) {
                    var item = remainingItems[index];
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
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMenuItemScreen()),
          ).then((_) {
            setState(() {}); // Refresh the menu after adding a new item
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMenuItemScreen extends StatefulWidget {
  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Menu Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter the menu item name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _selectImage(context);
                  },
                  child: Center(
                    child: _image == null
                        ? Text('Tap to select image')
                        : Image.file(_image!),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _addMenuItem(
                        _nameController.text,
                        _descriptionController.text,
                        double.parse(_priceController.text),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectImage(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image picker not supported on web.'),
        ),
      );
      return;
    }

    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addMenuItem(
      String name, String description, double price) async {
    // Prepare the payload
    Map<String, String> data = {
      'name': name,
      'description': description,
      'price': price.toString(),
    };

    // If image is selected, include it in the payload
    if (_image != null) {
      String fileName = _image!.path.split('/').last;
      data['image'] = fileName;
    }

    print('Request Payload: $data'); // Debug print

    // Send the request
    var uri =
    Uri.parse('http://192.168.100.155/flutter/create_menu.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(data);

    // If image is selected, add it as a file
    if (_image != null) {
      String fieldName = 'image';
      String filePath = _image!.path;
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Response received'); // Debug print
      // Read and print the response body for further analysis
      await response.stream.bytesToString().then(print);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu item added successfully'),
        ),
      );
    } else {
      print('Failed to add menu item'); // Debug print
      // Read and print the response body for further analysis
      await response.stream.bytesToString().then(print);
      throw Exception('Failed to add menu item');
    }
  }
}