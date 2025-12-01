import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../utils/exceptions.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  // Add a new review
  Future<void> addReview(ReviewModel review) async {
    try {
      await _reviewsCollection.doc(review.id).set(review.toJson());

      // Update technician's average rating (could be done via Cloud Function ideally)
      // For now, we'll just add the review.
    } catch (e) {
      throw FirestoreException('Failed to add review', originalError: e);
    }
  }

  // Get reviews for a specific technician
  Future<List<ReviewModel>> getReviewsForTechnician(String technicianId) async {
    try {
      final snapshot = await _reviewsCollection
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch reviews for technician',
        originalError: e,
      );
    }
  }

  // Get paginated reviews for a specific technician
  Future<List<ReviewModel>> getPaginatedReviews(
    String technicianId, {
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _reviewsCollection
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch paginated reviews',
        originalError: e,
      );
    }
  }

  // Get review for a specific order (to check if already reviewed)
  Future<ReviewModel?> getReviewForOrder(String orderId) async {
    try {
      final snapshot = await _reviewsCollection
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ReviewModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch review for order',
        originalError: e,
      );
    }
  }

  // Calculate average rating for a technician
  Future<double> getAverageRating(String technicianId) async {
    try {
      final reviews = await getReviewsForTechnician(technicianId);
      if (reviews.isEmpty) return 0.0;

      final totalRating = reviews.fold(
        0,
        (total, review) => total + review.rating,
      );
      return totalRating / reviews.length;
    } catch (e) {
      throw FirestoreException(
        'Failed to calculate average rating',
        originalError: e,
      );
    }
  }
}
