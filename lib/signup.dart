import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auth_app/conexion.dart';
import 'package:auth_app/pantallaprin.dart';
import 'package:auth_app/subirimg.dart';
import 'package:auth_app/image.dart';
import 'package:auth_app/login.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? mensajeError = "";
  File? imagen_to_upload;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 239, 184, 16),
        title: const Center(child:  Text('Inicio de sesion'),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Center(
            child: Text(
              "Registrar nuevo usuario y datos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children:[
              CircleAvatar(
                radius: 60, // Tamaño del círculo
                backgroundImage: const NetworkImage('https://imgs.search.brave.com/E2wWV-XQE5MK86b8cup97hVsZS7rUrtKje6tFJ5O308/rs:fit:1200:1200:1/g:ce/aHR0cDovL2NvbG9t/Ymlhc2luZnJvbnRl/cmFzcnV0YXMuY29t/L1J1dGElMjBwYXJh/JTIwdmFsaWRhciUy/MGVsJTIwYmFjaGls/bGVyYXRvJTIwZW4l/MjBDb2xvbWJpYSUy/MHklMjBwcmVzZW50/YXIlMjBsYXMlMjBw/cnVlYmFzJTIwU2Fi/ZXIlMjAxMS9pbWcv/cmVnaXN0cm8ucG5n'),
                backgroundColor: Colors.blueGrey,
                )]
          ),
          Center(
            child: Text(
              mensajeError!,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    final imagen = await getImage();
                    setState(() {
                      imagen_to_upload = File(imagen!.path);
                    });
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(Size(50, 10)), // Cambia el tamaño fijo
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)), // Ajusta el padding
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Cambia el color de fondo
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Cambia el color del texto
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Imagen de perfil "), Icon(Icons.image_search)],
                  )),
            ],
          ),
          Container(
            child: (imagen_to_upload != null
                ? Image.file(imagen_to_upload!)
                : SizedBox()),
          ),
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: 'Nombre(s)',
            ),
          ),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(
              labelText: 'Apellidos',
            ),
          ),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
            ),
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  if ((firstNameController.text == "") ||
                      (lastNameController.text == "") ||
                      (emailController.text == "") ||
                      (passwordController.text == "") ||
                      (imagen_to_upload == null)) {
                    setState(() {
                      mensajeError = "Favor de llenar los datos completos";
                    });
                  } else {
                    addNewUser();
                  }
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(Size(50, 10)), // Cambia el tamaño fijo
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)), // Ajusta el padding
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Cambia el color de fondo
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Cambia el color del texto
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),),
                   ),
                 ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Registrar"), Icon(Icons.assignment_add)],
                  )),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ConexionFirebase()),
              );
            },
            child: Text('En caso de estar registrado, Inicia sesión',style: TextStyle(color: Colors.white, fontSize: 10),),
          ),
        ],
      ),
    );
  }

  void addNewUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      User? user = userCredential.user;

      /* Subir la imagen de perfil a Storage */
      Reference ref =
          FirebaseStorage.instance.ref().child('perfl/${user!.uid}');
      UploadTask uploadTask = ref.putFile(imagen_to_upload!);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      /* agreggar informacion */
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(emailController.text)
          .set({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'imgUser': downloadUrl,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {}
  }

  void addImgUser(String email) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Usuarios');
    final Reference ref = FirebaseStorage.instance.ref().child('images/$email');
    String urlImg = await ref.getDownloadURL();

    users.doc(email).set({'imgUser': urlImg}, SetOptions(merge: true));
  }

  void addUserFirestore(
      String firstName, String lastName, String email, String password) {
    CollectionReference users = FirebaseFirestore.instance.collection('Usuarios');

    users.doc(email).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
  }

  signUp() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      setState(() {
        mensajeError = e.message;
      });
    }
  }
}


  /* 

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        print(e.message);
      }
    }
  }
*/