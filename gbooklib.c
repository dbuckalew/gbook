#include "gbooklib.h"
#include "sqlite3.h"
#include <stdio.h>

int loadStudents(sqlite3 *db, student_t *list) {
  int rc, i;
  char *zErrMsg = 0;
  char **result;
  int rows;
  int cols;
  char *sql = "SELECT * FROM student_data";
  rc = sqlite3_get_table(db, sql, &result, &rows, &cols, &zErrMsg);

  for(i=1; i<=rows; i++) {
    fprintf(stderr, "%s %s %s %s", result[i*4], result[i*4+1], result[i*4+2], result[i*4+3]);
  }

  sqlite3_free_table(result);
}

int main(int argc, char **argv) {
  sqlite3 *db;
  student_t *student_list;
  int rc;

  if( argc != 2 ) {
    fprintf(stderr, "Usage: %s DATABASE\n", argv[0]);
    exit(1);
  }

  rc = sqlite3_open(argv[1], &db);

  if( rc ) {
    fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    exit(1);
  }

  loadStudents(db, student_list);
}
