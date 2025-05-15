#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/wait.h>  
#include <stdlib.h>
#include <ctype.h>



char *readl(void){
  char *line=malloc(sizeof(char)*100);

    if (!line) {
        perror("malloc failed");
        exit(1);
    }
    if (!fgets(line, 100, stdin)) {
        free(line);
        exit(1);
    }
  //fgets(line, 100, stdin);
  line[strcspn(line, "\n")] = '\0';
  return line;
}


char **split(char line[]){
  
  if(line==NULL){ return NULL;}
    line[strcspn(line, "\n")] = '\0';
    char *token =strtok(line," ");
    int buffer=10;
    char **str = malloc(buffer * sizeof(char *));
    if (!str) {
        perror("malloc failed");
        exit(1);
    }

    int i=0;
    while(token!=NULL){
      if (i >= buffer-1) {
        buffer += 10;
        str = realloc(str, buffer * sizeof(char *));
        if (!str) {
            perror("realloc failed");
            exit(1);
        }
      }
      str[i]=strdup(token);
      i++;
      token=strtok(NULL," ");

    }
    str[i] = NULL;
    return str;
  }
  

int count_words(char* x){
  int k=0;
  int c=0;
  FILE *file = fopen(x, "r");
    if (file == NULL) {
        printf("Error opening file.\n");
        return 1;
    }

    char ch;
    while ((ch = fgetc(file)) != EOF) { 
      
      if(isspace(ch)){
        c=0;
        }else if(c==0){
          c=1;
          k++;
        }
  }
        
        
    printf("%d\n",k);
    fclose(file);
    return 0;
}


void cd(char *path) {
  if (path == NULL) {
      fprintf(stderr, "cd: expected argument\n");
  } else if (chdir(path) != 0) {
      perror("cd failed");
  }
}

int lsh_launch(char **args)
{
  pid_t pid, wpid;
  int status;

  pid = fork();
  if (pid == 0) {
    // Child process
    if (execvp(args[0], args) == -1) {
      perror("lsh");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    // Error forking
    perror("lsh");
  } else {
    // Parent process
    do {
      wpid = waitpid(pid, &status, WUNTRACED);
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
  }

  return 1;
}

int main()
{
  while(1){
    
    char cwd[1024];  
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        printf("%s:~ ", cwd);
        printf("$ ");
    } 
    
    char *input=readl();
    char **words= split(input);

    if(words[0]==NULL){
      free(input);
      free(words);
      continue;
    }

    if (words[0] != NULL && words[0][0] != '\0'){
      if (strcmp(words[0], "cd") == 0) { 
          cd(words[1]);  // Call built-in `cd`
      } else if (strcmp(words[0], "exit") == 0) {
        // Exit gracefully
        printf("Exiting shell...\n");
        free(input);
        break;
      }else if (strcmp(words[0], "count-words") == 0) {
        count_words(words[1]);
      }else {
          lsh_launch(words);  // Execute external commands
      }
  }
    
    
    
    free(input);
        for (int i = 0; words[i]; i++) {
          free(words[i]);
        }
        free(words);  
    }

}