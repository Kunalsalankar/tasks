import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../blocs/task_bloc.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  late bool _isCompleted;
  late DateTime _dueDate;
  final List<String> _categories = ['Personal', 'Work', 'Study', 'Health', 'Other'];
  late String _selectedCategory;

  // Color scheme based on priority - these will be adjusted based on theme
  final List<Color> _priorityColorsLight = [
    Colors.green.shade300,  // Low
    Colors.orange.shade300, // Medium
    Colors.red.shade300,    // High
  ];

  final List<Color> _priorityColorsDark = [
    Colors.green.shade400,  // Low
    Colors.orange.shade400, // Medium
    Colors.red.shade400,    // High
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 2;
    _isCompleted = widget.task?.isCompleted ?? false;
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedCategory = widget.task?.category ?? 'Personal';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        isCompleted: _isCompleted,
        dueDate: _dueDate,
        category: _selectedCategory,
        createdDate: widget.task?.createdDate,
      );

      if (widget.task == null) {
        context.read<TaskBloc>().add(AddTask(task));
      } else {
        context.read<TaskBloc>().add(UpdateTask(task));
      }

      Navigator.pop(context);
    }
  }

  // Get priority colors based on theme
  List<Color> _getPriorityColors(bool isDark) {
    return isDark ? _priorityColorsDark : _priorityColorsLight;
  }

  // Display a priority chip with appropriate color
  Widget _buildPriorityChip(int priority, bool isDark) {
    String label = _getPriorityLabel(priority);
    List<Color> priorityColors = _getPriorityColors(isDark);
    Color color = priorityColors[priority - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColors = _getPriorityColors(isDark);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Determine appropriate colors based on theme
    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final cardColor = isDark ? Colors.grey.shade800 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final fieldColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final fieldTextColor = isDark ? Colors.white : Colors.black87;
    final iconColor = primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        foregroundColor: textColor,
        title: Text(
          widget.task == null ? 'Create New Task' : 'Edit Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: iconColor),
            onPressed: _submitForm,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card with title input
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: fieldTextColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What do you need to do?',
                          hintStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: fieldColor,
                          prefixIcon: Icon(Icons.task_alt, color: iconColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Details card with description, priority, etc.
              Card(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description section
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(fontSize: 16, color: fieldTextColor),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add details about this task...',
                          hintStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: fieldColor,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category dropdown
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: fieldTextColor),
                            dropdownColor: fieldColor,
                            style: TextStyle(color: fieldTextColor),
                            items: _categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(value),
                                      color: _getCategoryColor(value, isDark),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(value, style: TextStyle(color: fieldTextColor)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Due date picker
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.fromSeed(
                                    seedColor: primaryColor,
                                    brightness: Theme.of(context).brightness,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _dueDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: fieldColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: iconColor, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                style: TextStyle(fontSize: 16, color: fieldTextColor),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_forward_ios, size: 16, color: labelColor),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Priority section
                      Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPriorityChip(1, isDark),
                          _buildPriorityChip(2, isDark),
                          _buildPriorityChip(3, isDark),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: themeColors[_priority - 1],
                          inactiveTrackColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          thumbColor: themeColors[_priority - 1],
                          overlayColor: themeColors[_priority - 1].withOpacity(0.2),
                          trackHeight: 6.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                        ),
                        child: Slider(
                          value: _priority.toDouble(),
                          min: 1.0,
                          max: 3.0,
                          divisions: 2,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toInt();
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Completion status for existing tasks
                      if (widget.task != null)
                        SwitchListTile(
                          title: Text(
                            'Mark as completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Toggle task completion status',
                            style: TextStyle(
                              fontSize: 14,
                              color: labelColor,
                            ),
                          ),
                          value: _isCompleted,
                          activeColor: Colors.green,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _isCompleted = value;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Text(
              widget.task == null ? 'Create Task' : 'Update Task',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Medium';
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

  Color _getCategoryColor(String category, bool isDark) {
    // Adjust colors based on theme
    switch (category) {
      case 'Personal':
        return isDark ? Colors.purple.shade300 : Colors.purple;
      case 'Work':
        return isDark ? Colors.blue.shade300 : Colors.blue;
      case 'Study':
        return isDark ? Colors.orange.shade300 : Colors.orange;
      case 'Health':
        return isDark ? Colors.green.shade300 : Colors.green;
      case 'Other':
        return isDark ? Colors.grey.shade300 : Colors.grey;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey;
    }
  }
}