import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  final String userId;

  const AdminScreen({super.key, required this.userId});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Function to show dialog for creating or updating a product
  _showProductDialog({String? productId, String? name, String? price, String? imageUrl}) {
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController priceController = TextEditingController(text: price);
    final TextEditingController imageUrlController = TextEditingController(text: imageUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(productId == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    imageUrlController.text.isNotEmpty) {
                  if (productId == null) {
                    // Create new product
                    FirebaseFirestore.instance.collection('Products').add({
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                      'imageUrl': imageUrlController.text,
                    });
                  } else {
                    // Update existing product
                    FirebaseFirestore.instance.collection('Products').doc(productId).update({
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                      'imageUrl': imageUrlController.text,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to show dialog for deleting a product
  _deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('Products').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Page')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Products').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Price: \$${product['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showProductDialog(
                          productId: product.id,
                          name: product['name'],
                          price: product['price'].toString(),
                          imageUrl: product['imageUrl'],
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductDialog(); // Show dialog to add a new product
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
