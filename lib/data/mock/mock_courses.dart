import '../../models/course.dart';
import '../../models/progress.dart';

/// Demo catalogue used until the Laravel API is connected.

Exercise _predict(
  String id,
  String code,
  List<String> options,
  String answer,
  String why, {
  String question = 'What will this code print?',
}) =>
    Exercise(
      id: id,
      type: ExerciseType.predictOutput,
      question: question,
      code: code,
      options: options,
      answer: answer,
      explanation: why,
    );

Exercise _choice(
  String id,
  String question,
  List<String> options,
  String answer,
  String why, {
  String? code,
}) =>
    Exercise(
      id: id,
      type: ExerciseType.multipleChoice,
      question: question,
      code: code,
      options: options,
      answer: answer,
      explanation: why,
    );

Exercise _fill(
  String id,
  String question,
  String code,
  String answer,
  String why,
) =>
    Exercise(
      id: id,
      type: ExerciseType.fillInCode,
      question: question,
      code: code,
      answer: answer,
      explanation: why,
    );

final List<Course> mockCourses = [
  Course(
    id: 'python-beginners',
    title: 'Python for Beginners',
    language: 'Python',
    level: CourseLevel.beginner,
    rating: 4.8,
    hours: 6,
    description:
        'Learn variables, loops, functions and lists by writing real code in every lesson.',
    lessons: [
      Lesson(
        id: 'py-1',
        title: 'Hello, Python',
        minutes: 4,
        body:
            'print() shows text on the screen. Text (a "string") always goes inside quotes.',
        code: 'print("Hello, Python!")\nprint("Code Wise Academy")',
        tip: 'Try printing your own name.',
        exercises: [
          _predict('py-1-a', 'print("Hi" * 3)',
              ['HiHiHi', 'Hi 3', 'Hi Hi Hi', 'Error'], 'HiHiHi',
              'Multiplying a string by a number repeats it.'),
          _fill('py-1-b', 'Complete the code so it prints Hello.',
              '____("Hello")', 'print', 'print() is the function that writes output.'),
        ],
      ),
      Lesson(
        id: 'py-2',
        title: 'Variables & Types',
        minutes: 6,
        body: 'A variable stores a value. Python works out the type for you.',
        code: 'name = "Ada"\nage = 21\nprint(name, age)',
        tip: 'Try changing the values and predict what will print.',
        exercises: [
          _predict('py-2-a', 'x = 3\ny = x * 2\nprint(y + 1)',
              ['6', '7', '8', 'Error'], '7', 'y is 6, so y + 1 prints 7.'),
          _choice('py-2-b', 'What type is the value 3.14?',
              ['int', 'str', 'float', 'bool'], 'float',
              'Numbers with a decimal point are floats.'),
        ],
      ),
      Lesson(
        id: 'py-3',
        title: 'Loops',
        minutes: 7,
        body:
            'A for loop repeats code for every item in a sequence. range(n) counts from 0 up to n - 1.',
        code: 'for i in range(3):\n    print(i)',
        tip: 'The indented lines are the body of the loop.',
        exercises: [
          _predict('py-3-a', 'total = 0\nfor n in range(1, 4):\n    total += n\nprint(total)',
              ['3', '6', '10', '4'], '6', '1 + 2 + 3 = 6. range(1, 4) stops before 4.'),
          _fill('py-3-b', 'Fill in the keyword that starts the loop.',
              '____ fruit in ["apple", "kiwi"]:\n    print(fruit)', 'for',
              'for item in sequence: loops over every item.'),
        ],
      ),
      Lesson(
        id: 'py-4',
        title: 'Functions',
        minutes: 8,
        body: 'def creates a reusable block of code. return sends a value back to the caller.',
        code: 'def greet(name):\n    return "Hi " + name\n\nprint(greet("Sam"))',
        exercises: [
          _predict('py-4-a', 'def double(n):\n    return n * 2\n\nprint(double(5))',
              ['10', '25', '52', 'None'], '10', 'double(5) returns 5 * 2 = 10.'),
          _choice('py-4-b', 'Which keyword sends a value back from a function?',
              ['print', 'return', 'def', 'break'], 'return',
              'return ends the function and hands back a value.'),
        ],
      ),
      Lesson(
        id: 'py-5',
        title: 'Lists',
        minutes: 7,
        body: 'A list stores many values in order. Counting positions (indexes) starts at 0.',
        code: 'langs = ["Python", "Dart", "SQL"]\nprint(langs[0])\nprint(len(langs))',
        exercises: [
          _predict('py-5-a', 'nums = [4, 8, 15]\nprint(nums[1])',
              ['4', '8', '15', 'Error'], '8', 'Index 1 is the second item.'),
          _choice('py-5-b', 'How do you add an item to the end of a list?',
              ['items.add(x)', 'items.append(x)', 'items.push(x)', 'items.insert(x)'],
              'items.append(x)', 'append() adds one item to the end.'),
        ],
      ),
    ],
  ),
  Course(
    id: 'flutter-dart',
    title: 'Flutter & Dart Basics',
    language: 'Dart',
    level: CourseLevel.beginner,
    rating: 4.7,
    hours: 8,
    description:
        'Start with Dart fundamentals, then build your first Flutter screens with widgets and state.',
    lessons: [
      Lesson(
        id: 'dart-1',
        title: 'Dart Variables',
        minutes: 5,
        body: 'Use var when a value changes, final when it is set once, and const for compile-time constants.',
        code: "var score = 10;\nfinal name = 'Ada';\nconst pi = 3.14;\nprint('\$name scored \$score');",
        exercises: [
          _predict('dart-1-a', 'var a = 5;\na += 2;\nprint(a);',
              ['5', '7', '52', 'Error'], '7', 'a += 2 adds 2 to a.'),
          _choice('dart-1-b', 'Which variable can never be reassigned once set?',
              ['var', 'final', 'dynamic', 'int'], 'final',
              'final variables are assigned exactly once.'),
        ],
      ),
      Lesson(
        id: 'dart-2',
        title: 'Functions in Dart',
        minutes: 6,
        body: 'Functions have a return type, a name and parameters. => is a shortcut for one-line functions.',
        code: 'int add(int a, int b) => a + b;\n\nvoid main() {\n  print(add(2, 3));\n}',
        exercises: [
          _predict('dart-2-a', "String shout(String s) => s.toUpperCase();\nprint(shout('hi'));",
              ['hi', 'HI', 'Hi', 'Error'], 'HI', 'toUpperCase() turns every letter into a capital.'),
          _fill('dart-2-b', 'Every Dart program starts in which function?',
              "void ____() {\n  print('Start');\n}", 'main', 'main() is the entry point.'),
        ],
      ),
      Lesson(
        id: 'dart-3',
        title: 'Widgets',
        minutes: 8,
        body: 'In Flutter everything on screen is a widget. Text shows text and Column stacks widgets vertically.',
        code: "Column(\n  children: [\n    Text('Hello'),\n    Text('Flutter'),\n  ],\n)",
        exercises: [
          _choice('dart-3-a', 'Which widget lays out its children horizontally?',
              ['Column', 'Row', 'Stack', 'Container'], 'Row',
              'Row is horizontal, Column is vertical.'),
          _choice('dart-3-b', 'Which widget can rebuild when its data changes?',
              ['StatelessWidget', 'StatefulWidget', 'Text', 'Padding'], 'StatefulWidget',
              'A StatefulWidget keeps State and rebuilds when it changes.'),
        ],
      ),
      Lesson(
        id: 'dart-4',
        title: 'setState',
        minutes: 7,
        body: 'Call setState() inside a State class to change data and tell Flutter to redraw the widget.',
        code: 'int count = 0;\n\nvoid increment() {\n  setState(() {\n    count++;\n  });\n}',
        exercises: [
          _fill('dart-4-a', 'Complete the call that tells Flutter to rebuild.',
              '____(() {\n  count++;\n});', 'setState', 'setState schedules a rebuild.'),
          _predict('dart-4-b', 'var count = 0;\nfor (var i = 0; i < 3; i++) {\n  count++;\n}\nprint(count);',
              ['0', '2', '3', '4'], '3', 'The loop runs for i = 0, 1 and 2.'),
        ],
      ),
    ],
  ),
  Course(
    id: 'javascript-essentials',
    title: 'JavaScript Essentials',
    language: 'JavaScript',
    level: CourseLevel.intermediate,
    rating: 4.6,
    hours: 7,
    description: 'Master modern JavaScript: let and const, arrow functions, arrays and objects.',
    lessons: [
      Lesson(
        id: 'js-1',
        title: 'let and const',
        minutes: 5,
        body: 'let declares a variable you can change. const declares one you cannot reassign.',
        code: 'let score = 10;\nconst name = "Ada";\nscore = score + 5;\nconsole.log(name, score);',
        exercises: [
          _predict('js-1-a', 'console.log(2 + "2");',
              ['4', '22', 'NaN', 'Error'], '22', '+ with a string joins text together.'),
          _choice('js-1-b', 'Which keyword declares a variable you cannot reassign?',
              ['let', 'var', 'const', 'function'], 'const', 'const bindings cannot be reassigned.'),
        ],
      ),
      Lesson(
        id: 'js-2',
        title: 'Arrow Functions',
        minutes: 6,
        body: 'Arrow functions are a short way to write functions: (params) => result.',
        code: 'const square = (n) => n * n;\nconsole.log(square(4));',
        exercises: [
          _predict('js-2-a', 'const add = (a, b) => a + b;\nconsole.log(add(3, 4));',
              ['34', '7', '12', 'undefined'], '7', 'Both are numbers, so + adds them.'),
          _fill('js-2-b', 'Complete the arrow function.',
              'const greet = (name) ____ "Hi " + name;', '=>', 'The arrow => separates parameters from the body.'),
        ],
      ),
      Lesson(
        id: 'js-3',
        title: 'Arrays & map',
        minutes: 7,
        body: 'map() creates a new array by running a function on every item.',
        code: 'const nums = [1, 2, 3];\nconst doubled = nums.map(n => n * 2);\nconsole.log(doubled);',
        exercises: [
          _predict('js-3-a', 'console.log([1, 2, 3].map(n => n + 1));',
              ['[1, 2, 3]', '[2, 3, 4]', '[2, 4, 6]', '6'], '[2, 3, 4]', 'Each item gets 1 added.'),
          _choice('js-3-b', 'Which method keeps only the items that pass a test?',
              ['map', 'filter', 'forEach', 'push'], 'filter', 'filter() returns the items where the test is true.'),
        ],
      ),
      Lesson(
        id: 'js-4',
        title: 'Objects',
        minutes: 6,
        body: 'Objects group related values as key: value pairs. Read a value with a dot.',
        code: 'const user = { name: "Ada", age: 21 };\nconsole.log(user.name);',
        exercises: [
          _predict('js-4-a', 'const car = { brand: "Toyota", year: 2020 };\nconsole.log(car.year);',
              ['Toyota', '2020', 'undefined', 'year'], '2020', 'car.year reads the year property.'),
          _choice('js-4-b', 'What does === compare?',
              ['Value only', 'Value and type', 'Type only', 'Memory size'], 'Value and type',
              '=== is strict equality: no type conversion.'),
        ],
      ),
    ],
  ),
  Course(
    id: 'html-css',
    title: 'HTML & CSS Fundamentals',
    language: 'HTML/CSS',
    level: CourseLevel.beginner,
    rating: 4.5,
    hours: 5,
    description: 'Build and style web pages with HTML tags, CSS selectors and flexbox layouts.',
    lessons: [
      Lesson(
        id: 'web-1',
        title: 'HTML Structure',
        minutes: 5,
        body: 'HTML uses tags to describe content. Most tags have an opening and a closing part.',
        code: '<h1>Code Wise</h1>\n<p>Learn to code.</p>',
        exercises: [
          _choice('web-1-a', 'Which tag makes the biggest heading?',
              ['<h6>', '<h1>', '<head>', '<p>'], '<h1>', 'h1 is the top-level heading.'),
          _fill('web-1-b', 'Close the paragraph tag.', '<p>Hello world____', '</p>',
              'Closing tags start with a slash.'),
        ],
      ),
      Lesson(
        id: 'web-2',
        title: 'Links & Images',
        minutes: 5,
        body: 'The a tag creates links and img shows pictures. Attributes add extra information.',
        code: '<a href="https://flutter.dev">Flutter</a>\n<img src="logo.png" alt="Logo">',
        exercises: [
          _choice('web-2-a', 'Which attribute sets where a link goes?',
              ['src', 'href', 'alt', 'link'], 'href', 'href holds the link address.'),
          _choice('web-2-b', 'Why add alt text to an image?',
              ['It loads faster', 'It describes the image for screen readers', 'It adds a border', 'It resizes the image'],
              'It describes the image for screen readers', 'alt text makes images accessible.'),
        ],
      ),
      Lesson(
        id: 'web-3',
        title: 'CSS Selectors',
        minutes: 6,
        body: 'CSS selectors choose which elements to style. A dot selects a class.',
        code: 'p {\n  color: yellow;\n}\n.title {\n  font-size: 24px;\n}',
        exercises: [
          _choice('web-3-a', 'Which selector targets class="card"?',
              ['card', '#card', '.card', '*card'], '.card', '. selects classes, # selects ids.'),
          _fill('web-3-b', 'Make the heading text bold.', 'h2 {\n  font-weight: ____;\n}', 'bold',
              'font-weight: bold makes text thicker.'),
        ],
      ),
      Lesson(
        id: 'web-4',
        title: 'Flexbox',
        minutes: 7,
        body: 'Flexbox arranges items in a row or column and controls the space between them.',
        code: '.row {\n  display: flex;\n  justify-content: space-between;\n}',
        exercises: [
          _choice('web-4-a', 'Which declaration turns on flexbox?',
              ['display: flex', 'position: flex', 'flex: on', 'layout: flex'], 'display: flex',
              'display: flex makes the element a flex container.'),
          _choice('web-4-b', 'Which property spaces items along the main axis?',
              ['align-items', 'justify-content', 'text-align', 'margin'], 'justify-content',
              'justify-content works on the main axis; align-items on the cross axis.'),
        ],
      ),
    ],
  ),
  Course(
    id: 'sql-querying',
    title: 'SQL Querying',
    language: 'SQL',
    level: CourseLevel.intermediate,
    rating: 4.7,
    hours: 6,
    description: 'Read and analyse data with SELECT, WHERE, ORDER BY and GROUP BY.',
    lessons: [
      Lesson(
        id: 'sql-1',
        title: 'SELECT',
        minutes: 5,
        body: 'SELECT chooses columns and FROM chooses the table to read them from.',
        code: 'SELECT name, email\nFROM students;',
        exercises: [
          _choice('sql-1-a', 'Which keyword picks the table to read from?',
              ['SELECT', 'FROM', 'WHERE', 'TABLE'], 'FROM', 'FROM names the table.'),
          _fill('sql-1-b', 'Select every column.', 'SELECT ____ FROM courses;', '*',
              '* means all columns.'),
        ],
      ),
      Lesson(
        id: 'sql-2',
        title: 'Filtering with WHERE',
        minutes: 6,
        body: 'WHERE keeps only the rows that match a condition.',
        code: "SELECT title\nFROM courses\nWHERE level = 'Beginner';",
        exercises: [
          _predict('sql-2-a', 'SELECT * FROM students\nWHERE age > 18;',
              ['0', '1', '2', '3'], '2', 'Only 21 and 25 are greater than 18.',
              question: 'The students table has ages 17, 21 and 25. How many rows come back?'),
          _choice('sql-2-b', 'Which operator means "not equal" in standard SQL?',
              ['==', '<>', '=!', '=/='], '<>', '<> is standard SQL; most databases also accept !=.'),
        ],
      ),
      Lesson(
        id: 'sql-3',
        title: 'Sorting with ORDER BY',
        minutes: 5,
        body: 'ORDER BY sorts the results. ASC is lowest first, DESC is highest first.',
        code: 'SELECT title, rating\nFROM courses\nORDER BY rating DESC;',
        exercises: [
          _choice('sql-3-a', 'Which keyword sorts from highest to lowest?',
              ['ASC', 'DESC', 'DOWN', 'REVERSE'], 'DESC', 'DESC means descending.'),
          _fill('sql-3-b', 'Sort students by name.', 'SELECT * FROM students\n____ BY name;', 'ORDER',
              'ORDER BY column sorts the rows.'),
        ],
      ),
      Lesson(
        id: 'sql-4',
        title: 'COUNT & GROUP BY',
        minutes: 7,
        body: 'COUNT(*) counts rows. GROUP BY splits rows into groups so you can count each group.',
        code: 'SELECT level, COUNT(*)\nFROM courses\nGROUP BY level;',
        exercises: [
          _choice('sql-4-a', 'What does COUNT(*) return?',
              ['The sum of a column', 'The number of rows', 'The largest value', 'The first row'],
              'The number of rows', 'COUNT(*) counts rows.'),
          _predict('sql-4-b', "SELECT COUNT(*) FROM courses\nWHERE level = 'Advanced';",
              ['1', '2', '3', '5'], '2', 'Only the 2 Advanced rows are counted.',
              question: 'A table has 3 Beginner and 2 Advanced courses. What is returned?'),
        ],
      ),
    ],
  ),
  Course(
    id: 'algorithms',
    title: 'Algorithms & Big-O',
    language: 'Python',
    level: CourseLevel.advanced,
    rating: 4.9,
    hours: 9,
    description: 'Understand how fast your code runs, and solve problems with recursion and searching.',
    lessons: [
      Lesson(
        id: 'algo-1',
        title: 'Big-O Basics',
        minutes: 8,
        body: 'Big-O describes how running time grows with the input size n.',
        code: 'for x in items:      # O(n)\n    print(x)\n\nprint(items[0])     # O(1)',
        exercises: [
          _choice('algo-1-a', 'Looping once over n items is…',
              ['O(1)', 'O(n)', 'O(n²)', 'O(log n)'], 'O(n)', 'The work grows in step with n.'),
          _choice('algo-1-b', 'Binary search on a sorted list runs in…',
              ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'], 'O(log n)', 'Each step halves the search space.'),
        ],
      ),
      Lesson(
        id: 'algo-2',
        title: 'Recursion',
        minutes: 9,
        body: 'A recursive function calls itself on a smaller problem until it reaches a base case.',
        code: 'def fact(n):\n    if n <= 1:\n        return 1\n    return n * fact(n - 1)',
        exercises: [
          _predict('algo-2-a', 'print(fact(4))',
              ['4', '10', '16', '24'], '24', '4 × 3 × 2 × 1 = 24.'),
          _choice('algo-2-b', 'Every recursive function needs a…',
              ['loop', 'base case', 'list', 'class'], 'base case', 'Without a base case it never stops.'),
        ],
      ),
    ],
  ),
];

/// Starting progress for the demo account so the dashboard has something to show.
LearningProgress demoProgress() {
  final today = DateTime.now();
  return LearningProgress(
    courses: {
      'python-beginners': CourseProgress(
        courseId: 'python-beginners',
        completedLessonIds: {'py-1', 'py-2'},
        currentLessonIndex: 2,
        correctAnswers: 3,
        totalAnswers: 4,
      ),
      'flutter-dart': CourseProgress(
        courseId: 'flutter-dart',
        completedLessonIds: {'dart-1'},
        currentLessonIndex: 1,
        correctAnswers: 2,
        totalAnswers: 2,
      ),
    },
    streakDays: 5,
    lastActiveDay: DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1)),
    lastCourseId: 'python-beginners',
  );
}
