import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticketonline/Config.dart';
import 'package:ticketonline/pages/DashboardPage.dart';
import 'package:ticketonline/pages/InfoWidget.dart';
import 'package:ticketonline/pages/LoginPage.dart';
import 'package:ticketonline/pages/ResultWidget.dart';
import 'package:ticketonline/pages/SeatReservationWidget.dart';
import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/OccasionModel.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/TicketHelper.dart';
import 'package:ticketonline/services/ToastHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Config.supabase_url,
    anonKey: Config.anon_key,
  );
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(
      path: DashboardPage.ROUTE,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
    path: LoginPage.ROUTE,
    builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/:occasionLink',
      builder: (context, state) => MyHomePage(occasionLink: state.pathParameters["occasionLink"],),
    ),
  ],
);

TextStyle textStyleBig = TextStyle(fontWeight: FontWeight.w900, fontSize: 16);


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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(120, 55, 84, 98)),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.occasionLink});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? occasionLink;

  @override
  State<MyHomePage> createState() => _MyHomePageState(occasionLink);
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String title = "";
  int initialPrice = 0;
  int price = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  FormBuilder? formBuilder = const FormBuilder(child: Spacer());
  final _emailFieldKey = GlobalKey<FormBuilderFieldState>();
  final String? occasionLink;
  final Set<BoxModel> selectedSeats = {};

  OccasionModel? occasion;

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
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                const Image(image: AssetImage('assets/header.png')),
                const SizedBox(height: 12),
                HtmlWidget(occasion?.description??"",),
                const SizedBox(height: 32),
                formBuilder!,
                const SizedBox(height: 12),
                Text("Celková cena: $price Kč", style: textStyleBig,),
                const SizedBox(height: 12),
                HtmlWidget(occasion?.priceDescription??"",),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      TextInput.finishAutofillContext();
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        if (true) {
                          // // Either invalidate using Form Key
                          // _formKey.currentState?.fields['email']
                          //     ?.invalidate('Email already taken.');
                          // OR invalidate using Field Key
                          // _emailFieldKey.currentState?.invalidate('Email already taken.');
                          var email = _formKey.currentState?.fields[CustomerModel.emailColumn]!.value.toString().toLowerCase();
                          var name = _formKey.currentState?.fields[CustomerModel.nameColumn]!.value;
                          var surname = _formKey.currentState?.fields[CustomerModel.surnameColumn]!.value;
                          var note = _formKey.currentState?.fields[TicketModel.noteColumn]!.value;
                          var place = selectedSeats.firstOrNull;

                          var customer = CustomerModel(email: email, name: name, surname: surname);

                          var ticket = TicketModel(occasion: occasion!.id,
                              price: price,
                              note: note,
                              box: place,
                              options: [
                                _formKey.currentState?.fields["food"]!.value,
                                _formKey.currentState?.fields["taxi"]!.value
                              ]);
                          setState(() {
                            _isLoading = true;
                          });
                          await TicketHelper.sendTicketOrder(customer, ticket);
                          await showGeneralDialog(
                            context: context,
                            barrierColor: Colors.black12.withOpacity(0.6), // Background color
                            barrierDismissible: false,
                            barrierLabel: 'Dialog',
                            transitionDuration: const Duration(milliseconds: 300),
                            pageBuilder: (context, __, ___) {
                              return ResultWidget(ticketModel: ticket,);
                            },
                          );
                        }
                      }
                      debugPrint(_formKey.currentState?.value.toString());
                    },
                    child: const Text("Koupit vstupenku")
                ),
                const SizedBox(height: 12),
              ]
              ,
            ),
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void loadData() async {
    // await showGeneralDialog(
    //   context: context,
    //   barrierColor: Colors.black12.withOpacity(0.6), // Background color
    //   barrierDismissible: false,
    //   barrierLabel: 'Dialog',
    //   transitionDuration: const Duration(milliseconds: 300),
    //   pageBuilder: (context, __, ___) {
    //     return InfoWidget();
    //   },
    // );
    occasion = await DataService.getOccasionModelByLink(occasionLink??"");
    if(occasion == null)
    {
      occasion = (await DataService.getAllOccasions()).firstOrNull;
      if(occasion==null)
      {
        setState(() {
          title = "vstupenka.online";
        });
        ToastHelper.Show("událost nenalezena", severity: ToastSeverity.NotOk);
        return;
      }
    }
    title = occasion!.name??"";
    initialPrice = occasion!.price??0;
    price = initialPrice;

    var groups = await DataService.getAllOptionGroups(occasion!.id!);
    var taxis = groups.firstWhere((element) => element.id == 1);
    var foods = groups.firstWhere((element) => element.id == 2);

    var taxiOptions  = <FormBuilderFieldOption<OptionModel>>[];
    for (var element in taxis.options!) {
      taxiOptions.add(FormBuilderFieldOption<OptionModel>(value: element));
    }
    var taxiGroup = FormBuilderRadioGroup<OptionModel>(orientation: OptionsOrientation.vertical, initialValue: taxis.options!.first, name: taxis.code!, options: taxiOptions, decoration: InputDecoration(labelText: taxis.name!, labelStyle: textStyleBig),);

    var foodOptions  = <FormBuilderFieldOption<OptionModel>>[];
    for (var element in foods.options!) {
      foodOptions.add(FormBuilderFieldOption(value: element, child: Text(element.toStringWithPrice()),));
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
    var foodGroup = FormBuilderRadioGroup<OptionModel>(orientation: OptionsOrientation.vertical, initialValue: foods.options!.first, name: foods.code!, options: foodOptions, decoration: InputDecoration(labelText: foods.name!, labelStyle: textStyleBig),
    onChanged: chng,);

    formBuilder = FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              autofillHints: const [AutofillHints.givenName],
              name: CustomerModel.nameColumn,
              decoration: InputDecoration(labelText: 'Jméno', labelStyle: textStyleBig),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              autofillHints: const [AutofillHints.familyName],
              name: CustomerModel.surnameColumn,
              decoration: InputDecoration(labelText: 'Příjmení', labelStyle: textStyleBig),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              autofillHints: const [AutofillHints.email],
              key: _emailFieldKey,
              name: CustomerModel.emailColumn,
              decoration: InputDecoration(labelText: 'E-mail', labelStyle: textStyleBig),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(errorText: "Zadejte platný e-mail"),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: TicketModel.boxColumn,
              enableInteractiveSelection: false,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Místo k sezení', suffixIcon: Icon(Icons.event_seat), labelStyle: textStyleBig),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onTap: () async {
                var email = _formKey.currentState?.fields[CustomerModel.emailColumn]?.value;
                if(email == "admin")
                {
                  DataService.isEditor = true;
                }
                _formKey.currentState?.save();
                await showGeneralDialog(
                  context: context,
                  barrierColor: Colors.black12.withOpacity(0.6), // Background color
                  barrierDismissible: false,
                  barrierLabel: 'Dialog',
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, __, ___) {
                    return SeatReservationWidget(occasion: occasion, selectedSeats: selectedSeats);
                  },
                );
                _formKey.currentState?.fields[TicketModel.boxColumn]!.didChange(selectedSeats.firstOrNull?.toString());
              },
            ),
            const SizedBox(height: 10),
            foodGroup,
            const SizedBox(height: 10),
            taxiGroup,
            const SizedBox(height: 10),
            FormBuilderTextField(name: TicketModel.noteColumn, decoration: InputDecoration(labelText: "Poznámka", labelStyle: textStyleBig)),
          ],
        ));
    setState(() {});
  }
}
