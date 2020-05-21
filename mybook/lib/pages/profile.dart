import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/models/user.dart';
import 'package:mybook/pages/edit_profile.dart';
import 'package:mybook/widgets/header.dart';
import 'package:mybook/widgets/post_tile.dart';
import 'package:mybook/widgets/progress.dart';
import 'package:mybook/pages/home.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  int bookCount = 0;
  int bookSold = 0;
  List<Book> books = [];
  bool isLoading = false;
  @override  
  void initState(){
    super.initState();
    getProfilePost();
  }

  getProfilePost() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef.where("ownerId",isEqualTo:widget.profileId).getDocuments();
    setState(() {
      isLoading = false;
      bookCount = snapshot.documents.length;
      books = snapshot.documents.map((doc)=> Book.fromDocument(doc)).toList();
      //count number of boos sold
      snapshot.documents.forEach((doc){
        if(doc.data['bookStatus']=='sold'){
          bookSold +=1;
        }
      });
    });
    print(snapshot.documents);
  }

  Column buildCountColumn(String label, int count){
    return Column(  
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(  
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(  
          margin: EdgeInsets.only(top: 4.0),
          child: Text(  
            label,
            style: TextStyle(  
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400 
            ),
          ),
        )
      ],
    );
  }

  Container buildButton({String text,Function function}){
    return Container(  
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(  
        onPressed: ()=>function(),
        child: Container( 
          width: 200.0,
          height: 27.0,
          child: Text(  
            text,
            style: TextStyle(  
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(  
            color: Colors.blue,
            border: Border.all(  
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton(){
    //if viewing own profile= show show edit profile
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner){
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    }
    // else if (isFollowing){
    //   return buildButton(
    //     text: "Unfollow", 
    //     function: handleUnfollowUser
    //   );
    // }
    // else if (!isFollowing){
    //   return buildButton(
    //     text: "Follow",
    //     function: handleFollowUser
    //   );
    // }
    else{
      return Text('Thumbs up!');
    }
  }

  editProfile(){
    Navigator.push(context, MaterialPageRoute(builder:(context) => EditProfile(currentUserId: currentUserId)));
  }

  buildProfileHeader(){
    return FutureBuilder(  
      future: usersRef.document(widget.profileId).get(),
      builder: (context,snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(  
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(  
                children: <Widget>[
                  CircleAvatar( 
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(  
                    flex: 1,
                    child: Column(  
                      children: <Widget>[
                        Row(  
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("books added", bookCount),
                            buildCountColumn("books sold", bookSold),
                            // buildCountColumn("following", 1),

                          ],
                        ),
                        Row(  
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(  
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(  
                  user.username,
                  style: TextStyle(  
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  )
                ),
              ),
              Container(  
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(  
                  user.displayName,
                  style: TextStyle(  
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
              // Text(user),
              
            ],
          ),
        );
      },
    );
  }

  buildProfilePost(){
    if(isLoading){
      circularProgress();
    }
    else if(books.isEmpty){
      return Text('You haven\'t added any books. Help others to buy book at cheaper cost by selling your unwanted books');
    }
    else{
      List<GridTile> gridTiles = [];
      books.forEach((book){
        gridTiles.add(GridTile( 
          child: PostTile(book:book),
        ));
      });

      return GridView.count(  
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }

  }
    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(  
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          Text('Books added:',
            style: TextStyle(   
              fontSize: 30.0,
              fontFamily: 'Eagle-Lake',
              fontWeight: FontWeight.bold
            ),
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}