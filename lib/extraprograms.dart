import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Async & Await Example')),
        body: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String message = 'Press the button to fetch data';

  // Async function to simulate data fetching
  Future<void> fetchData() async {
    setState(() {
      message = 'Fetching data...';
    });

    // Simulate a 2-second delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      message = 'Data fetched successfully!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchData, // Call the async function when button is pressed
            child: Text('Fetch Data'),
          ),
        ],
      ),
    );
  }
}





//
// //update data
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('SQLite Update Example')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               final dbHelper = DatabaseHelper();
//
//               // Inserting an employee
//               Employee employee = Employee(name: 'Alice', age: 30, department: 'HR');
//               await dbHelper.insertEmployee(employee);
//
//               // Updating Alice's age
//               Employee updatedEmployee = Employee(id: 1, name: 'Alice', age: 31, department: 'HR');
//               await dbHelper.updateEmployee(updatedEmployee);
//
//               // Optionally, retrieve and print all employees to verify update
//               final db = await dbHelper.database;
//               List<Map<String, dynamic>> employees = await db.query('employees');
//
//               for (var emp in employees) {
//                 print(Employee.fromMap(emp));
//               }
//             },
//             child: Text('Update Employee'),
//           ),
//         ),
//       ),
//     );
//   }
// }


//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('SQLite Delete Example')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               final dbHelper = DatabaseHelper();
//
//               // Inserting an employee
//               Employee employee = Employee(name: 'Alice', age: 30, department: 'HR');
//               await dbHelper.insertEmployee(employee);
//
//               // Inserting another employee to delete later
//               Employee employeeToDelete = Employee(name: 'Bob', age: 25, department: 'Engineering');
//               await dbHelper.insertEmployee(employeeToDelete);
//
//               // Deleting Bob's record
//               await dbHelper.deleteEmployee(2); // Assuming Bob's ID is 2
//
//               // Optionally, retrieve and print all employees to verify deletion
//               final db = await dbHelper.database;
//               List<Map<String, dynamic>> employees = await db.query('employees');
//
//               for (var emp in employees) {
//                 print(Employee.fromMap(emp));
//               }
//             },
//             child: Text('Delete Employee'),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Popup Title'),
                    content: Text('This is a simple popup message.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Show Popup'),
          ),
        ),
      ),
    );
  }
}



//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         drawer: Drawer(
//           child: ListView(
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(color: Colors.blue),
//                 child: Text(
//                   'Drawer Header',
//                   style: TextStyle(color: Colors.white, fontSize: 24),
//                 ),
//               ),
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: Text('Home'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.settings),
//                 title: Text('Settings'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.logout),
//                 title: Text('Logout'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: Center(
//           child: Text('Swipe from the left or tap the icon to open the drawer.'),
//         ),
//       ),
//     );
//   }
// }
