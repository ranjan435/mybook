import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybook/models/book.dart';
import 'package:mybook/models/user.dart';
import 'package:mybook/pages/home.dart';
import 'package:mybook/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  final Book book;
  final String title;
  Upload({this.currentUser,this.book,this.title});
  @override
  _UploadState createState() => _UploadState(book: book);
}

class _UploadState extends State<Upload> {
  final Book book;
  _UploadState({this.book});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String bookImageFile = ' ';
  List<String> categoryName = [];
  TextEditingController bookNameController = TextEditingController();
  TextEditingController originalPriceController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController editionController = TextEditingController();
  TextEditingController boughtYearController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryTextController = TextEditingController();//for category add

  bool isUploading = false;
  File file ;
  bool isFileEmpty = true;
  String postId = Uuid().v4();
  String updatedPostId = '';
  String updatedOwnerId = '';
  String updatedMediaUrl = '';
  String updatedUsername = '';
  String updatedRequestedBy = '';
  bool isUpdate = false;
  final List<String> bookStatus = ['available','sold'];
  String _currentStatus='sold';
  String _currentCategory=' ';
  bool _addCategory = false;

  String tempUrl = ' ';
  @override 
  void initState(){
    super.initState();
    setState(() {
      getCategory();
      bookNameController.text = book.bookName;
      originalPriceController.text = book.originalPrice;
      sellingPriceController.text = book.sellingPrice;
      editionController.text = book.edition;
      boughtYearController.text = book.boughtYear;
      descriptionController.text = book.description;
      updatedPostId = book.postId;
      updatedOwnerId = book.ownerId;
      updatedMediaUrl = book.mediaUrl;
      _currentStatus = book.bookStatus;
      _currentCategory = book.category;
      // updatedUsername = book.username;
      // updatedRequestedBy = book.requestedBy;
    });
    if(book.username.length > 2){
      setState(() {
        isUpdate = true;
        isFileEmpty = false;
      });
    }
    print('isUpdate: ${isUpdate}');
  }

  getCategory() async{
    CollectionReference collectCat = Firestore.instance.collection('categories');
    QuerySnapshot query = await collectCat.getDocuments();
    query.documents.forEach((doc)=>{
      setState((){
        categoryName.add(doc.documentID);
      })
    });
    
    // print(categoryName);
  }

