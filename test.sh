files="box-sum/das box-dsad/das"
regex="(box-[0-9a-z]*)"
for f in $files
do
    if [[ $f =~ $regex ]]
    then
        name="${BASH_REMATCH[1]}"
        result=$result" "$name
    fi
done
echo $result