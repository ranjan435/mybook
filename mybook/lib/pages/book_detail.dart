import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/pages/upload.dart';
import 'package:mybook/widgets/header.dart';
import 'package:mybook/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';


class BookDetail extends StatefulWidget {
  // String currentUserContact = currentUser?.contact;
  final Book book;
  BookDetail({this.book});
  @override
  _BookDetailState createState() => _BookDetailState(book: book);
}

class _BookDetailState extends State<BookDetail> {
  String currentUserId = currentUser?.id;
  final Book book;
  _BookDetailState({this.book});
  bool isOwner = false;
  bool bookStatusAvailable=false;
  List<String> categoryList = [];
  @override 
  void initState(){
    super.initState();
    if(currentUserId == book.ownerId){
      isOwner = true;
    }
    String bookStatus = book.bookStatus;
    if(bookStatus=='available'){
      bookStatusAvailable=true;
    }
    // getCategoryName();
    //test category
    
  }
 
  handleCallRequest()async{
    DocumentSnapshot snapshot = await usersRef
      .document(book.ownerId)
      .get();
    String num = snapshot.data['contact'];
    launch("tel:${num}");
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Book Detail"),
      body: Padding(
        padding: const EdgeInsets.only(top:8.0),
        child: ListView(  
          children: <Widget>[
            Container(  
              margin: EdgeInsets.all(5.0),
              // height: MediaQuery.of(context).size.height *0.3,
              // width: MediaQuery.of(context).size.width * 0.5,
              alignment: Alignment.center,
              child: CachedNetworkImage(
                imageUrl: book.mediaUrl,
                fit:BoxFit.fill,
                width: MediaQuery.of(context).size.width*0.6,
              ),  
            ),
            Card(
              child: Container(
                margin: EdgeInsets.all(10.0),
                // decoration: BoxDecoration( 
                //   border: Border.all()
                // ),
                width: MediaQuery.of(context).size.width*0.8,
                child: Column(  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${book.bookName}'.toUpperCase(),
                        style: TextStyle(  
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ),
                    Row(  
                      children: <Widget>[
                        Text('Book Status: ',
                          style: TextStyle( 
                            fontSize: 20.0
                          ),
                        ),
                        Text('${book.bookStatus}',
                          style: TextStyle( 
                            fontSize: 20.0,
                            color: bookStatusAvailable? Colors.green: Colors.red
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Owner: ${book.username}',
                      style: TextStyle(  
                        color: Colors.black,
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Original price: Rs ${book.originalPrice}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Selling price: Rs ${book.sellingPrice}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Edition: ${book.edition}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Category: ${book.category}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Bought Year: ${book.boughtYear}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Row(  
                      children: <Widget>[
                        Text('Description: ',
                          style: TextStyle( 
                            fontSize: 20.0
                          ),
                        ),
                        Text('${book.description}',
                          style: TextStyle( 
                            fontSize: 20.0,
                            color: Colors.black45
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0,),
                    Container(
                      alignment: Alignment.center,
                      child: FlatButton(  
                        onPressed: ()=> isOwner? Navigator.push(context,MaterialPageRoute(builder: (context)=> Upload(currentUser: currentUser,book: book,title: "${book.bookName}"))): handleCallRequest(),
                        child: Container( 
                          width: 200.0,
                          height: 40.0,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(isOwner?Icons.edit:Icons.call,color: Colors.white,),
                              SizedBox(width: 5.0,),
                              Text(  
                                isOwner? "Edit Book" : "Call owner",
                                style: TextStyle( 
                                  fontSize: 18.0, 
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                            ],
                          ),
                          decoration: BoxDecoration(  
                            color: Colors.blue,
                            border: Border.all(  
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
             
          ],
        ),
      ),
    );
  }
}