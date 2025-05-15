
````markdown
# 📝 Task Manager App

A simple yet powerful Flutter app for managing tasks efficiently. Includes support for categories, due dates, priorities, and themes. Built with clean architecture principles using BLoC for state management and SQLite for local persistence.

---

## 🚀 Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/Kunalsalankar/tasks.git
cd tasks
````

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

---

## 🔌 API Endpoints

### Note: This app uses a local SQLite database. Below are the simulated data operations.

#### Task Model Example

```json
{
  "id": 1,
  "title": "Task Title",
  "description": "Task details",
  "isCompleted": false,
  "createdDate": "2025-05-15T12:00:00",
  "dueDate": "2025-05-20T12:00:00",
  "priority": 2,
  "category": "Personal"
}
```

#### SQLite Operations (via `DatabaseHelper`)

| Operation      | Method                   | Description                     |
| -------------- | ------------------------ | ------------------------------- |
| Create Task    | `insertTask(Task)`       | Inserts a task into the DB      |
| Read All Tasks | `getTasks()`             | Returns all tasks               |
| Read One Task  | `getTask(id)`            | Returns a single task by ID     |
| Update Task    | `updateTask(Task)`       | Updates an existing task        |
| Delete Task    | `deleteTask(id)`         | Deletes a task by ID            |
| Filter Tasks   | `getTasksByStatus(bool)` | Gets tasks by completion status |

---

## 📱 Usage Instructions

1. Launch the app on a device/emulator.
2. View all tasks on the task list screen.
3. Add new tasks using the form.
4. Tap a task to view or edit its details.
5. Mark tasks complete/incomplete.
6. Use the search functionality to find tasks.
7. Switch app theme using the theme BLoC.

---

## 🏛 Architecture Overview

### Layers Overview

```
lib/
├── blocs/           → State management using BLoC
│   ├── task_bloc.dart
│   └── theme_bloc.dart
├── data/            → Database and API services
│   ├── api_service.dart
│   └── database_helper.dart
├── models/          → Data models (Task)
│   └── task_model.dart
├── repositories/    → Business logic and data abstraction
│   └── task_repository.dart
├── screens/         → UI for list, detail, and form screens
│   ├── task_list_screen.dart
│   ├── task_detail_screen.dart
│   └── task_form_screen.dart
├── services/        → Utility services (e.g., search)
│   └── search_service.dart
├── theme/           → App theming
└── main.dart        → App entry point
```

### State Management

* **BLoC (Business Logic Component)** using `flutter_bloc`
* Ensures separation of UI and business logic

### Local Storage

* **SQLite** using `sqflite` package
* Handles task creation, editing, deletion, and filtering

---

## ✅ Testing

### Run all tests:

```bash
flutter test
```



---

## 📦 Packages Used

* `flutter_bloc`: For state management
* `sqflite`: For local database
* `path_provider`: To locate database path
* `intl`: For date formatting
* `equatable`: For value comparisons in BLoC

---

## 👨‍💻 Author

**Kunal Salankar**
[GitHub Profile](https://github.com/Kunalsalankar)

---

## 📃 License

This project is open-source and available under the MIT License.

```

---



I can help you enhance it further!
```
