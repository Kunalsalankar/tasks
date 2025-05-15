import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../blocs/task_bloc.dart';
import 'package:intl/intl.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with SingleTickerProviderStateMixin {
  Task? task;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchTask();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchTask() async {
    final taskBloc = context.read<TaskBloc>();
    taskBloc.add(FetchTasks());
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade400;
      case 2:
        return Colors.amber.shade600;
      case 3:
        return Colors.redAccent.shade200;
      default:
        return Colors.blue.shade400;
    }
  }

  String _getTimeRemainingText(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              border: isDarkMode
                  ? Border.all(color: Colors.grey[800]!)
                  : null,
            ),
            child: Icon(Icons.arrow_back_ios_new, color: theme.primaryColor, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                border: isDarkMode
                    ? Border.all(color: Colors.grey[800]!)
                    : null,
              ),
              child: Icon(Icons.edit_outlined, color: theme.primaryColor, size: 18),
            ),
            onPressed: () {
              if (task != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(task: task),
                  ),
                ).then((_) => _fetchTask());
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                border: isDarkMode
                    ? Border.all(color: Colors.grey[800]!)
                    : null,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            ),
            onPressed: () {
              _showDeleteConfirmationDialog();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is TasksLoaded) {
            task = state.tasks.firstWhere(
                  (t) => t.id == widget.taskId,
              orElse: () => null as Task,
            );

            if (task == null) {
              return const Center(child: Text('Task not found'));
            }

            return _buildTaskDetail(task!, theme);
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No task data available'));
          }
        },
      ),
      floatingActionButton: task != null ? FloatingActionButton.extended(
        onPressed: () {
          context.read<TaskBloc>().add(ToggleTaskCompletion(task!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                task!.isCompleted ? 'Task marked as pending' : 'Task marked as completed',
              ),
              backgroundColor: task!.isCompleted ? Colors.orange : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.white,
                onPressed: () {
                  context.read<TaskBloc>().add(ToggleTaskCompletion(task!));
                },
              ),
            ),
          );
        },
        icon: Icon(
          task!.isCompleted ? Icons.refresh : Icons.check,
          color: Colors.white,
        ),
        label: Text(
          task!.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: task!.isCompleted ? Colors.orange : Colors.green,
      ) : null,
    );
  }

  Widget _buildTaskDetail(Task task, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    final isDarkMode = theme.brightness == Brightness.dark;

    // Enhanced dark mode colors
    final cardColor = isDarkMode
        ? Color(0xFF2C2C2E) // Dark gray for cards in dark mode
        : Colors.white;
    final textColor = isDarkMode
        ? Colors.white
        : Colors.black87;
    final secondaryTextColor = isDarkMode
        ? Colors.grey[400]
        : Colors.grey[600];
    final cardBorderColor = isDarkMode
        ? Colors.grey[800]
        : Colors.transparent;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Header section with priority color
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getPriorityColor(task.priority),
                    _getPriorityColor(task.priority).withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: isDarkMode
                                  ? Border.all(color: Colors.grey[800]!)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 16,
                                  color: _getPriorityColor(task.priority),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getPriorityText(task.priority),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getPriorityColor(task.priority),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: isDarkMode
                                  ? Border.all(color: Colors.grey[800]!)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.isCompleted ? Icons.check_circle : Icons.pending_actions,
                                  size: 16,
                                  color: task.isCompleted ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.isCompleted ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: task.isCompleted ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: Text(
                          task.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Container(
              color: isDarkMode ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black38 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 18, color: secondaryTextColor),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeRemainingText(task.createdDate),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: isDarkMode
                          ? Border.all(color: cardBorderColor!)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: theme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task.description.isEmpty ? 'No description provided.' : task.description,
                          style: TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date section
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: isDarkMode
                          ? Border.all(color: cardBorderColor!)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: theme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Date Information',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(task.createdDate),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for the FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text('Delete Task', style: TextStyle(color: textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this task?',
                style: TextStyle(color: textColor)),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(DeleteTask(widget.taskId));

              // Show a snackbar to confirm deletion and navigate back
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              Navigator.of(context).pop(); // Go back to list screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}