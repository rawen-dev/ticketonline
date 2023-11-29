import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/TicketHelper.dart';
import 'package:ticketonline/services/ToastHelper.dart';

final _router = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => MyHomePage(title: "vstupenka.online"),
    ),
    GoRoute(
      path: '/event',
      builder: (context, state) => MyHomePage(title: "vstupenka.online", occasionLink: "skautskyples",),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zsyryiiwkcpjhtdptdhp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzeXJ5aWl3a2Nwamh0ZHB0ZGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDEwOTQzODYsImV4cCI6MjAxNjY3MDM4Nn0.ZeF5HXnaq8A5amCfEQFrXqJ-X1IwqpTIRHRShv-gezE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ticketonline',
      routerConfig: _router,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'ticketonline'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.occasionLink});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String? occasionLink;

  @override
  State<MyHomePage> createState() => _MyHomePageState(occasionLink);
}

class _MyHomePageState extends State<MyHomePage> {

  int initialPrice = 300;
  int price = 300;
  final _formKey = GlobalKey<FormBuilderState>();
  FormBuilder? formBuilder = const FormBuilder(child: Spacer());
  final _emailFieldKey = GlobalKey<FormBuilderFieldState>();
  final String? occasionLink;

  _MyHomePageState(this.occasionLink);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              children: [ formBuilder!, Text("Cena: $price") ]
              ,
            ),
          ),
        ),
        ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void loadData() async {
    var bs = Uri.base;
    var path = bs.path.substring(1);
    var occasion = await DataService.getOccasionModelByLink("skautskyples"??"");
    if(occasion==null)
    {
      ToastHelper.Show("událost nenalezena", severity: ToastSeverity.NotOk);
      return;
    }
    var groups = await DataService.getAllOptionGroups(occasion.id!);
    var taxis = groups.firstWhere((element) => element.id == 1);
    var foods = groups.firstWhere((element) => element.id == 2);

    var taxiOptions  = <FormBuilderFieldOption<OptionModel>>[];
    for (var element in taxis.options!) {
      taxiOptions.add(FormBuilderFieldOption<OptionModel>(value: element));
    }
    var taxiGroup = FormBuilderRadioGroup<OptionModel>(initialValue: taxis.options!.first, name: taxis.code!, options: taxiOptions, decoration: InputDecoration(labelText: taxis.name!),);

    var foodOptions  = <FormBuilderFieldOption<OptionModel>>[];
    for (var element in foods.options!) {
      foodOptions.add(FormBuilderFieldOption(value: element));
    }

    chng(OptionModel? option)
    {
      if(option==null)
      {
        return;
      }
      var endPrice = initialPrice;
      endPrice += option.price??0;
      setState(() {
        price = endPrice;
      });
    }
    var foodGroup = FormBuilderRadioGroup<OptionModel>(initialValue: foods.options!.first, name: foods.code!, options: foodOptions, decoration: InputDecoration(labelText: foods.name!),
    onChanged: chng,);

    formBuilder = FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(labelText: 'Jméno'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'surname',
              decoration: const InputDecoration(labelText: 'Příjmení'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              key: _emailFieldKey,
              name: 'email',
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(errorText: "Zadejte platný e-mail"),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'place',
              decoration: const InputDecoration(labelText: 'Místo k sezení'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            foodGroup,
            const SizedBox(height: 10),
            taxiGroup,
            const SizedBox(height: 10),
            MaterialButton(
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  if (true) {
                    // // Either invalidate using Form Key
                    // _formKey.currentState?.fields['email']
                    //     ?.invalidate('Email already taken.');
                    // OR invalidate using Field Key
                    // _emailFieldKey.currentState?.invalidate('Email already taken.');
                    var email = _formKey.currentState?.fields['email']!.value;
                    var name = _formKey.currentState?.fields['name']!.value;
                    var surname = _formKey.currentState?.fields['surname']!.value;

                    var customer = CustomerModel(email: email, name: name, surname: surname);

                    var ticket = TicketModel(occasion: occasion.id, price: price, options: [
                      _formKey.currentState?.fields[groups[0].code]!.value,
                      _formKey.currentState?.fields[groups[1].code]!.value
                    ]);
                    await TicketHelper.sendTicketOrder(customer, ticket);
                  }
                }
                debugPrint(_formKey.currentState?.value.toString());
              },
              child:
              const Text("Koupit lístek", style: TextStyle(color: Colors.white)),
            )
          ],
        ));
    setState(() {});
  }
}
