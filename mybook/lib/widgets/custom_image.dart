import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mybook/widgets/progress.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.contain,
    placeholder: (context, url)=> Padding( 
      child: circularProgress(),
      padding: EdgeInsets.all(20.0)
    ),
    errorWidget: (context, url, error)=> Icon(Icons.error),
  );
}
