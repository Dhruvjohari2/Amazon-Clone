import 'package:flutter/material.dart';
import '../category/firebase_service.dart';
import '../firestore_service.dart';

class CartProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<CartItem> _cartItems = [];

  CartProvider() {
    _loadCart();
  }

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0.0, (total, cartItem) {
      return total + (cartItem.product.price * cartItem.quantity);
    });
  }

  Future<void> _loadCart() async {
    
    _cartItems = await _firebaseService.getCartItems(); 
    notifyListeners();
  }

  void addToCart(Product product) {
    final existingCartItem = _cartItems.firstWhere(
          (cartItem) => cartItem.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingCartItem.quantity > 0) {
      existingCartItem.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }

    _saveCart(); 
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final cartItem = _cartItems.firstWhere((item) => item.product.id == product.id);
    cartItem.quantity = quantity;

    if (cartItem.quantity <= 0) {
      _cartItems.remove(cartItem);
    }

    _saveCart(); 
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((cartItem) => cartItem.product.id == product.id);
    _saveCart(); 
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    await _firebaseService.saveCartItems(_cartItems); 
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
