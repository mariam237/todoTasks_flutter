import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskListPage(),
    );
  }
}

class Task {
  String description;
  bool isCompleted;

  Task({required this.description, this.isCompleted = false});
}

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo Tasks'),
        backgroundColor: Color.fromARGB(255, 245, 168, 194),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskInsightsPage(tasks)),
              );
            },
          ),
        ],
      ),
      body:
      tasks.length==0? Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        color: Color.fromARGB(255, 187, 187, 187),
        child: Text("No tasks added yet, To add tasks use the plus button", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),)):
       ReorderableListView(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        onReorder: _onReorder,
        children: List.generate(
          tasks.length,
          (index) {
            return Card(
              color: Color.fromARGB(255, 187, 187, 187),
              key: Key('$index'),
              elevation: 8,
              margin: EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Checkbox(
                  activeColor: Colors.green,
                  value: tasks[index].isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      tasks[index].isCompleted = value ?? false;
                    });
                  },
                ),
                title: Text(
                  tasks[index].description,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: tasks[index].isCompleted ? Colors.grey[600] : Colors.black,
                    decoration: tasks[index].isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
                onTap: () => _editTask(index),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 245, 168, 194),
        tooltip: 'Add Task',
        elevation: 10,
      ),
    );
  }

  void _addTask() {
    setState(() {
      tasks.add(Task(description: 'New Task'));
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _editTask(int index) {
    TextEditingController taskController = TextEditingController(text: tasks[index].description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(
              hintText: 'Enter new task description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 245, 168, 194), // Set the background color here
            ),
            child: Text('Save', style: TextStyle(color: Colors.black),),
            onPressed: () {
              setState(() {
                tasks[index].description = taskController.text;
              });
              Navigator.of(context).pop();
            },
          ),

          ],
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });
  }
}

class TaskInsightsPage extends StatelessWidget {
  final List<Task> tasks;

  TaskInsightsPage(this.tasks);

  @override
  Widget build(BuildContext context) {
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    int pendingTasks = tasks.length - completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Insights'),
        backgroundColor: Color.fromARGB(255, 245, 168, 194),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: completedTasks.toDouble(),
                        title: 'Completed ${(completedTasks/tasks.length*100).toInt()}%',
                        radius: 120,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: pendingTasks.toDouble(),
                     title: 'Pending ${(pendingTasks / tasks.length * 100).toInt()}%',
                        radius: 120,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 0,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Total Tasks: ${tasks.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Completed Tasks: $completedTasks',
                style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Text(
                'Pending Tasks: $pendingTasks',
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
