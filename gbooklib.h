#include <sqlite3.h>

typedef struct student {
  int id;
  char *firstName;
  char *lastName;
  char *email;
} student_t;

int loadStudents(sqlite3 *, student_t *);
