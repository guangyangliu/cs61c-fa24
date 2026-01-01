#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t *state, unsigned int snum);
static char next_square(game_state_t *state, unsigned int snum);
static void update_tail(game_state_t *state, unsigned int snum);
static void update_head(game_state_t *state, unsigned int snum);

/* Task 1 */
game_state_t *create_default_state()
{
  game_state_t *state = malloc(sizeof(game_state_t));
  if (state == NULL)
  {
    return NULL;
  }
  state->num_rows = 18;
  state->board = malloc(state->num_rows * sizeof(char *));
  if (state->board == NULL)
  {
    free(state);
    return NULL;
  }

  const char *wall = "####################";
  const char *empty = "#                  #";
  for (int i = 0; i < state->num_rows; i++)
  {
    state->board[i] = malloc(21 * sizeof(char));
    if (state->board[i] == NULL)
    {
      for (int j = 0; j < i; j++)
      {
        free(state->board[j]);
      }
      free(state->board);
      free(state);
      return NULL;
    }
    if (i == 0 || i == state->num_rows - 1)
    {
      strcpy(state->board[i], wall);
    }
    else if (i == 2)
    {
      const char *snake_line = "# d>D    *         #";
      strcpy(state->board[i], snake_line);
    }
    else
    {
      strcpy(state->board[i], empty);
    }
  }

  state->num_snakes = 1;
  state->snakes = malloc(state->num_snakes * sizeof(snake_t));
  if (state->snakes == NULL)
  {
    for (int i = 0; i < state->num_rows; i++)
    {
      free(state->board[i]);
    }
    free(state->board);
    free(state);
    return NULL;
  }
  snake_t *snake = &state->snakes[0];
  snake->tail_col = 2;
  snake->tail_row = 2;
  snake->head_col = 4;
  snake->head_row = 2;
  snake->live = true;
  return state;
}

