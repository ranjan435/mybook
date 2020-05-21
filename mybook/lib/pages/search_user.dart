import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/models/user.dart';
import 'package:mybook/pages/book_detail.dart';
import 'package:mybook/pages/profile.dart';
import 'package:mybook/widgets/header.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mybook/pages/home.dart';
import 'package:mybook/widgets/post_tile.dart';
import 'package:mybook/widgets/progress.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Future<QuerySnapshot> searchBookResultsFuture;
  bool isBookSearch = false;
  TabController _tabController ;
  int _currentIndex = 0;
  @override 
  void initState() {
    super.initState();
    _tabController = TabController(length: 2,vsync: this);
    _tabController.addListener(tabChanged);
  }

  tabChanged(){
    print('tab changed ${_tabController.index}');
    clearSearch();
    setState(() {
      searchResultsFuture = null;
      searchBookResultsFuture = null;
      _currentIndex = _tabController.index;
      if(_currentIndex == 0){
        isBookSearch = false;
      }
      else{
        isBookSearch = true;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.account_box),text: "User",),
    Tab(icon: Icon(Icons.book),text: "Book",)
  ];

  handleSearch(String query){
    Future<QuerySnapshot> users = usersRef
      .where("displayName",isGreaterThanOrEqualTo: query.toUpperCase())
      .getDocuments();
    print('handling search');
    setState(() {
      searchResultsFuture = users;
    });
  }

  handleBookSearch(String query){
    Future<QuerySnapshot> posts = postsRef
      .where("bookName",isGreaterThanOrEqualTo: query)
      .getDocuments();
    print('handling book search $posts');
    setState(() {
      searchBookResultsFuture = posts;
    });
    // print('after handling book search $searchBoo');
  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(  
      backgroundColor: Theme.of(context).primaryColor,
      title: TextFormField(  
        onChanged: (val)=> setState((){
          isBookSearch ? handleBookSearch(val): handleSearch(val);
        }),
        controller: searchController,
        decoration: InputDecoration(  
          hintText: "Search for a user....",
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(  
            Icons.account_box,
            size: 28.0
          ),     
          suffixIcon: IconButton(  
            icon: Icon(Icons.clear),
            onPressed: ()=> clearSearch(),
          ),
        ),
        onFieldSubmitted: isBookSearch ? handleBookSearch: handleSearch,
      ),
      bottom: TabBar( 
        controller: _tabController, 
        tabs: myTabs
      ),
    );
  }

  Container buildNoContent(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(  
      child: Center(  
        child: ListView(   
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0:200.0),
            Text(
              isBookSearch?'Find Books':'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(  
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0, 
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults(){
    return FutureBuilder(  
      future: searchResultsFuture,
      builder: (context,snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        if(searchResults!=null){
          print(searchResults);
          return ListView(  
            children: searchResults,
          );
        }
      },
    );
  }
  buildSearchBookResults(){
    return FutureBuilder(  
      future: searchBookResultsFuture,
      builder: (context,snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        }
        List<BookResult> searchBookResults = [];
        snapshot.data.documents.forEach((doc){
          Book book = Book.fromDocument(doc);
          BookResult searchBookResult = BookResult(book);
          searchBookResults.add(searchBookResult);
        });
        print('running buildSearchBook results');
        return ListView(  
          children: searchBookResults,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(  
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
          appBar: buildSearchField(),
          body: TabBarView(  
            controller: _tabController,
            // children: <Widget>[
            //   searchResultsFuture == null ? buildNoContent(): buildSearchResults(),
            //   searchBookResultsFuture == null ? buildNoContent(): buildSearchBookResults(),
            // ],
            children: myTabs.map<Widget>((Tab tab){
              if(_currentIndex == 0){
                // setState(() {
                //   isBookSearch = false;
                // });
                print('user search $searchResultsFuture');
                return searchResultsFuture == null ? buildNoContent() : buildSearchResults();
              }
              else{
                // setState(() {
                //   isBookSearch = true;
                // });
                print('book search $searchBookResultsFuture');
                return searchBookResultsFuture == null ? buildNoContent(): buildSearchBookResults();
              }
            }).toList(),
          ),
          // body: searchResultsFuture == null ? buildNoContent(): buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        child: Column(  
          children: <Widget>[
            GestureDetector(  
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(profileId: user.id,))),
              child: ListTile(  
                leading: CircleAvatar( 
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(  
                  user.displayName,
                  style: TextStyle(  
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text( 
                  user.username,
                  style: TextStyle(  
                    color: Colors.white
                  ),
                ),
              ),
            ),
            Divider( 
              height: 2.0,
              color: Colors.white54,
            )
          ],
        ),
      ),
    );
  }
}

class BookResult extends StatelessWidget {
  final Book book;
  BookResult(this.book);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        child: Column(  
          children: <Widget>[
            GestureDetector(  
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> BookDetail(book: book,))),
              child: ListTile(  
                leading: CircleAvatar( 
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(book.mediaUrl),
                ),
                title: Text(  
                  book.bookName,
                  style: TextStyle(  
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text( 
                  book.ownerId,
                  style: TextStyle(  
                    color: Colors.white
                  ),
                ),
                trailing: Icon(Icons.brightness_1,
                  color: book.bookStatus == 'available'? Colors.green[800]:Colors.red,
                ),
              ),
            ),
            Divider( 
              height: 2.0,
              color: Colors.white54,
            )
          ],
        ),
      ),
    );
  }
}