import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mybook/models/book.dart';

import 'package:mybook/models/user.dart';
import 'package:mybook/pages/about_us.dart';
import 'package:mybook/pages/all_books.dart';
import 'package:mybook/pages/book_detail.dart';
import 'package:mybook/pages/category.dart';
import 'package:mybook/pages/create_account.dart';
import 'package:mybook/pages/profile.dart';
import 'package:mybook/pages/search_user.dart';
import 'package:mybook/pages/test.dart';
import 'package:mybook/pages/upload.dart';
import 'package:mybook/widgets/custom_image.dart';
import 'package:mybook/widgets/header.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
GoogleSignInAccount googleUser ;
final DateTime timestamp = DateTime.now();
User currentUser;
List<String> categoryList=[];//for displaying category name
List<Book> categoryBookList=[];//for displaying each category's book when tapped on category

//database ref
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final categoryRef = Firestore.instance.collection('categories');
final StorageReference storageRef = FirebaseStorage.instance.ref();

bool connection = true;
class Home extends StatefulWidget {
  bool isAuth;
  Home({this.isAuth=false});
  @override
  _HomeState createState() => _HomeState(isAuth: this.isAuth);
}

class _HomeState extends State<Home> {
   Book book = Book(
    bookName: '',
    postId: '',
    ownerId: '',
    originalPrice: '',
    sellingPrice: '',
    edition: '',
    boughtYear: '',
    username: '',
    mediaUrl: '',
    description: '',
    bookStatus: 'available',
    category: 'Entrance',
  );
  var connectivity;
  bool isAuth;
  _HomeState({this.isAuth=false});
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  // bool isAuth = false;
  List<dynamic> bookList = [];
  List<String> allMediaUrl = [];
  List<String> testUrl = [];
  Book selectedBook ;
  @override
  void initState() {
    super.initState();
    
    getAllBooks();
    
    getCategoryName();
    
  }


  void getAllBooks() async{
    QuerySnapshot snapshot = await postsRef.orderBy('timestamp',descending:true).getDocuments();
    // setState(() {
      bookList = snapshot.documents.map((doc)=>Book.fromDocument(doc)).toList();
    // });
    snapshot.documents.forEach((doc){
      print('this data in home${doc.data['mediaUrl']}');
      
    });
    extractMediaUrl();
    getCategoryName();
    
  }

  void getCategoryName() async{
    QuerySnapshot testDocuments = await categoryRef.getDocuments();
    testDocuments.documents.forEach((doc)=>{
      if(!categoryList.contains(doc.documentID)){
        categoryList.add(doc.documentID)
      }
    });
    print(categoryList);
  }

  void getCategoryBooks(String categoryName) async{
    QuerySnapshot query = await postsRef.where('category',isEqualTo: categoryName).getDocuments();
    // print(query.documents);
    setState(() {  
      categoryBookList = query.documents.map((doc)=> Book.fromDocument(doc)).toList();
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=> AllBooks(bookList: categoryBookList,pageTitle: categoryName,)));
  }

  void getOneBook(String mediaUrl)async{
    await bookList.forEach((doc){
      print('got mediaUrl $mediaUrl');
      if(doc.mediaUrl == mediaUrl){
        setState(() {
          selectedBook = doc;
        });
      }
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=> BookDetail(book: selectedBook,)));
  }

  // routetoDetail(String mediaUrl){

  // }

  void extractMediaUrl() {
    bookList.forEach((d){
      setState(() {
        
      allMediaUrl.add(d.mediaUrl);
      });
    });

    // print('total mediaUrl = ${allMediaUrl.length}');
    // testUrl = snapshot.documents.map((doc)=>Book.fromDocument(doc)).toList();
  }

  login() async{
    googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = 
         await googleUser.authentication;
      // get the credentials to (access / id token)
      // to sign in via Firebase Authentication 
      final AuthCredential credential =
         GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken
         );
      await _auth.signInWithCredential(credential);
      
