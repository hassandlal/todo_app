import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField(
        {@required TextEditingController controller,
        @required TextInputType type,
        Function onSubmit,
        Function onChange,
        bool isPassword = false,
        @required Function validate,
        @required String label,
        IconData suffix,
        Function onTap,
        @required IconData prefix}) =>
    TextFormField(
      validator: validate,
      onTap: onTap,
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      obscureText: isPassword,
      decoration: InputDecoration(
        suffixIcon: suffix != null ? Icon(suffix) : null,
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        border: OutlineInputBorder(),
      ),
    );

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
  key: Key(model['id'].toString()),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(id: model['id']);
  },
  child:   Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
                icon: Icon(
                  Icons.check_box,
                  color: Colors.green,
                ),
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: 'done', id: model['id']);
                }),
            IconButton(
                icon: Icon(
                  Icons.archive,
                  color: Colors.black45,
                ),
                onPressed: () { AppCubit.get(context)
                    .updateData(status: 'archive', id: model['id']);})
          ],
        ),
      ),
);
Widget tasksBuilder({@required List<Map> tasks})=>ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
      itemBuilder: (context, index) =>
          buildTaskItem(tasks[index], context),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
      itemCount: tasks.length),
  fallback: (context) => Center(
    child: Column(
      children: [
        Icon(
          Icons.menu,
          size: 100,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet Please Add Some Tasks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    ),
  ),
);