import 'package:flutter/material.dart';
import 'package:mybook/widgets/header.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isAppTitle:false,titleText:'About Us'),
      body: ListView(  
        children: <Widget>[
          Image.asset('assets/images/about_us.jpg'),
          Container(  
            margin: EdgeInsets.all(10.0),
            // alignment: Alignment.center,
            child: Text(
              'Meronayabook is a crowd source platform where people upload about their unwanted book and the needy people can buy them via contacting them. We are providing a platform to connect the buyer and seller.\n\nWe often have many unused books which other people can find useful. The needy one can get this book at very minimal price amidst the recent tax hike in book.\n\nHelp each other and spread the love for book.' ,
              style: TextStyle( 
                letterSpacing: 1.0,
                fontSize: 15.0,
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      )
    );
  }
}