/* Task 2 */
void free_state(game_state_t *state)
{
  if (state == NULL)
  {
    return;
  };
  free(state->snakes);
  for (int i = 0; i < state->num_rows; i++)
  {
    free(state->board[i]);
  }
  free(state->board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp)
{
  for (int i = 0; i < state->num_rows; i++)
  {
    fprintf(fp, "%s\n", state->board[i]);
  }
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t *state, char *filename)
{
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t *state, unsigned int row, unsigned int col) { return state->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch)
{
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c)
{
  if (c == 'w' || c == 'a' || c == 's' || c == 'd')
  {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c)
{
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x')
  {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c)
{
  if (is_tail(c) || is_head(c) || c == '^' || c == '<' || c == '>' || c == 'v')
  {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c)
{
  if (c == '^')
  {
    return 'w';
  }
  else if (c == '<')
  {
    return 'a';
  }
  else if (c == 'v')
  {
    return 's';
  }
  else if (c == '>')
  {
    return 'd';
  };
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c)
{
  if (c == 'W')
  {
    return '^';
  }
  else if (c == 'A')
  {
    return '<';
  }
  else if (c == 'S')
  {
    return 'v';
  }
  else if (c == 'D')
  {
    return '>';
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c)
{
  if (c == 'v' || c == 's' || c == 'S')
  {
    return cur_row + 1;
  }
  else if (c == '^' || c == 'w' || c == 'W')
  {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c)
{
  if (c == '>' || c == 'd' || c == 'D')
  {
    return cur_col + 1;
  }
  else if (c == '<' || c == 'a' || c == 'A')
  {
    return cur_col - 1;
  };
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t *state, unsigned int snum)
{
  snake_t *snake = &state->snakes[snum];
  char head_char = get_board_at(state, snake->head_row, snake->head_col);
  unsigned int next_row = get_next_row(snake->head_row, head_char);
  unsigned int next_col = get_next_col(snake->head_col, head_char);
  char next_char = get_board_at(state, next_row, next_col);
  return next_char;
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t *state, unsigned int snum)
{
  snake_t *snake = &state->snakes[snum];
  char head_char = get_board_at(state, snake->head_row, snake->head_col);
  unsigned int next_row = get_next_row(snake->head_row, head_char);
  unsigned int next_col = get_next_col(snake->head_col, head_char);
  set_board_at(state, snake->head_row, snake->head_col, head_to_body(head_char));
  set_board_at(state, next_row, next_col, head_char);
  snake->head_col = next_col;
  snake->head_row = next_row;
  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t *state, unsigned int snum)
{
  snake_t *snake = &state->snakes[snum];
  char tail_char = get_board_at(state, snake->tail_row, snake->tail_col);
  unsigned int next_row = get_next_row(snake->tail_row, tail_char);
  unsigned int next_col = get_next_col(snake->tail_col, tail_char);
  set_board_at(state, snake->tail_row, snake->tail_col, ' ');
  set_board_at(state, next_row, next_col, body_to_tail(get_board_at(state, next_row, next_col)));
  snake->tail_col = next_col;
  snake->tail_row = next_row;
  return;
}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state))
{
  for (unsigned int i = 0; i < state->num_snakes; i++)
  {
    snake_t *snake = &state->snakes[i];
    if (snake->live)
    {
      char next_char = next_square(state, i);
      if (next_char == '*')
      {
        update_head(state, i);
        add_food(state);
      }
      else if (next_char == ' ')
      {
        update_head(state, i);
        update_tail(state, i);
      }
      else
      {
        snake->live = false;
        set_board_at(state, snake->head_row, snake->head_col, 'x');
      }
    }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp)
{
  /*
  fixed length is not a good approach, dynamic length is better.
  size_t length = 1000;
  char* line = malloc(length * sizeof(char));
  if(line == NULL) {
    return NULL;
  }

  if(fgets(line, (int)length, fp) == NULL) {
    free(line);
    return NULL;
  }
  length = strlen(line);
  char* temp = realloc(line, (length + 1) * sizeof(char));
  if(temp == NULL) {
    free(line);
    return NULL;
  }
  line = temp;
  return line;*/

  size_t capacity = 32; // Start with a small, efficient capacity
  size_t len = 0;       // Current length of the string content

  char *line = (char *)malloc(capacity);
  if (line == NULL)
  {
    return NULL;
  }

  while (1)
  {
    // 1. Read into the remaining space: line + len
    char *read_result = fgets(line + len, (int)(capacity - len), fp);

    if (read_result == NULL)
    {
      // EOF or error encountered. If no data was ever read, clean up and return NULL.
      if (len == 0)
      {
        free(line);
        return NULL;
      }
      break; // Stream ended, finalize the partial line.
    }

    // 2. Update the current total length
    len = strlen(line);

    // 3. Check for line completion (newline found)
    if (len > 0 && line[len - 1] == '\n')
    {
      break;
    }

    // If here, the line is longer than the current buffer.

    // 4. Double the buffer size
    capacity *= 2;
    char *temp = (char *)realloc(line, capacity * sizeof(char));

    if (temp == NULL)
    {
      // Realloc failure: free the existing, valid memory and return NULL
      free(line);
      return NULL;
    }
    line = temp;
  }

  // 5. Shrink buffer to the exact size (len + 1 for '\0')
  char *temp = (char *)realloc(line, len + 1);

  // If shrinking succeeded, update 'line'. Otherwise, return the slightly larger block.
  if (temp != NULL)
  {
    line = temp;
  }

  return line;
}

/* Task 5.2 */
game_state_t *load_board(FILE *fp)
{
  game_state_t *state = malloc(sizeof(game_state_t));
  if (state == NULL)
  {
    return NULL;
  }
  state->board = NULL;
  state->num_rows = 0;
  state->num_snakes = 0;
  state->snakes = NULL;

  char *line;
  size_t capacity = 0;
  while ((line = read_line(fp)) != NULL)
  {
    char **temp_board = realloc(state->board, (capacity + 1) * sizeof(char *));
    if (temp_board == NULL)
    {
      free(line);
      free_state(state);
      return NULL;
    }
    state->board = temp_board;
    line[strlen(line) - 1] = '\0';
    state->board[capacity] = line;
    capacity++;
  }
  state->num_rows = (unsigned int)capacity;

  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t *state, unsigned int snum)
{
  snake_t *snake = &state->snakes[snum];
  unsigned int cur_row = snake->tail_row;
  unsigned int cur_col = snake->tail_col;
  char cur_char = get_board_at(state, cur_row, cur_col);
  while (!is_head(cur_char))
  {
    cur_row = get_next_row(cur_row, cur_char);
    cur_col = get_next_col(cur_col, cur_char);
    cur_char = get_board_at(state, cur_row, cur_col);
  }
  snake->head_row = cur_row;
  snake->head_col = cur_col;
  return;
}

/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state)
{
  state->num_snakes = 0;
  state->snakes = NULL;
  for (unsigned int row = 0; row < state->num_rows; row++)
  {
    for (unsigned int col = 0; col < (int)strlen(state->board[row]); col++)
    {
      char c = get_board_at(state, row, col);
      if (is_tail(c))
      {
        snake_t *temp_snakes = realloc(state->snakes, (state->num_snakes + 1) * sizeof(snake_t));
        if (temp_snakes == NULL)
        {
          free_state(state);
          return NULL;
        }
        state->snakes = temp_snakes;
        snake_t *snake = &state->snakes[state->num_snakes];
        snake->tail_row = row;
        snake->tail_col = col;
        snake->live = true;
        find_head(state, state->num_snakes);
        state->num_snakes++;
      }
    }
  }
  return state;
}
