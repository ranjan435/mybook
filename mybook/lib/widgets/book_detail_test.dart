import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/widgets/header.dart';
import 'package:mybook/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';


class BookDetailTest extends StatelessWidget {
  String currentUserContact = currentUser?.contact;
  String currentUserId = currentUser?.id;
  final Book books;
  BookDetailTest({this.books});
  // bool isRequested = false;
  // handleBookRequest() async{
  //   final doc = await postsRef
  //     .document(books.postId)
  //     .get();
  //   if(doc.exists){
  //     doc.reference.updateData({'requestedBy': currentUserId});
  //   }
  // }

  handleCallRequest()async{
    DocumentSnapshot snapshot = await usersRef
      .document(books.ownerId)
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
                imageUrl: books.mediaUrl,
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
                        '${books.bookName}'.toUpperCase(),
                        style: TextStyle(  
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ),
                    Text(
                      'Owner: ${books.username}',
                      style: TextStyle(  
                        color: Colors.black,
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Original price: Rs ${books.originalPrice}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Selling price: Rs ${books.sellingPrice}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Edition: ${books.edition}',
                      style: TextStyle( 
                        fontSize: 20.0
                      ),
                    ),
                    Text(
                      'Bought Year: ${books.boughtYear}',
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
                        Text('${books.description}',
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
                        onPressed: ()=> handleCallRequest(),
                        child: Container( 
                          width: 200.0,
                          height: 40.0,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.call,color: Colors.white,),
                              Text(  
                                "Call owner",
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