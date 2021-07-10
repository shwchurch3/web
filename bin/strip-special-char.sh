#!/bin/bash


# /home/ec2-user/hugo/github/hugo-theme/bin/strip-special-char.sh >> /home/ec2-user/hugo/github/sync.log 2>&1 &
echo "[INFO] Stripping all links including special chars"

cd /home/ec2-user/hugo/github/t5/content/posts

echo "" > special-chars.txt 
echo "" > special-chars-shorted.txt 

grep -iRl "^url: /20" ./ | xargs cat | grep "^url: " | sed 's/url: //' >> special-chars.txt 2>/dev/null

declare -a SpecialChars=(
	"　" 
	"。" 
	"，" 
	"-" 
	"—" 
	"——" 
	"－－" 
	" " 
	"”" 
	"“" 
	"”" 
	"？" 
	"：" 
	"！" 
	"_" 
	"（" 
	"）" 
	"《" 
	"》" 
	"•" 
	"、" 
	"：" 
	"、" 
	"："
)

while IFS='' read -r line || [[ -n "$line" ]]; do

	escapedLine=${line}

	for SpecialChar in "${SpecialChars[@]}"; do
		#escapedLine=$(printf '%s\n' "${escapedLine//${SpecialChar}/}")
		escapedLine=$(echo ${escapedLine} | sed "s/${SpecialChar}//g")
	done

	echo ${escapedLine}

	if [[ ! -z "${escapedLine}" && "${escapedLine}" != "${line}" ]]; then

		pattern="s#${line}#${escapedLine}#g"
		echo "${pattern}" >> ./special-chars-shorted.txt
		echo "[INFO] ${pattern}"

		find . -type f -name "*.md" -exec sed -i "${pattern}" {} \; >/dev/null 2>&1
	fi
	
    
done < "./special-chars.txt"

