#!/bin/bash
# 329924567 Gideon Neeman
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
    local promote_to=$3
    if [ -z "$promote_to" ]; then
        board[$to]=${board[$from]}
    else
        board[$to]=$promote_to
    fi
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
if [[ ! -f $1 ]]; then
    echo "File does not exist: $1"
    exit 1
fi

# Continue with the rest of the script
initialize_board
prev_line=""
while IFS= read -r line
do
    if [[ $line == *"1."* ]]; then
        echo "$prev_line"
        break
    fi
    if [[ ! -z $prev_line ]]; then
        echo "$prev_line"
    fi
    prev_line=$line
done < "$1"


# Find the line number of the first occurrence of "1."
line_number=$(grep -n -m 1 '1\.' $1 | cut -d: -f1)

# Read from the line that contains "1." to the end of the file
buffer=$(sed -n "${line_number},\$p" $1)

# Replace newline characters with spaces
buffer=${buffer//$'\n'/ }
moves=""
# Try to match a full move in the buffer
while [[ $buffer =~ ([0-9]+\.[[:space:]]*([a-zA-Z0-9+-]+)[[:space:]]*([a-zA-Z0-9+-=]+)) || $buffer =~ ([a-zA-Z0-9+-=]+) ]]; do    # Extract the full move with the move number
    full_move="${BASH_REMATCH[1]}"
    # Remove the first occurrence of the full move from the buffer
    buffer=${buffer/"$full_move"/}
    # Add a space and the full move to the moves string
    moves+=" $full_move"
done

# Remove the first space from the moves string
moves=${moves#" "}
#echo "$moves"

parsed_moves=$(python3 parse_moves.py "$moves")
#echo -e "$parsed_moves\n"
index=0
IFS=' ' read -ra parsed_moves <<< "$parsed_moves"
echo "Move $index/${#parsed_moves[@]}" 
print_chess_board

while true; do
    echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit: "
    read -n 1 key
    echo
    case $key in
        d)
            if (( index < ${#parsed_moves[@]} )); then
                move=${parsed_moves[$index]}
                start=${move:0:2}
                end=${move:2:2}
                original_piece=${board[$start]}
                promote_to=${move:4:1}
                if [ -z "$promote_to" ]; then
                    move_piece "$start" "$end" "$original_piece"
                else
                    move_piece "$start" "$end" "$promote_to"
                    promotions[$index]="$promote_to"
                fi
                ((index++))
                echo "Move $index/${#parsed_moves[@]}"
                print_chess_board
            else
                echo "No more moves available."
            fi
            ;;
        a)
           if (( index > 0 )); then
                ((index--))
                move=${parsed_moves[$index]}
                start=${move:0:2}
                end=${move:2:2}
                original_piece=${board[$end]}
                if [ -n "${promotions[$index]}" ]; then
                    move_piece "$end" "$start" "p"
                    unset 'promotions[$index]'
                else
                    move_piece "$end" "$start" "$original_piece"
                fi
                echo "Move $index/${#parsed_moves[@]}" 
                print_chess_board
            fi
            ;;
        w)
            index=0
            initialize_board
            echo "Move $index/${#parsed_moves[@]}"
            print_chess_board
            ;;
        s)
            for move in "${parsed_moves[@]}"; do
                from=${move:0:2}
                to=${move:2:2}
                move_piece "$from" "$to"
            done
            index=${#parsed_moves[@]}
            echo "Move $index/${#parsed_moves[@]}"
            print_chess_board
            ;;
        q)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid key pressed: $key"
            ;;
    esac
done