import 'package:crud_project/screens/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';  // Add your AdminPage here

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userRole;
  late String userName;
  late String userEmail;
  late String profileImage;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fetch the user role from Firestore
    // Fetch the user data (name, email, profile image, and role) from Firestore
  void _getUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'] ?? 'No Name'; // Default to 'No Name' if missing
        userEmail = userDoc['email'] ?? 'No Email'; // Default to 'No Email' if missing
        profileImage = userDoc['profileImage'] ?? 'https://cdn-icons-png.flaticon.com/512/8847/8847419.png'; // Default image URL
        userRole = userDoc['role'] ?? 'user'; // Default to 'user' if role is not set
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
               accountName: Text(userName),  // Dynamically display the user's name
              accountEmail: Text(userEmail),  // Dynamically display the user's email
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(profileImage),  // Dynamically display the user's profile image
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              title: Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId)),
                );
              },
            ),
            if (userRole == 'admin') // Show Admin Page if user is admin
              ListTile(
                title: Text('Admin Page'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminScreen(userId: widget.userId)),
                  );
                },
              ),
            ListTile(
              title: Text('Help'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpScreen()),
                  );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(userId: widget.userId)));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId)));
          }
        },
      ),
      body: Column(
        children: [
          // Welcome Text and Image Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Welcome to Our Project',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/3733/3733132.png', // Image URL
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ),
          // Products StreamBuilder
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Products').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available.'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var product = snapshot.data!.docs[index];
                    String imageUrl = product['imageUrl'] ?? '';

                    return Card(
                      child: Column(
                        children: [
                          // Show the image if the URL is valid, otherwise show an error icon
                          imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 100,
                                  width: 100,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    // Show a loading spinner while the image is being loaded
                                    if (loadingProgress == null) {
                                      return child; // Image loaded successfully
                                    } else {
                                      return Center(child: CircularProgressIndicator()); // Show loading spinner
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // Log the error to help debug why the image is not loading
                                    print('Error loading image: $error');
                                    return Icon(Icons.error, size: 100); // Fallback on error
                                  },
                                )
                              : Icon(Icons.image_not_supported, size: 100), // Fallback if no image URL
                          Text(product['name'] ?? 'Unnamed Product'), // Fallback name
                          ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance.collection('Carts').add({
                                'userId': widget.userId,
                                'productId': product.id,
                              });
                            },
                            child: Text('Add to Cart'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
