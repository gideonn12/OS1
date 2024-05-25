#!/bin/bash
declare -A board
initialize_board() {
    for rank in {8..1}; do
        for file in {a..h}; do
            if [ "$rank" -eq 8 ]; then
                board[$file$rank]="r"
            elif [ "$rank" -eq 7 ]; then
                board[$file$rank]="p"
            elif [ "$rank" -eq 2 ]; then
                board[$file$rank]="P"
            elif [ "$rank" -eq 1 ]; then
                board[$file$rank]="R"
            else
                board[$file$rank]="."
            fi
        done
    done
    board[b8]="n"; board[g8]="n"; board[b1]="N"; board[g1]="N"
    board[c8]="b"; board[f8]="b"; board[c1]="B"; board[f1]="B"
    board[d8]="q"; board[d1]="Q"
    board[e8]="k"; board[e1]="K"
}
move_piece() {
    local from=$1
    local to=$2
    board[$to]=${board[$from]}
    board[$from]="."
}

print_chess_board() {
    echo "  a b c d e f g h"
    for rank in {8..1}; do
        echo -n "$rank "
        for file in {a..h}; do
            echo -n "${board[$file$rank]} "
        done
        echo "$rank"
    done
    echo "  a b c d e f g h"
}

initialize_board
print_chess_board

# Read the entire file into a buffer
buffer=$(cat "capmemel24_1.pgn")

# Replace newline characters with spaces
buffer=${buffer//$'\n'/ }

moves=""
# Try to match a full move in the buffer
while [[ $buffer =~ ([0-9]+\.[[:space:]]*([a-zA-Z0-9-]+)[[:space:]]*([a-zA-Z0-9-]+)) ]]; do
    # Extract the full move with the move number
    full_move="${BASH_REMATCH[1]}"
    # Remove the first occurrence of the full move from the buffer
    buffer=${buffer/"$full_move"/}
    # Add a space and the full move to the moves string
    moves+=" $full_move"
done

# Remove the first space from the moves string
moves=${moves#" "}
#echo "$moves"

# Send all the moves to the Python script
parsed_moves=$(python3 parse_moves.py "$moves")
#echo -e "$parsed_moves\n"
index=0

IFS=' ' read -ra parsed_moves <<< "$parsed_moves"
#while true; do  PROBLEM IS HERE WITH LOOP
    echo "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read -n 1 key
    case $key in
        d)
            # Move forward
            if (( index < ${#parsed_moves[@]} )); then
                echo "Next move: ${parsed_moves[$index]}"
                move_piece "${parsed_moves[$((index-1))]}" "${parsed_moves[$index]}"
                ((index++))
                print_chess_board
            else
                echo "End of moves"
            fi
            ;;
        a)
            # Move back
            if (( index > 0 )); then
                ((index--))
                echo "Previous move: ${parsed_moves[$index]}"
                move_piece "${parsed_moves[$index]}" "${parsed_moves[$((index-1))]}"
                print_chess_board
            else
                echo "Start of moves"
            fi
            ;;
        w)
            # Go to the start
            index=0
            echo "Start of moves"
            print_chess_board
            ;;
        s)
            # Go to the end
            index=${#parsed_moves[@]}
            echo "End of moves"
            print_chess_board
            ;;
        q)
            # Quit
            echo "Quitting"
            exit 0
            ;;
    esac