import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybook/models/user.dart';
import 'package:mybook/pages/home.dart';
import 'package:mybook/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _usernameValid = true;
  bool _contactValid = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async{
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef  
      .document(widget.currentUserId)
      .get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    usernameController.text = user.username;
    contactController.text = user.contact;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField(){
    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(  
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display Name',
            style: TextStyle( color: Colors.grey),
          ),
        ),
        TextField(  
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update display name",
            errorText: _displayNameValid ? null: "Display name too short",
          ),
        )
      ],
    );
  }
  Column buildUsernameField(){
    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(  
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Username',
            style: TextStyle( color: Colors.grey),
          ),
        ),
        TextField(  
          controller: usernameController,
          decoration: InputDecoration(
            hintText: "Update username",
            errorText: _usernameValid ? null: "Display name too short",
          ),
        )
      ],
    );
  }
  Column buildContactField(){
    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(  
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Contact',
            style: TextStyle( color: Colors.grey),
          ),
        ),
        TextField(  
          controller: contactController,
          decoration: InputDecoration(
            hintText: "Update your contact number",
            errorText: _contactValid ? null: "Contact number unvalid",
          ),
        )
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayNameValid=false : _displayNameValid = true;
      usernameController.text.trim().length <3 || usernameController.text.isEmpty ? _usernameValid = false : _usernameValid = true;
      contactController.text.trim().length == 10 ? _contactValid = true : _contactValid = false;
    });

    if (_displayNameValid && _usernameValid && _contactValid){
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "username": usernameController.text,
        "contact": contactController.text
      });
      SnackBar snackbar = SnackBar(content: Text("Profile Updated"),);
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(  
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(  
          "Edit Profile"
        ),
        actions: <Widget>[
          IconButton(  
            onPressed: ()=> Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: isLoading? circularProgress(): ListView(  
        children: <Widget>[
          Container(   
            child: Column(  
              children: <Widget>[
                Padding(  
                  padding: EdgeInsets.only(top: 16.0,bottom:8.0),
                  child: CircleAvatar(  
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(  
                  padding: EdgeInsets.all(16.0),
                  child: Column(  
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildUsernameField(),
                      buildContactField(),
                    ],
                  ),
                ),
                RaisedButton(  
                  onPressed: ()=> updateProfileData(),
                  child: Text(  
                    "Update Profile",
                    style: TextStyle(  
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                
              ],
            ),
          )
        ],
      ),
    );
  }
}