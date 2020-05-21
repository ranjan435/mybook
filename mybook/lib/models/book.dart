import 'package:cloud_firestore/cloud_firestore.dart';
class Book {
  final String postId;
  final String ownerId;
  final String bookName;
  final String originalPrice;
  final String sellingPrice;
  final String boughtYear;
  final String edition;
  final String username;
  final String mediaUrl;
  final String description;
  final String requestedBy;
  final String bookStatus;
  final String category;
  Book({
    this.postId,
    this.ownerId,
    this.bookName,
    this.originalPrice,
    this.sellingPrice,
    this.boughtYear,
    this.edition,
    this.username,
    this.mediaUrl,
    this.description,
    this.requestedBy,
    this.bookStatus,
    this.category
  });

  factory Book.fromDocument(DocumentSnapshot doc){
    return Book( 
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      bookName: doc['bookName'],
      originalPrice: doc['originalPrice'],
      sellingPrice: doc['sellingPrice'],
      boughtYear: doc['boughtYear'],
      edition: doc['edition'],
      username: doc['username'],
      mediaUrl: doc['mediaUrl'],
      description: doc['description'],
      requestedBy: doc['requestedBy'],
      bookStatus: doc['bookStatus'],
      category: doc['category'],
    );
  }
}