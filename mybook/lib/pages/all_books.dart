import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/pages/book_detail.dart';
import 'package:mybook/pages/home.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/pages/test.dart';
import 'package:mybook/widgets/book_detail_test.dart';
import 'package:mybook/widgets/custom_image.dart';
import 'package:mybook/widgets/header.dart';

class AllBooks extends StatefulWidget {
  final String pageTitle;
  List<dynamic> bookList = [];
  AllBooks({this.bookList,this.pageTitle});
  @override
  _AllBooksState createState() => _AllBooksState(
    bookList: bookList
  );
}

class _AllBooksState extends State<AllBooks> {
  // List<Book> books = [];
  List<dynamic> bookList = [];
  _AllBooksState({this.bookList});
  // List<Book> books = 
  bool isLoading = false;
  @override
  void initState(){
    super.initState();
    bookList = this.bookList;
    print('all book got bookList $bookList');
    print(widget.pageTitle);
    // getAllBooks();
  }

  // getAllBooks() async{
  //   setState(() {
  //     isLoading = true;
  //   });
  //   QuerySnapshot snapshot = await postsRef
  //     .orderBy('timestamp',descending: true)
  //     .getDocuments();
  //   books = snapshot.documents.map((doc)=>Book.fromDocument(doc)).toList();
    
  //   print(books[0].bookName);
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(  
      appBar: header(context,isAppTitle: true),
      body: Column(
        children: <Widget>[

          Card(
            elevation: 20.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.pageTitle,
                style: TextStyle(  
                  fontFamily: "Eagle-Lake",
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                ),
              ),
            ),
          ),
          
          Expanded(
            child: GridView.builder (
              itemCount: bookList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ), 
              itemBuilder: (BuildContext context,int index){
                return Card( 
                  elevation: 30.0,
                  child: InkWell(
                      highlightColor: Colors.blue,
                      radius: 5.0,
                      borderRadius: BorderRadius.circular(20.0),
                      // onDoubleTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>Test(bookList:bookList))),
                      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> BookDetail(book:bookList[index]))),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: cachedNetworkImage(
                              bookList[index].mediaUrl,
                              // width: 300,
                              // height: 300,
                              // fit: BoxFit.cover,
                            ),
                          ),
                         Positioned.fill(
                           top: 150,
                            child: Align(
                             alignment: Alignment.bottomCenter,
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.5),
                                padding: const EdgeInsets.all(8.0),
                                child: Text(bookList[index].bookName,
                                  style: TextStyle(  
                                    color: Colors.white
                                  ),
                                )
                              ),
                            ),
                         )
                          // Container(
                          //   alignment: Alignment.center,
                          //     margin: EdgeInsets.only(top: 40),
                          //     child: CachedNetworkImage(
                          //       imageUrl: bookList[index].mediaUrl,
                          //       alignment: Alignment.center,
                          //     )
                          // ),
                          
                        ],
                      )
                    ),
                  
                  // child: GridTile(  
                  //   // footer: Text(bookos[index].bookName),
                  //   child: CachedNetworkImage(imageUrl: books[index].mediaUrl,),
                  // ),
                );
              }
            ),
          ),
        ],
      ),
    );
    
    
  }
}