import 'package:flutter/material.dart';
import 'package:auth_app/conexion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

final User? user = FirebaseAuth.instance.currentUser;

class HomePage extends StatefulWidget {
  String email;
  HomePage({Key? key, required this.email}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Usuarios');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.email).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            drawer: Drawer(
              child: ListView(
                // un ListView puede tener multiples widgets
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data['imgUser']),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              child: const Text("Cerrar Sesion"),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();

                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const ConexionFirebase())));
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Colors.blueGrey,
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 239, 184, 16),
              title: const Center(
                child: Text('Registro de usuario a base'),
              ),
            ),
            body: ListView(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Text(
                        'Bienvenido Usuario:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data['imgUser']),
                    ),
                    Center(
                      child: Text(
                        "Nombre(s): ${data['firstName']}",
                        style: TextStyle(
                          fontSize: 20.0, // Tamaño de fuente
                          color: Colors.black, // Color de fuente
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Apellido(s): ${data['lastName']}",
                        style: TextStyle(
                          fontSize: 20.0, // Tamaño de fuente
                          color: Colors.black, // Color de fuente
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Correo Electrónico: ${widget.email}",
                        style: TextStyle(
                          fontSize: 10.0, // Tamaño de fuente
                          color: Colors.black, // Color de fuente
                        ),
                      ),
                    ),
                    /* Center(
                      child:user==null? Text("cargando datos"):Text("Correo Electrónico: ${user!.email}"),
                    ), */
                  ],
                ),
                /* TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ConexionFirebase()),
                    );
                  },
                  child: Text('Regresar al inicio de sesion'),
                ), */
              ],
            ),
          );
        }

        return Text("loading");
      },
    );
  }
}


/*  return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  'Hola Bienvenido !',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              Center(
                child: Text(widget.email),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ConexionFirebase()),
              );
            },
            child: Text('Regresar al inicio de sesion'),
          ),
        ],
      ),
    );
  } */
