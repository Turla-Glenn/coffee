import 'package:flutter/material.dart';
import 'drawer_and_update_delete_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Define a callback function to refresh menu items
  void refreshMenu() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      drawer: DrawerAndUpdateDeleteScreen(onMenuRefresh: refreshMenu), // Use the combined screen
      body: MenuBody(),
    );
  }
}

class MenuBody extends StatefulWidget {
  @override
  _MenuBodyState createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: primaryItems.length,
                  itemBuilder: (context, index) {
                    var item = primaryItems[index];
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.7,
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
                ),
              ),

              // List of remaining items
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
    );
  }
}
