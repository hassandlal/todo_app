import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archivedtasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/donetasks/done_tasks_screen.dart';
import 'package:todo_app/modules/newtasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  Database database;
  List<Widget> screens = [
    newTasksScreen(),
    doneTasksScreen(),
    archivedTasksScreen(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDataBase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((Error) {
        print('error ${Error.toString()}');
      });
    }, onOpen: (database) {
      getDataFromDataBase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }

  insertToDataBase(
      {@required String title,
      @required String time,
      @required String date}) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title, date, time,status) VALUES("$title", "$date", "$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDataBaseState());

        getDataFromDataBase(database);
      }).catchError((error) {
        print('error in insert');
      });
      return null;
    });
  }

  void getDataFromDataBase(databse)  {
    newTasks = [];
     doneTasks = [];
    archivedTasks = [];
    emit(AppGetDataBaseLoadingState());
    databse.rawQuery('SELECT * From Tasks').then((value) {

      value.forEach((element) {
        if(element['status']=='new')
          newTasks.add(element);
        else if(element['status']=='done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });
      emit(AppGetDataBaseState());
    });
  }

  void updateData({@required String status, @required int id}) async {
     database.rawUpdate(
      'UPDATE Tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDataBase(database);
      emit(AppUpdateDataBaseState());
     });
  }
  void deleteData({ @required int id}) async {
    database.rawDelete(
      'DELETE FROM Tasks WHERE id = ?',
      [id],
    ).then((value) {
      getDataFromDataBase(database);
      emit(AppDeleteDataBaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheeetState({@required isShow, @required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomNavBarState());
  }
}
