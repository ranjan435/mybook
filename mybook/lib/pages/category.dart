import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/pages/all_books.dart';
import 'package:mybook/widgets/header.dart';
import 'package:mybook/pages/home.dart';

class showCategory extends StatefulWidget {
  final String categoryName;
  showCategory({this.categoryName});
  @override
  _showCategoryState createState() => _showCategoryState(categoryName: categoryName);
}

class _showCategoryState extends State<showCategory> {
  final String categoryName;
  List<Book> bookList = [];
  _showCategoryState({this.categoryName});
  @override
  void initState(){
    super.initState();
    getCategoryBooks();
  }

  getCategoryBooks()async{
    QuerySnapshot query = await postsRef.where('category',isEqualTo: categoryName).getDocuments();
    // print(query.documents);
    setState(() {
      
      bookList = query.documents.map((doc)=> Book.fromDocument(doc)).toList();
    });
    print(bookList);
  }
  @override
  Widget build(BuildContext context) {
    return AllBooks(bookList: bookList,pageTitle: categoryName,);
  }
}