#include <stdio.h>
#include <string.h>
#include <assert.h>

#define MAX_BUF		4096

int main(int argc, char *argv[])
{
  char response[MAX_BUF];

  fprintf(stderr, "example ready\n");
  setlinebuf(stdout);

  for(;;) {
    char *ret = fgets(response, MAX_BUF, stdin);
    assert(ret != NULL);

    char *input = strtok(response, " ");
    fprintf(stderr, "got command '%s'\n", input);

    if(!strcmp(input, "find")) {
      printf("find FOUND\n");
    } else if(!strcmp(input, "insert")) {
      printf("insert OK\n");
    } else {
      fprintf(stderr, "unknown input\n");
    }
  }

  return 0;
}
