import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controller/user_controller.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/model/category.dart';
import 'package:todo_app/model/edit_task_model.dart';

import 'package:todo_app/model/task.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/extensions.dart';
import 'package:todo_app/view/widget/dialog_content.dart';

class TaskController extends GetxController {
  final EditTaskModel? editTaskModel;
  TaskController({this.editTaskModel});
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final GlobalKey<FormState> categoryKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  DateTime? selectedTime;

  static String formattedDate(
      {String? dateFormate = 'E, MMM d yyyy', required String dateString}) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat(dateFormate).format(date);
    return formattedDate;
  }

  static String formatTime(
      {required DateTime time, String? dateFormate = 'hh:mm a'}) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat(dateFormate).format(dateTime);
  }

  void disposePage() {
    titleController.clear();
    descriptionController.clear();
    dateInput.text = DateFormat('E, MMM d yyyy').format(DateTime.now());
    timeInput.text = DateFormat('hh:mm a').format(DateTime.now());
    selectedTime = null;
    selectedDate = null;
  }

  RxList<TaskCategory> defaultCategories = [
    TaskCategory(
      name: 'Personal',
      color: 0xff42A5F5,
    ),
    TaskCategory(
      name: 'Work',
      color: 0xff607D8B,
    ),
    TaskCategory(
      name: 'Sports',
      color: 0xff4CAF50,
    ),
    TaskCategory(
      name: 'Study',
      color: 0xffFF9800,
    ),
    TaskCategory(
      name: 'Health',
      color: 0xffF44336,
    ),
    TaskCategory(
      name: 'Entertainment',
      color: 0xff41CF9F,
    ),
    TaskCategory(
      name: 'Finance',
      color: 0xff3F51B5,
    ),
  ].obs;

  RxString selectedPriority = 'Low Priority'.obs;
  RxBool isRemind = true.obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateInput = TextEditingController(
      text: DateFormat('E, MMM d yyyy').format(DateTime.now()));

  final timeInput =
      TextEditingController(text: formatTime(time: DateTime.now()));

  final categoryName = TextEditingController();

  final chipIndex = 0.obs;

  Rx<int> selectedColor = 0xff778CDD.obs;
  RxInt buttonIndex = 0.obs;

  void selectCategory(String name, int color) {
    defaultCategories.add(TaskCategory(color: color, name: name));
    Get.back();
    selectedColor.value = 0xff778CDD;
    buttonIndex.value = 0;
    categoryName.clear();
    selectedDate = null;
  }

  deleteCategory(int index, id) async {
    if (index > 6) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("Categories")
          .doc(id)
          .delete();
    } else {
      null;
    }
  }

  void deleteTask(String id) async {
    try {
      final taskRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("Tasks")
          .doc(id);
      await taskRef.delete();
      Get.back();
      Fluttertoast.showToast(
          msg: "Task has been deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Failed to delete task",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  createCategory(TaskCategory category) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    final taskRef = firestore
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .collection("Categories")
        .doc();
    try {
      await taskRef.set({
        'name': category.name,
        'color': category.color,
      }).then((_) {
        categoryName.clear();
        selectedColor.value = 0xff778CDD;
        buttonIndex.value = 0;
      });
      Get.back();
      Fluttertoast.showToast(
          msg: "Category created successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } on FirebaseAuthException {
      Fluttertoast.showToast(
          msg: "Failed to create category",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String? categoryFieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter category name';
    } else {
      return null;
    }
  }

  Future displayDatePicker(BuildContext context) async {
    final initialDate = selectedDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: darkBlue,
                ),
              ),
              colorScheme: const ColorScheme.dark(
                onSurface: blue,
                primary: black,
                onPrimary: darkBlue,
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1950),
        lastDate: DateTime(2100));
    if (pickedDate != null) {
      selectedDate = pickedDate;
      dateInput.text = formattedDate(dateString: pickedDate.toIso8601String());
    } else {}
  }

  Future displayTimePicker(
      BuildContext context, TextEditingController timeInput) async {
    TimeOfDay? initialTime;

    initialTime = selectedTime != null
        ? TimeOfDay(hour: selectedTime!.hour, minute: selectedTime!.minute)
        : TimeOfDay.now();

    TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (pickedTime != null) {
      selectedTime = timeOfDayToDateTime(pickedTime);
      timeInput.text = formatTime(time: timeOfDayToDateTime(pickedTime));
    }
  }

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: black,
          surfaceTintColor: black,
          title: const Text(
            'Create Category',
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(
            color: white,
            fontSize: 24,
          ),
          content: const DialogContent(),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: darkBlue),
              child: const Text('Cancle'),
              onPressed: () {
                Navigator.of(context).pop();
                selectedColor.value = 0xff778CDD;
                buttonIndex.value = 0;
                categoryName.clear();
              },
            ),
            TextButton(
                style: TextButton.styleFrom(foregroundColor: darkBlue),
                child: const Text('Create'),
                onPressed: () {
                  if (categoryKey.currentState!.validate()) {
                    final category = TaskCategory(
                        color: selectedColor.value, name: categoryName.text);
                    createCategory(category);
                  }
                }),
          ],
        );
      },
    );
  }

  Future<void> createTask({
    required BuildContext context,
    required String title,
    String? description,
    required TaskCategory category,
    required String priority,
    required bool isRemind,
    required List<String> subTasks,
  }) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: darkBlue,
                  ),
                  SizedBox(
                    height: 3.0.wp,
                  ),
                  const Text(
                    "Creating...",
                    style: TextStyle(color: blue),
                  )
                ],
              ),
            ));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    final taskRef = FirebaseAuth.instance.currentUser!.isAnonymous
        ? firestore
            .collection("Guest")
            .doc(await UserController.getId())
            .collection("Tasks")
            .doc()
        : firestore
            .collection("Users")
            .doc(auth.currentUser!.uid)
            .collection("Tasks")
            .doc();
    final task = Task(
      id: taskRef.id,
      title: title,
      date: selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      description: description == '' ? null : description,
      time: selectedTime?.toIso8601String() ??
          timeOfDayToDateTime(TimeOfDay.now()).toIso8601String(),
      category: category,
      priority: priority,
      isRemind: isRemind,
      subTasks: subTasks,
      createdOn: FieldValue.serverTimestamp(),
    );

    try {
      await taskRef.set({
        'id': taskRef.id,
        'createdOn': task.createdOn,
        'title': task.title,
        'date': task.date,
        'description': task.description,
        'time': task.time,
        'categoryName': task.category.name,
        'categoryColor': task.category.color.toString(),
        'priority': task.priority,
        'isRemind': task.isRemind,
        'subTasks': task.subTasks,
      });
      await Fluttertoast.showToast(
          msg: "Task created successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } on FirebaseAuthException {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      Fluttertoast.showToast(
          msg: "Failed to create task",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  @override
  void onInit() {
    titleController.text = editTaskModel?.title ?? '';
    dateInput.text = editTaskModel?.date != null
        ? formattedDate(dateString: editTaskModel!.date)
        : DateFormat('E, MMM d yyyy').format(DateTime.now());
    timeInput.text = formatTime(
        time: editTaskModel?.time != null
            ? DateTime.parse(editTaskModel!.time)
            : DateTime.now());
    descriptionController.text = editTaskModel?.description ?? '';
    selectedPriority.value = editTaskModel?.priorities ?? 'Low Priority';
    isRemind.value = editTaskModel?.isRemind ?? true;

    super.onInit();
  }

  updateTask() {
    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // FirebaseAuth auth = FirebaseAuth.instance;
    // final taskRef = FirebaseAuth.instance.currentUser!.isAnonymous
    //     ? firestore
    //         .collection("Guest")
    //         .doc(UserController.getId())
    //         .collection("Tasks")
    //         .doc()
    //     : firestore
    //         .collection("Users")
    //         .doc(auth.currentUser!.uid)
    //         .collection("Tasks")
    //         .doc();
  }
}
