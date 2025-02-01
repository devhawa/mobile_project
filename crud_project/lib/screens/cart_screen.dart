import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  const CartScreen({super.key, required this.userId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Carts')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is empty.'));
          }

          // List of cart items
          return ListView.builder(
            itemCount: cartSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var cartItem = cartSnapshot.data!.docs[index];
              String productId = cartItem['productId'];

              // Fetch product details based on productId
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Products').doc(productId).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: CircularProgressIndicator(),
                    );
                  }

                  if (!productSnapshot.hasData) {
                    return ListTile(
                      title: Text('Product not found'),
                    );
                  }

                  var product = productSnapshot.data!;
                  String productName = product['name'] ?? 'Unknown';
                  String productImage = product['imageUrl'] ?? '';

                  return ListTile(
                    leading: productImage.isNotEmpty
                        ? Image.network(productImage, width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 50),
                    title: Text(productName),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('Carts').doc(cartItem.id).delete();
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
