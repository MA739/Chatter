import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:date_format/date_format.dart';

FirebaseService service = FirebaseService();

class RegistrationForm extends StatelessWidget {
  RegistrationForm({Key? key}) : super(key: key);
  //Controllers for first name, last name, etc
  //FNController, EController, PwController, bioController, homeController, ageController
  var fNController = TextEditingController();
  var eController = TextEditingController();
  var pwController = TextEditingController();
  var bioController = TextEditingController();
  var uNameController = TextEditingController();
  //variable for storing image selected by user
  //XFile? x_image;
  //var imageFile;
  //Image picker
  //final ImagePicker picker = ImagePicker();

//code snippet provided by: https://medium.com/fabcoding/adding-an-image-picker-in-a-flutter-app-pick-images-using-camera-and-gallery-photos-7f016365d856
  /*_imgFromGallery(BuildContext context) async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    x_image = image;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Image Selected. But it will not be pushed to firestore")));
    //upload image to firebase storage
    storage.ref().put(x_image)
    .then(snapshot => {
        console.log('Uploaded.');
  //imageFile = File(x_image?.path);
    });
  }*/

/*Future<Uri> uploadImageFile(XFile? image) async {
    var storageRef = storage.ref();
    UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(image).future;
    
    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri;
}*/

  Future<void> addUser(String fullName, String userName, String bio,
      String email, String pass, BuildContext context) async {
    // Call the user's Reference to add a new user
    bool errorThrown = true;
    try {
      UserCredential userCredential =
          await service.emailPassSignUp(email, pass);
      errorThrown = false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorThrown = true;
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("The password provided is too weak.")));
        //return;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("The account already exists for that email.")));
        errorThrown = true;
        //return;
      }
    } catch (e) {
      print(e);
      return;
    }
    //assuming everything went well with the email registration
    if (errorThrown == false && service.getCurrentUser() != null) {
      print('DATE' + DateTime.now().toString());
      var user = await service.getCurrentUser();
      String uid = user!.uid;

      //dateTime object
      var now = DateTime.now();
      var regisDate = formatDate(now, [mm, "/", dd, "/", yyyy]);
      service
          .getCollection('users')
          .doc(uid)
          .set({
            //'Email': Email, // xyz@gmail.com
            'FullName': fullName, //Ash Ketchum
            'Username': userName, // garchomp112
            'RegistrationDateTime':
                regisDate, //insert function to grab time/date, format it, and convert it to string
            'Bio': bio,
            'UID': uid,
            //'picture': defaultImageURL,
            //'Password': Pass
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
      Navigator.of(context).pop();
      //Navigator.of(context)..pop();

      //send popup showing that the user registered successfully. When the user clicks "ok", send them back to login page
      //} else {}
    }
  }

  @override
  //wall of textfields...
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: Center(
                    //padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0,),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
          const Padding(
              // Even Padding On All Sides
              padding: EdgeInsets.all(20.0)),
          TextField(
            controller: uNameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Username'),
          ),
          TextField(
            //scrollPadding: EdgeInsets.fromTLRB(0.0, 20.0, 0.0, 0.0),
            controller: fNController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Full Name'),
          ),

          TextField(
            controller: eController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Email'),
          ),
          TextField(
            controller: pwController,
            obscureText: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Password'),
          ),

          TextField(
            controller: bioController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Bio'),
          ),
          /*new ListTile(
              leading: new Icon(Icons.photo_library),
              title: new Text('Upload photo from library'),
              onTap: () {
                _imgFromGallery(context);
                //then display selected photo in preview
                //Navigator.of(context).pop();
              }),*/

          //child: CircleAvatar(
          /*CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xffFDCF09),
                    child: imageFile != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        //imageFile,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                        ),
                    ),
                  ),*/
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.black,
              //textStyle: const TextStyle(Fontweight.bold),
            ),
            //submit values to firestore
            onPressed: () => {
              //email/password authentication here

              //1constructor String FName, String LName, String Email, String Pass, --String UID--, --String Role--
              //user's data here
              //service.emailPassSignUp(EController.text, PwController.text),
              if (fNController.text == "" ||
                  eController.text == "" ||
                  pwController.text == "" ||
                  bioController.text == "" ||
                  uNameController.text == "")
                {
                  showDialog<String>(
                    //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                    //Otherwise send a popup that the login credentials were incorrect
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Status'),
                      content: const Text('Fill out all fields'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => {
                            //navigates back to login page
                            //Navigator.of(context)..pop()..pop()
                            Navigator.pop(context, 'OK'),
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  )
                }
              else
                {
                  addUser(
                      fNController.text,
                      uNameController.text,
                      bioController.text,
                      eController.text,
                      pwController.text,
                      context)
                },
            },
            child: const Text('Register'),
          )
        ])))));
  }
}
