import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/pages/book_detail.dart';
import 'package:mybook/widgets/book_detail_test.dart';
import 'package:mybook/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Book book;
  PostTile({this.book});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(  
      onTap: ()=> Navigator.push(context,MaterialPageRoute(builder: (context)=> BookDetail(book: book,))),
      child: cachedNetworkImage(book.mediaUrl),
    );
  }
}