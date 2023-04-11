import 'package:flutter/material.dart';
import 'package:flutter_database/data.dart';
import 'package:flutter_database/isar_service.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({
    Key? key,
    required this.service,
    this.task,
  }) : super(key: key);
  final IsarService service;
  final TaskEntity? task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Prority proritySelected;
  final TextEditingController _controller = TextEditingController();
  bool inputControllerFlage = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void changePrority(Prority prority) {
    setState(() {
      proritySelected = prority;
    });
  }

  final Map<String, List<dynamic>> prorityItem = {
    'low': [Prority.low, '0xff31D1F6'],
    'medium': [Prority.medium, '0xffFB8723'],
    'high': [Prority.high, '0xff7659FF']
  };

  @override
  void initState() {
    super.initState();
    final TaskEntity? task = widget.task;

    _controller.text = task?.name ?? '';
    proritySelected = task?.prority ?? Prority.low;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TaskEntity? task = widget.task;
    final List<Widget> prorityListItem = prorityItem.values
        .map((value) => ProrityItem(
            service: widget.service,
            item: value,
            prority: proritySelected,
            handelChange: changePrority))
        .toList();

    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 0,
          title: Text('Edit Task',
              style: TextStyle(
                  color: colorScheme.onSurface, fontWeight: FontWeight.w800)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () {
            final TaskEntity taskEntity = TaskEntity();
            if (_formKey.currentState!.validate()) {
              taskEntity
                ..name = _controller.text
                ..isCompletd = task?.isCompletd ?? false
                ..prority = proritySelected
                ;
              if (task == null) {
                widget.service.saveTask(taskEntity);
              } else {
                widget.service.editTask(task.id, taskEntity);
              }
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            }
          },
          label: Row(children: [
            Text(task == null ? 'save change' : 'Edit Task',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 10),
            Container(
                decoration: BoxDecoration(
                    color: const Color(0xff9073FD),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.done, color: Colors.white))
          ]),
        ),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: prorityListItem)),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Form(
              key: _formKey,
              child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'task is not allowed to save';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add a task for todays...',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  )),
            ),
          )
        ]));
  }
}

class ProrityItem extends StatelessWidget {
  const ProrityItem(
      {Key? key,
      required this.item,
      required this.prority,
      required this.handelChange,
      required this.service})
      : super(key: key);

  final List<dynamic> item;
  final Prority prority;
  final Function handelChange;
  final IsarService service;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: () => handelChange(item[0]),
        child: Container(
            width: 110,
            height: 35,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(2, 2),
              )
            ]),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item[0].toString().substring(8),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        color: Color(int.parse(item[1])),
                        borderRadius: BorderRadius.circular(20)),
                    child: prority == item[0]
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null)
              ],
            ))),
      ),
    );
  }
}
