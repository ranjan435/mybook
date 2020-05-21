import 'package:flutter/material.dart';

AppBar header(context,{bool isAppTitle = false, String titleText, removeBackButton = false}){
  return AppBar( 
    automaticallyImplyLeading: removeBackButton ? false: true, //value false means no back button so default false 
    title: Text(   
      isAppTitle ? "Merobook" : titleText,
      style: TextStyle(  
        color: Colors.white, 
        fontFamily: "Signatra",
        fontSize: isAppTitle? 65.0: 35.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}