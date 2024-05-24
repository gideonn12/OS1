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

moves=()
while read -r line; do
    for word in $line; do
        # Check if the word is a move (i.e., it doesn't end with a period)
        if [[ "$word" != *"." ]]; then
            move=$(python3 parse_moves.py "$word")
            moves+=("$move")
        fi
    done
done < "capmemel24_1.pgn"

index=0
while true; do
    echo "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read -n1 key
    echo

    case $key in
        d)
            # Move forward
            if (( index < ${#moves[@]} )); then
                echo "Next move: ${moves[$index]}"
                move_piece "${moves[$((index-1))]}" "${moves[$index]}"
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
                echo "Previous move: ${moves[$index]}"
                move_piece "${moves[$index]}" "${moves[$((index-1))]}"
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
            index=${#moves[@]}
            echo "End of moves"
            print_chess_board
            ;;
        q)
            # Quit
            echo "Quitting"
            break
            ;;
        *)
            echo "Invalid key"
            ;;
    esac