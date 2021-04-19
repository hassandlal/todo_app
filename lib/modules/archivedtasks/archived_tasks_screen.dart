import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';


class archivedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      builder:(context,state){
        var tasks= AppCubit.get(context).archivedTasks;
        return tasksBuilder(tasks:tasks);
      } ,
      listener: (context,state){},
    );
  }
}