      setState(() {
        isAuth=true;
      });
      createUserInFirestore();
      await getAllBooks();
      // await extractMediaUrl();
      
  }

  logout(){
    googleSignIn.signOut();
    setState(() {
        isAuth = false;
      });
  }

  void createUserInFirestore() async{
    //check if user existes in users collection in database according to their id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    // setState(() {
    //     // currentUser = User.fromDocument(doc);
    //     isAuth = true;
    //   });

    //if the user doesn't exist, then navigate to create account page
    if(!doc.exists){
      print('doc doesnt exist so calling create username');
      // List<String> detail;
      final username= await Navigator.push(context,MaterialPageRoute(builder: (context)=> CreateAccount()));
    //get username and create a new user and add it to users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": 'bio',
        "contact": " ",
        "timestamp": timestamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    setState(() {
      
      currentUser = User.fromDocument(doc);
      // isAuth = true;
    });
  }

  refreshHome(BuildContext context){
    print('refresh home');
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(isAuth: true,)));
  }

  Scaffold buildAuthScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;

    // getAllBooks();
    // extractMediaUrl();
    return Scaffold(
      appBar: header(context,isAppTitle: true),
      drawer: Drawer(  
        child: ListView(  
          children: <Widget>[
            //header            
            currentUser!=null? UserAccountsDrawerHeader(
              accountName: Text(currentUser.displayName), 
              accountEmail: Text(currentUser.email),
              currentAccountPicture: GestureDetector(  
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profileId: currentUser?.id,))),
                child: CircleAvatar( 
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                ),
              ),
              decoration: BoxDecoration(  
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 30.0, // has the effect of softening the shadow
                    spreadRadius: 1.0, // has the effect of extending the shadow
                    offset: Offset(
                      5.0, // horizontal, move right 10
                      10.0, // vertical, move down 10
                    ),
                  ),
                ]
              ),
            ):Text(' '),
            //body
            InkWell(  
              onTap: ()=> refreshHome(context),
              child: ListTile(  
                title: Text('Home page'),
                leading: Icon(
                  Icons.home,
                  color: Colors.blue,
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AllBooks(bookList: bookList,pageTitle: 'All Books',)));
              },
                child: ListTile( 
                  title: Text('All Books'),
                  leading: Icon(Icons.book,color:Colors.blue,),
              ),
            ),
            InkWell(  
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> Search())),
              child: ListTile(  
                title: Text('Search'),
                leading: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
              ),
            ),
            InkWell(  
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> Upload(currentUser: currentUser,book: book,title: " "))),
              child: ListTile(  
                title: Text('Add a book'),
                leading: Icon(
                  Icons.library_add,
                  color: Colors.blue,
                ),
              ),
            ),
            InkWell(  
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(profileId: currentUser?.id))),
              child: ListTile(  
                title: Text('Profile'),
                leading: Icon(
                  Icons.account_box,
                  color: Colors.blue,
                ),
              ),
            ),
           
            
            Divider(),

            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> About()));
              },
                child: ListTile( 
                  title: Text('About'),
                  leading: Icon(Icons.help,color: Colors.blue,),
              ),
            ),
            InkWell(
              onTap: (){
                logout();
              },
                child: ListTile( 
                  title: Text('Sign Out'),
                  leading: Icon(Icons.person,color: Colors.blue,),
              ),
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: ()=> refreshHome(context),
          child: ListView(  
            children: <Widget>[
              //slider
              Container(
                decoration: BoxDecoration(  
                  color: Theme.of(context).primaryColor,
                  gradient:LinearGradient(  
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                    // Colors.white,
                    // Colors.black45
                    Theme.of(context).accentColor,
                    Theme.of(context).primaryColor              
                    ]
                  )
                ),
                child: Column(
                  children: <Widget>[
                    Text(  
                      'Recent Books',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 40.0,
                        fontFamily: 'Eagle-Lake',
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    CarouselSlider(
                      options: CarouselOptions(  
                        aspectRatio: 2.0,
                        height: 240.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayAnimationDuration: Duration(seconds: 1)
                      ),
                      items: allMediaUrl.map((it){
                        return GestureDetector(
                          onTap: ()=> getOneBook(it),
                            child: Card(
                              elevation: 5.0,
                                child: ListTile(  
                                  contentPadding: EdgeInsets.only(bottom:20.0),
                                  title: cachedNetworkImage(it),
                              ),
                            ),
                        );
                        // return Container(  
                        //   color: Theme.of(context).primaryColor,
                        //   // width: MediaQuery.of(context).size.width,
                        //   child: CachedNetworkImage(imageUrl: it,),
                        // );
                      }).toList(),
                      
                    ),
                  ],
                ),
              ), 

              //category 
              Container(
                child: Text(
                  'Category',
                  style: TextStyle( 
                    fontSize: 30.0,
                    fontFamily: 'Eagle-Lake',
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              Container(  
                child:SizedBox(
                  height: 100,
                  child: ListView.builder(  
                    // shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryList.length,
                    itemBuilder: (BuildContext ctxt, int index){
                      return GestureDetector(
                        onTap: ()=> getCategoryBooks(categoryList[index]),
                        child: Card( 
                          elevation: 20.0, 
                          child: Container(
                            alignment: Alignment.center,
                            width: 100,
                            child: Text('${categoryList[index]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                // color: Colors.blue,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800
                              ),
                            )
                          ),
                        ),
                      );
                    },
                  ),
                )
              ),
              Padding(  
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Text(
                  'All Books',
                  style: TextStyle( 
                    fontSize: 30.0,
                    fontFamily: 'Eagle-Lake',
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              SizedBox(
                height: 200,  
                child: ListView.builder (
                  scrollDirection: Axis.horizontal,
                  itemCount: bookList.length,
                  // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //           crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                  //           crossAxisSpacing: 5.0,
                  //           mainAxisSpacing: 5.0,
                  //         ), 
                  itemBuilder: (BuildContext context,int index){
                    return GestureDetector(
                      child: Card( 
                        elevation: 30.0,
                        // child: InkWell(
                        //     highlightColor: Colors.blue,
                        //     radius: 5.0,
                        //     borderRadius: BorderRadius.circular(20.0),
                        //     onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> BookDetail(book:bookList[index]))),
                        //     child: Stack(
                        //       children: <Widget>[
                        //         Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: cachedNetworkImage(
                        //             bookList[index].mediaUrl,
                        //           ),
                        //         ),
                        //       Positioned.fill(
                        //         top: 150,
                        //           child: Align(
                        //           alignment: Alignment.bottomCenter,
                        //             child: Container(
                        //               alignment: Alignment.center,
                        //               color: Colors.black.withOpacity(0.5),
                        //               padding: const EdgeInsets.all(8.0),
                        //               child: Text(bookList[index].bookName,
                        //                 style: TextStyle(  
                        //                   color: Colors.white
                        //                 ),
                        //               )
                        //             ),
                        //           ),
                        //       )
                        //         // Container(
                        //         //   alignment: Alignment.center,
                        //         //     margin: EdgeInsets.only(top: 40),
                        //         //     child: CachedNetworkImage(
                        //         //       imageUrl: bookList[index].mediaUrl,
                        //         //       alignment: Alignment.center,
                        //         //     )
                        //         // ),
                                
                        //       ],
                        //     )
                        //   ),
                        child:cachedNetworkImage(bookList[index].mediaUrl,)
                        // child: GridTile(  
                        //   header: Container(
                        //     alignment: Alignment.center,
                        //     color: Colors.black.withOpacity(0.5),
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Text(bookList[index].bookName,
                        //       style: TextStyle(  
                        //         color: Colors.white
                        //       ),
                        //     )
                        //   ),
                        //   child: CachedNetworkImage(imageUrl:bookList[index].mediaUrl,),
                        // ),
                      ),
                    );
                  }
            ),
                  
                
            ),
            Container(
            alignment: Alignment.center,
            child: FlatButton(  
              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)
                    ),
              color: Theme.of(context).primaryColor,
              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AllBooks(bookList: bookList,pageTitle: 'All Books',))),
              child: Text('See all',
                style: TextStyle(  
                  color: Colors.white,
                  fontSize: 20.0
                ),
              ),
            ),
          )
           
              // Padding(padding: EdgeInsets.only(top:50.0),),
              
              // IconButton(  
              //   onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AllBooks(bookList: bookList,pageTitle: 'All Books',))),
              //   icon: Icon(Icons.person),
              // )
            ],
          ),
      )  
    );

    
    //categories

    //top books

  }

  Future<Null>_refreshTest(){
    print('refreshing the page');
    return null;
  }

  Scaffold buildUnAuthScreen(){
    
    return Scaffold(
      body: Container(  
        decoration: BoxDecoration(  
          gradient: LinearGradient(  
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: [
              // Colors.white,
              // Colors.black45
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor              
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Meronayabook',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white
              ),
            ),
            TweenAnimationBuilder(  
              tween: Tween<double>(begin: 0,end: 1),
              duration: Duration(seconds: 3),
              builder: (context,scale,child){
                return Transform.scale(scale: scale,child: Image.asset('assets/images/book_child.jpg'));
              },
            ),
           
            GestureDetector(  
              onTap: (){
                login();
              },
              child: Container(  
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(  
                  // border: Border.all(),
                  image: DecorationImage(  
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return isAuth? buildAuthScreen(): buildUnAuthScreen();
  }
}