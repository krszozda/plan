import 'package:plan/presentation/features/start/start_bloc.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  static const String routeName = '/start';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StartBloc>(
      create: (context) => StartBloc(),
      child: _StartPage(),
    );
  }
}

class _StartPage extends StatefulWidget {
  const _StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<_StartPage> {
  StartBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<StartBloc>();
    _bloc?.add(StartInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<StartBloc, StartState>(
      listener: (context, state) {
        if (state is StartSuccess) {
          Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
        }
      },
      builder: (context, state) {
        if (state is StartLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container();
      },
    ));
  }
}