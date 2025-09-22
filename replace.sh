#!/bin/sh
#Exercise 5 
input_file=""
output_file=""
operations=()



while getopts "vs:rlu:i:o:" opt; do
    case $opt in
        v) operations+=("reverse_case") ;;
        s) 
            a_word=$OPTARG
            if [[ $OPTIND -le $# ]]; then
                b_word=${!OPTIND}
                OPTIND=$((OPTIND + 1))
                operations+=("substitute:$a_word:$b_word")
            else
                echo "Error: -s requires two arguments"
                exit 1
            fi
            ;;
        r) operations+=("reverse_lines") ;;
        l) operations+=("lowercase") ;;
        u) operations+=("uppercase") ;;
        i) input_file=$OPTARG ;;
        o) output_file=$OPTARG ;;
        \?) exit 1 ;;
    esac
done

if [[ -z "$input_file" || -z "$output_file" ]]; then
    echo "Error: Input and output files are required"
    exit 1
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' not found"
    exit 1
fi

if [[ ${#operations[@]} -eq 0 ]]; then
    echo "Error: No operations specified"
    exit 1
fi

temp_file1=$(mktemp)
temp_file2=$(mktemp)
cp "$input_file" "$temp_file1"

for operation in "${operations[@]}"; do
    case $operation in
        "reverse_case")
            sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/' "$temp_file1" > "$temp_file2"
            ;;
        "substitute:"*)
            IFS=':' read -r op a_word b_word <<< "$operation"
            sed "s/$a_word/$b_word/g" "$temp_file1" > "$temp_file2"
            ;;
        "reverse_lines")
            tac "$temp_file1" > "$temp_file2"
            ;;
        "lowercase")
            sed 's/.*/\L&/' "$temp_file1" > "$temp_file2"
            ;;
        "uppercase")
            sed 's/.*/\U&/' "$temp_file1" > "$temp_file2"
            ;;
    esac
    mv "$temp_file2" "$temp_file1"
done

mv "$temp_file1" "$output_file"
rm -f "$temp_file2"

echo "Operations completed in order: ${operations[*]}"
echo "Output written to: $output_file"