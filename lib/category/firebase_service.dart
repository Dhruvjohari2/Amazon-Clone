import 'package:cloud_firestore/cloud_firestore.dart';
import '../cart/cart_provider.dart';
import '../firestore_service.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CartItem>> getCartItems() async {
    final cartSnapshot = await _db.collection('carts').doc('userCart').get();
    final cartData = cartSnapshot.data();

    if (cartData != null) {
      return (cartData['items'] as List)
          .map((item) => CartItem(product: Product.fromFirestore(item['product']), quantity: item['quantity']))
          .toList();
    }

    return [];
  }

  Future<void> saveCartItems(List<CartItem> cartItems) async {
    await _db.collection('carts').doc('userCart').set({
      'items': cartItems
          .map((item) => {
                'product': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'description': item.product.description,
                  'price': item.product.price,
                  'category': item.product.category,
                  'imageUrl': item.product.imageUrl,
                },
                'quantity': item.quantity,
              })
          .toList(),
    });
  }

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('Category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
}
