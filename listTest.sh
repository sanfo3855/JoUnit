for (( i = 0; i < 220; i++ )); do
    echo ""
    echo "***************"
    echo "***** " $i " *****"
    echo "***************"
    ./JoUnit.sh https://github.com/sanfo3855/JoEC &&
    ./JoUnit.sh https://github.com/sanfo3855/test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1 &&

    ./JoUnit.sh ../JoEC  &&
    ./JoUnit.sh ../test1
done
