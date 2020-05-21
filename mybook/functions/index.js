const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onBookCreate = functions.firestore
    .document("posts/{postId}")
    .onCreate(async(snapshot,context)=>{
        console.log('post created',snapshot.data());

        const postId = context.params.postId;
        const postsRef = admin.firestore().collection('posts');
        const categoryRef = admin.firestore().collection('categories');
        
        const querySnapshot = await postsRef.get();
        querySnapshot.forEach(doc=>{
            if(doc.exists){
                const postId = doc.id;
                const category = doc.get('category');
                const postData = doc.data();
                categoryRef.doc(category).set({'id':category});
                categoryRef.doc(category).collection('categoryBook').doc(postId).set(postData);
            }
        })
        //add each post to category
        
});

exports.onBookDelete = functions.firestore
    .document("posts/{postId}")
    .onDelete(async(snapshot,context)=>{
        console.log("Book Deleted",snapshot.data());
        const category = snapshot.get('category');
        const postId = context.params.postId;

        const querySnapshot = admin
            .firestore()
            .collection('categories')
            .doc(category)
            .collection('categoryBook')
            .doc(postId);
        const query = await querySnapshot.get();
        console.log(query.data());
        query.ref.delete();
       
    })

exports.onBookUpdate = functions.firestore
    .document('posts/{postId}')
    .onUpdate(async(change,context)=>{
        var beforeData = change.before.data();
        var initialCategory = beforeData['category'];
        var afterData = change.after.data();
        var finalCategory = afterData['category'];
        const postId = context.params.postId;

        if(initialCategory!=finalCategory){
            console.log('category is changed');
            //delete the book in one category
            const querySnapshot = admin
                .firestore()
                .collection('categories')
                .doc(initialCategory)
                .collection('categoryBook')
                .doc(postId);
            const query = await querySnapshot.get();
            console.log(query.data());
            query.ref.delete();

            //add the book in another category
            const categoryRef = admin.firestore().collection('categories');
            categoryRef.doc(finalCategory).collection('categoryBook').doc(postId).set(afterData);
        }
        else{
            const querySnapshot = admin
                .firestore()
                .collection('categories')
                .doc(initialCategory)
                .collection('categoryBook')
                .doc(postId);
            const query = await querySnapshot.get();
            console.log(query.data());
            query.ref.update(afterData);
        }
        
    })


    


