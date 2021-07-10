#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"


cd "$(dirname "$0")"

cd ..

# Build the project.
/usr/local/bin/hugo --minify # if using a theme, replace with `hugo -t <YOURTHEME>`


# Remove unnecessary html markup to reduce git commit
cd public
find . -type f -name "*.html" -exec sed -i  "s/id=gallery-[[:digit:]]\+/id=gallery-replaced/g" {} \;
find . -type f -name "*.html" -exec sed -i  "s/galleryid-[[:digit:]]\+/galleryid-replaced/g" {} \;
find . -type f -name "*.html" -exec sed -i  "s#https\?:/wp-content#/wp-content#g" {} \;
find . -type f -name "*.html" -exec sed -i  "s#title=[a-z0-9-]{1,}#title=replaced#g" {} \;
find . -type f -name "*.html" -exec sed -i  "s#alt=[a-z0-9-]{1,}#alt=replaced#g" {} \;

git config --global core.quotePath false

gitCommitByBulk(){
        path=$1
	msg=$2
        bulkSize=$3
	if [[ -z "$bulkSize" ]]; then
		bulkSize=200
	fi
	countLines=$(git ls-files -dmo ${path} | head -n ${bulkSize} | wc -l)
	echo "[INFO] Start git push at path $path"
	git ls-files -dmo ${path} | head -n ${bulkSize}
	while [[ "${countLines}" != "0"  ]]
	do
		git ls-files -dmo ${path} | head -n ${bulkSize} | xargs -t -I {} echo -e '{}' | xargs -I{} git add "{}"
		finaMsg="[Bulk] ${msg} - Added ${path}@${countLines} files"
		echo "$finaMsg"
		git commit -m "$finaMsg"
		git push origin master
		countLines=$(git ls-files -dmo ${path} | head -n ${bulkSize} | wc -l)
	done
}


gitAddCommitPush(){
	path=$1
	msg=$2
	git add "${path}"
	git add "${path}*"
	git add "${path}\*"

	if [[ -z ${msg} ]];then
		msg="[Partial] Commit for ${path} `date`"
	fi
	
	git commit -m "$msg"
	
	# Push source and build repos.
	git push origin master

	
}
export -f gitAddCommitPush

rangeGitAddPush(){
	pathPrefix=$1
	start=$2
	end=$3

	for i in $(seq $start $end)
	do
		gitCommitByBulk "$pathPrefix/${i}"
		gitCommitByBulk "$pathPrefix/${i}*"
		#gitAddCommitPush "$pathPrefix/${i}"
	done
}

#gitAddCommitPush "categories"
gitCommitByBulk "categories"
#gitAddCommitPush "wp-content"
gitCommitByBulk "wp-content"

rangeGitAddPush page 1 10
rangeGitAddPush "posts/page" 1 10

# Commit changes.
# Add changes to git.
START=2005
END=$(date +'%Y')
MONTH=$(date +"%m")
gitCommitByBulk "${END}/${MONTH}"
#gitAddCommitPush "${END}/${MONTH}"

git add .
for i in $(seq $START $END)
do
   git reset "$i/"
done
#gitAddCommitPush "." "Commit all the rest"
git commit -m "Commit all the rest"
git push origin master

git reset --hard
git clean -fd
git gc


# Come Back up to the Project Root
cd ..
