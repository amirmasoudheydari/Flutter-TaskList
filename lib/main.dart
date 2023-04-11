import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_database/data.dart';
import 'package:flutter_database/isar_service.dart';
import 'package:isar/isar.dart';

import 'edit.dart';

void main() async {
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794cff);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Color seconderyTextColor = const Color(0xffafbed0);
    const Color primaryTextColor = Color(0xff1d2830);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: const Color(0xffF3F4FB),
          textTheme: const TextTheme(),
          colorScheme: const ColorScheme.light(
              primary: primaryColor,
              primaryContainer: Color(0xff5c0aff),
              onPrimary: Color(0xfff3f5f8),
              secondary: primaryColor,
              onSecondary: Colors.white,
              onSurface: primaryTextColor,
              background: Color(0xffF3F4FB),
              onBackground: primaryTextColor),
          appBarTheme: const AppBarTheme(
              backgroundColor: primaryColor,
              systemOverlayStyle: SystemUiOverlayStyle())),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  final IsarService service = IsarService();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();
  String search = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 120,
            title: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('To Do List',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: colorScheme.onPrimary)),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.assessment_outlined, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  height: 50,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    textAlignVertical: TextAlignVertical.bottom,
                    onChanged: (text) {
                      setState(() {
                        search = text;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                        prefixIcon: InkWell(
                          child: const Icon(Icons.search),
                          onTap: () {},
                        ),
                        hintText: 'Search Tasks',
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                  ),
                )
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: colorScheme.primary,
          extendedPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                      service: widget.service,
                    )));
          },
          label: Row(children: [
            const Text('Add New Task', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Container(
                decoration: BoxDecoration(
                    color: const Color(0xff9073FD),
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.add, color: Colors.white))
          ]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        Container(
                            width: 70,
                            height: 3,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                            )),
                      ],
                    ),
                    FilledButton(
                        onPressed: () async {
                          await widget.service.deleteAllTasks();
                        },
                        style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                Color.fromARGB(255, 255, 255, 255)),
                            foregroundColor: const MaterialStatePropertyAll(
                                Color.fromARGB(255, 134, 137, 142)),
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)))),
                        child: Row(children: const [
                          Text('Delete All'),
                          SizedBox(width: 5),
                          Icon(Icons.delete)
                        ]))
                  ]),
            ),
            StreamBuilder<List<TaskEntity>>(
              stream: widget.service.getAllTask(search: search),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TaskEntity>> snapShot) {
                bool active =
                    snapShot.connectionState == ConnectionState.done ||
                        snapShot.connectionState == ConnectionState.active;
                bool wating =
                    snapShot.connectionState == ConnectionState.waiting;

                if (snapShot.data!.isEmpty) {
                  return EmptyState(themeData: themeData);
                }

                if (wating) {
                  return const CircularProgressIndicator();
                } else if (active) {
                  if (snapShot.hasError) {
                    return const Text('throw Erro');
                  } else if (snapShot.hasData) {
                    return Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.all(10),
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 10,
                              ),
                          itemCount: snapShot.data!.length,
                          itemBuilder: (context, index) {
                            return ListItemView(
                                task: snapShot.data![index],
                                service: widget.service);
                          }),
                    );
                  }
                }

                return Container();
              },
            ),
          ],
        ));
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/img/reclaim-tasks.png', height: 300),
        const Text('Task List Is Empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400))
      ],
    );
  }
}

class ListItemView extends StatelessWidget {
  const ListItemView({Key? key, required this.task, required this.service})
      : super(key: key);
  final TaskEntity task;
  final IsarService service;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const Map<String, Color> taskColor = {
      'Prority.low': Color(0xff31D1F6),
      'Prority.medium': Color(0xffFB8723),
      'Prority.high': Color(0xff7659FF)
    };

    return Container(
      width: 420,
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Row(children: [
        InkWell(
          onTap: () async {
            await service.changeCompletd(task.id);
          },
          child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(left: 15, right: 15),
              padding: (!task.isCompletd) ? const EdgeInsets.all(2.5) : null,
              decoration: BoxDecoration(
                color: const Color(0xffF1F1F1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                  decoration: BoxDecoration(
                    color: task.isCompletd ? colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: task.isCompletd
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null)),
        ),
        Expanded(
            child:
                Text(task.name, style: Theme.of(context).textTheme.bodyLarge)),
        TextButton(
            style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(Size(10, 10))),
            child: const Text('Edit', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditTaskScreen(task: task, service: service)));
            }),
        IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await service.deleteTask(task.id);
            },
            icon: const Icon(Icons.delete)),
        Container(
            width: 10,
            height: double.infinity,
            decoration: BoxDecoration(
                color: taskColor[task.prority.toString()],
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))))
      ]),
    );
  }
}
