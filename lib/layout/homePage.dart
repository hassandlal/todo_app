import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class homePage extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDataBaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            body: ConditionalBuilder(
              condition: state is! AppGetDataBaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState.validate()) {
                    cubit.insertToDataBase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                          (context) => Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(20),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      defaultFormField(
                                          controller: titleController,
                                          type: TextInputType.text,
                                          validate: (value) {
                                            if (value.isEmpty) {
                                              return 'task name mustn\'t be empty';
                                            } else {
                                              return null;
                                            }
                                          },
                                          label: 'Task Title',
                                          prefix: Icons.title),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      defaultFormField(
                                          onTap: () {
                                            showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now())
                                                .then((value) {
                                              timeController.text = value
                                                  .format(context)
                                                  .toString();
                                            });
                                          },
                                          controller: timeController,
                                          type: TextInputType.text,
                                          validate: (value) {
                                            if (value.isEmpty) {
                                              return 'task time mustn\'t be empty';
                                            } else {
                                              return null;
                                            }
                                          },
                                          label: 'Task Time',
                                          prefix: Icons.watch_later_outlined),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      defaultFormField(
                                          onTap: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.parse(
                                                        '2021-05-03'))
                                                .then((value) {
                                              dateController.text =
                                                  DateFormat.yMMMd()
                                                      .format(value);
                                            });
                                          },
                                          controller: dateController,
                                          type: TextInputType.datetime,
                                          validate: (value) {
                                            if (value.isEmpty) {
                                              return 'task date mustn\'t be empty';
                                            } else {
                                              return null;
                                            }
                                          },
                                          label: 'Task Date',
                                          prefix: Icons.calendar_today),
                                    ],
                                  ),
                                ),
                              ),
                          elevation: 20)
                      .closed
                      .then((value) {
                    cubit.changeBottomSheeetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheeetState(isShow: true, icon: Icons.add);
                }
              },
            ),
            appBar: AppBar(
              centerTitle: false,
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              currentIndex: AppCubit.get(context).currentIndex,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'tasks'),
                BottomNavigationBarItem(icon: Icon(Icons.check), label: 'done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive), label: 'archived'),
              ],
            ),
          );
        },
      ),
      create: (context) => AppCubit()..createDataBase(),
    );
  }
}
