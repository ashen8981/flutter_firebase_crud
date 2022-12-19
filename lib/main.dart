import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //firebase core library to initialized firebase app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title= "setup firebase";
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home:UserPage(),
      home:MyHomePage(),
    );
  }
}
//-------------------------
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  final controller= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('all users'),
      ),
      body: StreamBuilder<List<User>>(
        stream: readUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            return Text('there is an error ${snapshot.error}');
          }
          else if (snapshot.hasData) {
            final users = snapshot.data!;

            return ListView(
              children: users.map(buildUser).toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_circle),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserPage(),
            ));
          }),
    );
  }

  Widget buildUser(User user)=>ListTile(
    //leading: CircleAvatar(child: Text(user.age),),//===============================
    // leading:Text(user.age),
    title: Text(user.name),
    subtitle: Row(
      children: [
        Text(user.birthday),
      ],
    ),
  );


  Stream<List<User>> readUsers()=>FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot)=>
      snapshot.docs.map((doc)=>User.fromJson(doc.data())).toList());

}//-----newly }

class UserPage extends StatefulWidget {

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controllerName =TextEditingController();
  final controllerAge =TextEditingController();
  final controllerDate =TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: const BackButton(
          color: Colors.black, // <-- SEE HERE
        ),
        title:  const Text('Add a poll'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:   [
          TextField(
            controller: controllerName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your poll title',
            ),
          ),
          const SizedBox(height: 23),
          TextField(
            controller: controllerAge,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'option 1',
            ),
          ),
          const SizedBox(height: 23),
          TextField(
            controller: controllerDate,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'option 2',
            ),
          ),
          ElevatedButton(
            child: const Text('Enabled'),
            onPressed:(){
              final user= User(
                  name:controllerName.text,
                  age:controllerAge.text,
                  birthday:controllerDate.text
              );
              createUser(user);   //CreateUser method with user object

              // MaterialPageRoute(
              //     builder: (BuildContext context){ //seeeeeee
              //       return SecondScreen();
              //     });

            },
          ),
        ],
      ),
    );
  }
  InputDecoration decoration(String label)=>InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
  );
//delete


  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;


    final json =user.toJson();
    await docUser.set(json);
  }
}
//----------User class-----------
class User {
  String? id; //error found
  final String name;
  final String age;
  final String birthday;

  User({
    this.id = '',
    required this.name,
    required this.age,
    required this.birthday,
  });

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'age': age,
        'birthday': birthday,
      };

//to read data--

  static User fromJson(Map<String, dynamic> json) =>User(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    birthday: json['birthday'],
  );
}
