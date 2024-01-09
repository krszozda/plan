import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (BuildContext _) => AuthPage();
            break;
          case '/salesman_dashboard':
            builder = (BuildContext _) => SalesmanDashboardPage();
            break;
          case '/manager_dashboard':
            builder = (BuildContext _) => ManagerDashboardPage();
            break;
          case '/proposal_description':
            final proposal = settings.arguments as Proposal;
            builder = (BuildContext _) => ProposalDescriptionPage(proposal: proposal);
            break;
          case '/tasks_description':
            builder = (BuildContext _) => TasksDescriptionPage();
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}