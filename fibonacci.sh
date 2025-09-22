FIB=$1
#Exercise 1

if [[ -z $1 ]]|| [[ ! $1 =~ ^[0-9]+$ ]]; then
echo "Invalid arguments provide a positive integer"
exit 255
elif [[ $1 -eq 0 ]]; then
echo "Result for Fn[0] is 0"
exit 0
elif [[ $1 -eq 1 ]]; then
echo "Result for Fn[1]  is 1"
exit 0
fi


fibonacci(){
    local a1=0
    local a2=1
    local res=0
    for((i=0;i<FIB-1;i++ )); do
    res=$((a1+a2))
    a1=$a2;
    a2=$res;
    done
    echo "Result for Fn[$FIB] is $res"
}

fibonacci
