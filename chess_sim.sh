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
    local start=$1
    local end=$2
    local piece=$3

    if [[ $piece == "P" || $piece == "p" ]]; then
        local promote_to=${move:4:1} 
        if [ -n "$promote_to" ]; then
            if [[ $piece == "P" ]]; then
                promote_to=$(echo "$promote_to" | tr '[:lower:]' '[:upper:]')
            elif [[ $piece == "p" ]]; then
                promote_to=$(echo "$promote_to" | tr '[:upper:]' '[:lower:]')
            fi
            board[$end]=$promote_to
        else
            board[$end]=$piece
        fi
    else
        board[$end]=$piece
    fi
    board[$start]="."
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

initialize_board

echo "Metadata from PGN file:"
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

line_number=$(grep -n -m 1 '1\.' $1 | cut -d: -f1)

buffer=$(sed -n "${line_number},\$p" $1)

buffer=${buffer//$'\n'/ }
moves=""
while [[ $buffer =~ ([0-9]+\.[[:space:]]*([^[:space:]]+)[[:space:]]*([^[:space:]]*)) ]]; do
    full_move="${BASH_REMATCH[1]}"
    buffer=${buffer/"$full_move"/}
    moves+=" $full_move"
done

moves=${moves#" "}

parsed_moves=$(python3 parse_moves.py "$moves")

index=0
IFS=' ' read -ra parsed_moves <<< "$parsed_moves"
echo "Move $index/${#parsed_moves[@]}" 
print_chess_board

while true; do
    echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read key
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
                    if [[ $original_piece =~ [A-Z] ]]; then
                        promote_to=$(echo "$promote_to" | tr '[:lower:]' '[:upper:]')
                    fi
                    move_piece "$start" "$end" "$promote_to"
                    promotions[$index]="$promote_to,$original_piece"
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
                initialize_board
                for ((i=0; i<index; i++)); do
                    move=${parsed_moves[$i]}
                    start=${move:0:2}
                    end=${move:2:2}
                    piece=${board[$start]}
                    move_piece "$start" "$end" "$piece"
                done
            fi
            echo "Move $index/${#parsed_moves[@]}" 
            print_chess_board
            ;;
        w)
            index=0
            initialize_board
            echo "Move $index/${#parsed_moves[@]}"
            print_chess_board
            ;;
        s)
            if (( index != ${#parsed_moves[@]} )); then
                initialize_board
                for move in "${parsed_moves[@]}"; do
                    from=${move:0:2}
                    to=${move:2:2}
                    piece=${board[$from]}
                    move_piece "$from" "$to" "$piece"
                done
                index=${#parsed_moves[@]}
            fi
            echo "Move $index/${#parsed_moves[@]}"
            print_chess_board
            ;;
        q)
            echo "Exiting."
            echo "End of game."
            exit 0
            ;;
        *)
            echo "Invalid key pressed: $key"
            ;;
    esac
done