import 'package:amazon_clone/home/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import '../firestore_service.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final cartProvider = Provider.of<CartProvider>(context); 


    return Scaffold(
      appBar: AppBar(
        title: Text('Products in $category'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching products'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          
          final products = snapshot.data!
              .where((product) => product.category == category)
              .toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product, cartProvider: cartProvider,); 
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final CartProvider cartProvider;

  ProductCard({required this.product, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    print('now ${product.imageUrl}');
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                
                
                
                
                
                
                

                product.imageUrl.isNotEmpty ?
                Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                )
                    : Container(),
                SizedBox(height: 10),
                Text(
                  product.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 5),
                Text(
                  '\$${product.price}',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 5),
                Text(product.description),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      cartProvider.addToCart(product);
                    },
                    child: Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
