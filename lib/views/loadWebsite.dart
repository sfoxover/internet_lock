
import 'package:flutter/material.dart';
import 'package:internet_lock/models/website.dart';

class LoadWebsite extends StatefulWidget {
  
  final Website website;

  LoadWebsite({Key key, this.website}) : super(key: key);
  @override
  _LoadWebsiteState createState() => _LoadWebsiteState();
}

class _LoadWebsiteState extends State<LoadWebsite> {
  @override
  Widget build(BuildContext context) {
   return Text("Website");
  }
}