  updateThisBook({String bookName, String originalPrice, String sellingPrice, String edition, String boughtYear, String description, String mediaUrl,String currentStatus,String category}){
    print('updating $bookName @ ${widget.book.postId}');
    
    postsRef.document(widget.book.postId).updateData({
      'bookName':bookName,
      'originalPrice':originalPrice,
      'sellingPrice':sellingPrice,
      'edition':editionController.text,
      'boughtYear':boughtYear,
      'description':description,
      'mediaUrl':mediaUrl,
      'bookStatus':currentStatus,
      'category':category,
    });
      SnackBar snackbar = SnackBar(content: Text("Book Updated"),);
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Future.delayed(Duration(seconds: 2),()=>
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(isAuth: true,)))
      );
    
  }

  handleTakePhoto() async{
    Navigator.pop(context);
    
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960
    );
    if(file!=null){

      setState(() {
        this.file = file;
        isFileEmpty = false;
        updatedMediaUrl = ' ';
      });
    }
  }

  handleChooseFromGallery() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (file!=null){

      setState(() {
        this.file = file;
        isFileEmpty = false;
        updatedMediaUrl = ' ';
      });
    }
  }

  selectImage(parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(  
          title: Text('Upload an image'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Photo with Camera"),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text("Image from Gallery"),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: ()=> Navigator.pop(context),
            )
          ],
        );
      }
    );
  }

  compressImage() async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async{
    StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String bookName, String originalPrice, String sellingPrice, String edition, String boughtYear, String description,String currentStatus,String category}){
    postsRef  
      .document(postId)
      .setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": mediaUrl,
        "bookName": bookName,
        "originalPrice": originalPrice,
        "sellingPrice": sellingPrice,
        "edition": edition,
        "boughtYear": boughtYear,
        "description": description,
        "timestamp": timestamp,
        "requestedBy": " ",
        "bookStatus": currentStatus,
        "category": category,
      });
    SnackBar snackbar = SnackBar(content: Text('Your book has been added'));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    Future.delayed(Duration(seconds: 2),()=>
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(isAuth: true,)))
    );
  }

  clearController(){
    bookNameController.clear();
    originalPriceController.clear();
    sellingPriceController.clear();
    editionController.clear();
    boughtYearController.clear();
    descriptionController.clear();
    // _currentStatus = ' ';
    setState(() {
      file = null;
      isFileEmpty = true;
    });
  }

  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    if(file == null){
      if (isUpdate){
        print('file = $file isUpdate=$isUpdate');
        updateThisBook(  
          bookName : bookNameController.text,
          originalPrice : originalPriceController.text,
          sellingPrice : sellingPriceController.text,
          edition : editionController.text,
          boughtYear : boughtYearController.text,
          description : descriptionController.text,
          mediaUrl: widget.book.mediaUrl,
          currentStatus: _currentStatus,
          category: _currentCategory
        );
      }
      else{
        print('file = $file isUpdate=$isUpdate');
        createPostInFirestore(
          //default media
          mediaUrl: 'https://firebasestorage.googleapis.com/v0/b/merobook-70af0.appspot.com/o/awesomeface.png?alt=media&token=15aff1d7-d9c2-4137-9f19-5af90fc026be',
          bookName: bookNameController.text,
          originalPrice: originalPriceController.text,
          sellingPrice: sellingPriceController.text,
          edition: editionController.text,
          boughtYear: boughtYearController.text,
          description: descriptionController.text,
          currentStatus: _currentStatus,
          category: _currentCategory,
        ); 
      }
    }
    else{

      await compressImage();
      bookImageFile = await uploadImage(file);

      if(isUpdate){
        print('file = $file isUpdate=$isUpdate');
        updateThisBook(  
          bookName : bookNameController.text,
          originalPrice : originalPriceController.text,
          sellingPrice : sellingPriceController.text,
          edition : editionController.text,
          boughtYear : boughtYearController.text,
          description : descriptionController.text,
          mediaUrl: bookImageFile,
          currentStatus: _currentStatus,
          category: _currentCategory,
        );
      }
      else{
        print('file = $file isUpdate=$isUpdate');
        createPostInFirestore(
          mediaUrl: bookImageFile,
          bookName: bookNameController.text,
          originalPrice: originalPriceController.text,
          sellingPrice: sellingPriceController.text,
          edition: editionController.text,
          boughtYear: boughtYearController.text,
          description: descriptionController.text,
          currentStatus: _currentStatus,
          category: _currentCategory,
        );
      }
    }
   
    
    clearController();
    setState(() {
      file = null;
      isFileEmpty = true;
      isUploading = false;
      postId = Uuid().v4();
      // _currentStatus = " ";
    });
    
    //redirect to any page;
  }

  showAddCategory(){
    setState((){
      _addCategory = true;
    });

  }

  addCategory(){
    setState(() {
      categoryName.add(categoryTextController.text);
      _currentCategory = categoryTextController.text;
      _addCategory = false;
    });
  }

  Scaffold buildUploadForm(){
    return Scaffold(  
      key: _scaffoldKey,
      appBar: AppBar(  
        backgroundColor: Theme.of(context).primaryColor,
        //icon back button function can be added
        title: Text(
          isUpdate? "Edit book" : 'Add a book for sale',
          style: TextStyle(  
            color: Colors.white
          ),  
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).accentColor,
            ), 
            onPressed: ()=> clearController()
          ),
          IconButton(
            icon: Icon(
              Icons.check,
              color: Theme.of(context).accentColor,
            ), 
            onPressed: ()=> handleSubmit()
          ),
          
        ],
      ),
      body: ListView(  
        children: <Widget>[
          isUploading ? LinearProgress() : Text(''),
          Center(  
            child: Text(
              isUpdate ? "Edit ${widget.title}" : 'Add book\'s detail',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Name of Book:',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: bookNameController,
                    decoration: InputDecoration(  
                      hintText: 'The book thief',
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    // onChanged: (val)=> setState(()=>bookNameController.text = val),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Book Status: ',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black38, width: 1.0)
                  ),    
                  child: DropdownButton(
                    // isDense: true,
                    focusColor: Theme.of(context).primaryColor,
                    value: _currentStatus ,
                    items: bookStatus.map((status){
                      return DropdownMenuItem(
                        value: status,
                        child: Text('$status'),
                      );
                    }).toList(), 
                    onChanged: (val)=> setState(()=> _currentStatus=val)
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Book Category: ',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black38, width: 1.0)
                  ),    
                  child: DropdownButton(
                    // isDense: true,
                    focusColor: Theme.of(context).primaryColor,
                    value: _currentCategory ,
                    items: categoryName.map((status){
                      return DropdownMenuItem(
                        value: status,
                        child: Text('$status'),
                      );
                    }).toList(), 
                    onChanged: (val)=> setState(()=> _currentCategory=val)
                  ),
                ),
                IconButton(  
                  icon: Icon(Icons.add,color: Theme.of(context).primaryColor),
                  onPressed: ()=> showAddCategory(),
                )
              ],
            ),
          ),
          
          _addCategory?
            TweenAnimationBuilder(  
              tween: Tween<double>(begin: 0,end: 1),
              duration: Duration(milliseconds: 500),
              builder: (context,scale,child){
                return Transform.scale(scale: scale,
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Category name:',
                        style: TextStyle(  
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: categoryTextController,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration( 
                            hintText: 'Literature', 
                            // labelText: 'Name of book',
                            border: OutlineInputBorder(  
                              borderRadius: BorderRadius.circular(5.0)
                            )
                          ),
                          
                        ),
                      ),
                      IconButton(  
                        icon: Icon(Icons.close,color: Theme.of(context).primaryColor,),
                        onPressed: ()=> setState(()=>_addCategory = false),
                      ),
                      IconButton(  
                        icon: Icon(Icons.check,color: Theme.of(context).primaryColor,),
                        onPressed: ()=> addCategory(),
                      )
                    ],
                  )
                );
              },
            ):Text(' '),
          
            

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Original price\n(Rs):',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration( 
                      hintText: '500', 
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    // onChanged: (val)=> setState(()=>originalPriceController.text=val),
                  ),
                ),
              ],
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Selling price\n(Rs):',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: sellingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration( 
                      hintText: '200', 
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Edition of Book:',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: editionController,
                    decoration: InputDecoration(  
                      hintText: '2',
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'When was it bought?\n(years ago)',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: boughtYearController,
                    decoration: InputDecoration(  
                      hintText: '2',
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Description?',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(  
                      hintText: 'the book is pretty new with no any torn pages.',
                      // labelText: 'Name of book',
                      border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                    
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Upload image of book',
                  style: TextStyle(  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(width: 20.0,),
                FlatButton( 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Row(  
                    children: <Widget>[
                      Icon(Icons.add_a_photo,color: Colors.white,),

                      Text(' Upload',style: TextStyle(fontSize: 20.0,color: Colors.white),)
                    ],
                  ),
                  onPressed: ()=> selectImage(context), 
                )
              ],
            )
          ),
          isFileEmpty ? Text(' '):Container(  
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8 , //80% of totol widdth
            child: Center(  
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(  
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: updatedMediaUrl.length>2 ? CachedNetworkImageProvider(updatedMediaUrl):FileImage(file), //if greater than 2 show db image otherwise show file can be the case for new upload too
                    )
                  ),
                ),
                
              ),
            ),
          ),
          isUpdate? Container(
            alignment: Alignment.center,
            child: FlatButton(  
              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)
                    ),
              color: Colors.red,
              onPressed: ()=> handleDelete(context),
              child: Text('Delete Book',
                style: TextStyle(  
                  color: Colors.white,
                  fontSize: 20.0
                ),
              ),
            ),
          ):Text(" "),
        ],
      ),
    );
    
  }

  handleDelete(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(  
          title: Text('Delete this book?'),
          children: <Widget>[
            SimpleDialogOption(  
              onPressed: ()async{
                Navigator.pop(context); 
                await deleteBook();
              },
              child: Text(
                'Delete',
                style: TextStyle(  
                  color: Colors.red
                )
              ),
            ),
            SimpleDialogOption(  
              onPressed: ()=>Navigator.pop(context),
              child: Text(  
                'Cancel',
                style: TextStyle(  
                  color: Colors.blue,
                ),
              ),
            )
          ],
        );
      }
    );
  }

  deleteBook() async{
    deleteBookPost();
    //delete uploaded image from the storage
    deleteBookImage();
    deleteCompletion();
    //check it its default image
  }
  
  deleteBookPost() {
    // String tempUrl = ' ';
    // String tempPostId = ' ';
    //delete book
    postsRef  
    .document(book.postId)
    .get().then((doc){
      if (doc.exists){
        setState(() {
          tempUrl = doc['mediaUrl'];
        });
        // tempPostId = doc['postId'];
        print(tempUrl);
        // print('post id is $tempPostId');
        doc.reference.delete();
      }
    });
  }

  deleteBookImage() {

    var str = updatedMediaUrl;
    const start = ".com/o/";
    const end = "?alt";
    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end,startIndex+start.length);
    final requiredUrl = str.substring(startIndex+start.length,endIndex);
    storageRef.child(requiredUrl).delete();

  }

  deleteCompletion(){
    SnackBar snackbar = SnackBar(content: Text('The book has been deleted'));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    clearController();
    Future.delayed(Duration(seconds: 2),()=>
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(isAuth: true,)))
    );

  }
    
    

  
  @override
  Widget build(BuildContext context) {
    return buildUploadForm();
  }
}