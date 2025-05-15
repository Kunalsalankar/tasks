import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  DateTime _selectedDate = DateTime.now();
  bool _isFilteringByDate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TaskBloc>().add(FetchTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Open date picker to select a date filter
  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isFilteringByDate = true;
      });
    }
  }

  // Clear date filter
  void _clearDateFilter() {
    setState(() {
      _isFilteringByDate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskOperationSuccess) {
                  _showSnackBar(state.message);
                } else if (state is TaskError) {
                  _showSnackBar(state.message);
                }
              },
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is TasksLoaded) {
                  return _buildTaskListView(state.tasks);
                } else if (state is TaskError) {
                  return _buildErrorView(state.message);
                } else {
                  return _buildEmptyView();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Manager',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your tasks efficiently',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Icon(
                          state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: state.isDarkMode,
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                          activeColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Add New Task'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskFormScreen()),
              );
            },
          ),
      
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Tasks'),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(FetchTasks());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: _isSearching
          ? TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search tasks...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      )
          : const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        // Theme toggle button
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: state.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            );
          },
        ),
        // Search button
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = "";
              }
            });
          },
        ),
        // Date filter button
        IconButton(
          icon: Icon(_isFilteringByDate ? Icons.filter_alt : Icons.filter_alt_outlined),
          tooltip: 'Filter by date',
          onPressed: () {
            if (_isFilteringByDate) {
              _clearDateFilter();
            } else {
              _showDatePicker();
            }
          },
        ),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<TaskBloc>().add(FetchTasks());
          },
        ),
      ],
    );
  }

  Widget _buildTaskListView(List<Task> allTasks) {
    // Filter tasks based on search query and date filter
    final List<Task> filteredTasks = allTasks.where((task) {
      // Text search filter
      bool matchesSearchQuery = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Date filter
      bool matchesDateFilter = !_isFilteringByDate ||
          (task.dueDate != null &&
              DateFormat('yyyy-MM-dd').format(task.dueDate!) ==
                  DateFormat('yyyy-MM-dd').format(_selectedDate));

      return matchesSearchQuery && matchesDateFilter;
    }).toList();

    return TabBarView(
      controller: _tabController,
      children: [
        // All Tasks
        _buildTaskList(filteredTasks),
        // Active Tasks
        _buildTaskList(filteredTasks.where((task) => !task.isCompleted).toList()),
        // Completed Tasks
        _buildTaskList(filteredTasks.where((task) => task.isCompleted).toList()),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyFilteredView();
    }

    // Split tasks into those with due dates and those without
    final tasksWithDueDate = tasks.where((task) => task.dueDate != null).toList();
    final tasksWithoutDueDate = tasks.where((task) => task.dueDate == null).toList();

    // Group tasks by date
    final groupedTasks = <String, List<Task>>{};
    for (final task in tasksWithDueDate) {
      final String groupKey = DateFormat('yyyy-MM-dd').format(task.dueDate!);

      if (!groupedTasks.containsKey(groupKey)) {
        groupedTasks[groupKey] = [];
      }
      groupedTasks[groupKey]!.add(task);
    }

    // Sort the keys so that the nearest due dates appear first
    final sortedKeys = groupedTasks.keys.toList()..sort();

    // Count items for ListView builder
    int itemCount = sortedKeys.length;

    // Add an extra item for tasks without due date if there are any
    if (tasksWithoutDueDate.isNotEmpty) {
      itemCount += 1;
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // If we're at the last index and there are tasks without due dates
        if (tasksWithoutDueDate.isNotEmpty && index == sortedKeys.length) {
          // Handle tasks without due date at the end of the list
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUndatedHeader(),
              ...tasksWithoutDueDate.map((task) => _buildTaskCard(task)).toList(),
            ],
          );
        } else {
          // Handle tasks with due dates
          final dateKey = sortedKeys[index];
          final tasksForDate = groupedTasks[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateKey),
              ...tasksForDate.map((task) => _buildTaskCard(task)).toList(),
            ],
          );
        }
      },
    );
  }

  Widget _buildDateHeader(String dateKey) {
    final taskDate = DateFormat('yyyy-MM-dd').parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    String displayDate;
    if (taskDate.isAtSameMomentAs(today)) {
      displayDate = 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      displayDate = 'Tomorrow';
    } else if (taskDate.isAtSameMomentAs(yesterday)) {
      displayDate = 'Yesterday';
    } else {
      displayDate = DateFormat('EEEE, MMMM d').format(taskDate);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayDate,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUndatedHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Undated Tasks',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(task.id.toString()),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Task"),
                content: const Text("Are you sure you want to delete this task?"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          context.read<TaskBloc>().add(DeleteTask(task.id!));
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(taskId: task.id!),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority indicator and checkbox
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: task.isCompleted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onChanged: (value) {
                            context.read<TaskBloc>().add(ToggleTaskCompletion(task));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 8),
                          _buildDueDateChip(task),
                        ],
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormScreen(task: task),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateChip(Task task) {
    final bool isOverdue = _isTaskOverdue(task);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.1)
            : Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: isOverdue ? Colors.red : Colors.blueAccent,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d, yyyy').format(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOverdue ? Colors.red : Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 14,
            color: _getCategoryColor(category),
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getCategoryColor(category),
            ),
          ),
        ],
      ),
    );
  }

  bool _isTaskOverdue(Task task) {
    if (task.dueDate == null || task.isCompleted) return false;
    final now = DateTime.now();
    return task.dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TaskBloc>().add(FetchTasks());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task to get started',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskFormScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Task'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list,
            size: 60,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No matching tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isFilteringByDate
                ? 'No tasks due on ${DateFormat('MMM d, yyyy').format(_selectedDate)}'
                : 'Try adjusting your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (_isFilteringByDate || _searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isFilteringByDate = false;
                  _searchQuery = "";
                  _searchController.clear();
                  _isSearching = false;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskFormScreen()),
        );
      },
      label: const Text('Add Task'),
      icon: const Icon(Icons.add),
      elevation: 2,
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Helper functions for categories
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.school;
      case 'Health':
        return Icons.favorite;
      case 'Other':
        return Icons.label;
      default:
        return Icons.label;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.purple;
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.orange;
      case 'Health':
        return Colors.green;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}