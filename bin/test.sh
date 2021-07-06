
echoMe(){
        echo $1 
}
export -f echoMe
gitCommitByBulk(){
        path=$1
        bulkSize=200
        git ls-files -dmo ${path} | head -n ${bulkSize} | xargs -I{}  bash -c 'echoMe "$@"' _ {}
}
gitCommitByBulk .
