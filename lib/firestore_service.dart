import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Fetch product reviews
  Stream<List<Review>> getProductReviews(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  // Add review for a product
  Future<void> submitReview(String productId, Review review) async {
    await _db.collection('products').doc(productId).collection('reviews').add({
      'userId': review.userId,
      'userName': review.userName,
      'reviewText': review.reviewText,
      'rating': review.rating,
    });

    // Recalculate average rating
    await _updateProductRating(productId);
  }

  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot = await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .get();
    final reviews = reviewsSnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();

    if (reviews.isNotEmpty) {
      double averageRating = reviews
          .map((r) => r.rating)
          .reduce((a, b) => a + b) / reviews.length;

      // Update product with new average rating
      await _db.collection('products').doc(productId).update({
        'averageRating': averageRating,
      });
    }
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  double averageRating;
  List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.averageRating = 0.0,
    this.reviews = const [],
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      category: data['Category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      averageRating: data['averageRating'] ?? 0.0,
      reviews: [],
    );
  }
}

class Review {
  final String userId;
  final String userName;
  final String reviewText;
  final double rating;

  Review({
    required this.userId,
    required this.userName,
    required this.reviewText,
    required this.rating,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      reviewText: data['reviewText'] ?? '',
      rating: double.tryParse(data['rating'].toString()) ?? 0.0,
    );
  }
}

