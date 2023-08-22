#!/usr/bin/env bash


# :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-)
# Script        : autoKNOXSS.sh                                   :-)
# Version       : 2.0                                             :-)
# Description   : This script use KNOXSS API                      :-) 
#                           by Rodolfo Assis (a.k.a @brutelogic)  :-)
# Author        : Diego Moicano (a.k.a @hihackthis)               :-)
# Email         : moicano.diego@gmail.com                         :-)
# How to use:                                                     :-)
#           $ chmod +x autoKNOXSS.sh                              :-)
#           $ ./autoKNOXSS.sh                                     :-)
# :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-) :-)


# Colors Pallet TPUT command

blink_magic=$(tput setaf 6 blink)
blink_api_call=$(tput setaf 5 blink )
white=$(tput setaf 7)
bold_white=$(tput setaf 7 bold)
bold_red=$(tput setaf 1 bold)
bold_green=$(tput setaf 2 bold)
bold_purple=$(tput setaf 5 bold)
bold_cyan=$(tput setaf 6 bold)
bold_yellow=$(tput setaf 3 bold)
warn_bold_red=$(tput setaf 196 bold)
bold_light_gray=$(tput setaf 249 bold)
bold_light_yellow=$(tput setaf 190 bold)
italic_light_blue=$(tput setaf 10 sitm)
bg_red=$(tput setab 124)
endcolor=$(tput sgr0)

# Emojis

glass_face="\xF0\x9F\x98\x8E"
grimace_face="\xF0\x9F\x98\xAC"
heart_face="\xF0\x9F\x98\x8D"
sad_face="\xF0\x9F\x98\xA5"

# Locale C

LC_ALL=C

# Counters

t=0
f=0
e=0

# Function Magic

magic() {
    echo -e "${blink_magic}
    ░█▄█░█▀█░█▀▀░▀█▀░█▀▀░░█░█░█
    ░█░█░█▀█░█░█░░█░░█░░░░▀░▀░▀
    ░▀░▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░░▀░▀░▀
${endcolor}"
}

# Function API Call

api_call() {
call=$(echo "$result" | jq -r '.[3]' 2> /dev/null | tr '/' ' ')
read -a reqs <<< "$call"

if [[ -z "${reqs[0]}" || -z "${reqs[1]}" ]]
then
    "$call" 2> /dev/null
else    
    rest=$(("${reqs[1]}" - "${reqs[0]}"))
    printf "%10c${blink_api_call}*---------------------------------------\
--------------*${endcolor}\n"
    printf "%12c>>> ${bold_white}You made${endcolor} ${bold_green}${reqs[0]}${endcolor} \
${bold_white}requests${endcolor}, ${bold_red}$rest${endcolor} \
${bold_white}requests remain!${endcolor} <<<\n"
    printf "%10c${blink_api_call}*---------------------------------------\
--------------*${endcolor}"
    echo
fi
}

# Function Output

customOutput() {

cond1="\"true\""
cond2="\"none\""

xss=$(echo "$result" | jq '.[0]' 2> /dev/null)
poc=$(echo "$result" | jq '.[1]' 2>  /dev/null)
error=$(echo "$result" | jq '.[2]' 2> /dev/null)

if [[ "$xss" = "$cond1" && "$error" = "$cond2" ]]
then
    echo -e "${bold_yellow}URL Probe:${endcolor} ${bold_white}$target${endcolor}"
    echo -e "${bold_white}>>>${endcolor} ${bold_green}XSS FOUND${endcolor}" 
    echo -e "${bold_purple}PoC${endcolor}: $poc\n"
    ((t++))
elif  [[ "$xss" != "$cond1" && "$error" = "$cond2" ]]
then
    echo -e "${bold_yellow}URL Probe:${endcolor} ${bold_white}$target${endcolor}\n"
    echo -e "${bold_white}>>>${endcolor} ${bold_red}XSS NOT FOUND${endcolor}\n"
    ((f++))
elif [[ -z "$error" ]]
then
    echo -e "${warn_light_red}>>> Oh no, the firewall is blocking!\n${endcolor}"
    ((e++))
elif [[ "$xss" != "$cond1" && "$error" != "$cond2" ]]
then
    echo -e "${bold_yellow}URL Probe:${endcolor} ${bold_white}$target${endcolor}\n"
    echo -e "${bold_purple}ERROR${endcolor}: $error\n"
    ((e++))
fi
r=$(($t+$f+$e))
}

# Function Stats

stats() {
printf "%33c Stats\n"
printf "%30cSuccessfully: $t ${heart_face}\n"
printf "%30cFailed: $f ${sad_face}\n"
printf "%30cError/Block: $e ${grimace_face}\n"
printf "%30cTotal: $r ${glass_face}\n"
}


# Function one or more Parameters GET

paramGET() {
while IFS= read -r line
do
    target="$line"
    line=$(sed 's/&/%26/g' <<< "$line")
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Cookie GET

cookieGet() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line&auth=Cookie:$cookie_name=$cookie_value"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&auth=Cookie:$cookie_name=$cookie_value" \
-H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Header GET

headersGet() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line="$line&auth=$header"
# Regex to remove the carriage return and the linefeed at the end of the last parameter
    line=$(sed 's/%0D%0A$//' <<< $line)
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Cookie and Header GET

cookHeadGet() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line="$line&auth=Cookie:$cookie&auth=$header"
# Regex to remove the carriage return and the linefeed at the end of the last parameter
    line=$(sed 's/%0D%0A$//' <<< $line)
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Flash Mode Value GET

flashValueGet() {
while IFS= read -r line
do
# Regex replaces parameter values with [XSS]
    line=$(sed -E -e 's/([A-Za-z0-9!@#$%*. ]+&|[A-Za-z0-9!@#$%*. ]+&?$)/[XSS]\&/g' \
-e 's/&$//' <<< "$line")
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Flash Mode Suffix GET

flashSuffixGet() {
while IFS= read -r line
do
# Regex to add [XSS] at the end of the parameter values
    line=$(sed -E -e 's/(&|&?$)/[XSS]\&/g' -e 's/&$//' <<< "$line")
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Flash Mode Prefix GET

flashPrefixGet() {
while IFS= read -r line
do
# Regex to add [XSS] after the question mark
    line=$(sed -E 's/[A-Za-z0-9!@#$%*.]+\?/[XSS]\?/' <<< "$line")
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Flash Mode and Header GET

flashHeaderGet() {
while IFS= read -r line
do
    flash_value="[XSS]"
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line&auth=$header_name: $flash_value"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&auth=$header_name: $flash_value" \
-H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err) 
    customOutput
done < "$fget"
stats
}

# Function Advanced Filter Bypass GET

afbGet() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    target="$line&afb=1"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&afb=1" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Advanced Filter Bypass and Header GET

afbHeaderGet() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line="$line&auth=$header"
# Regex to remove the carriage return and the linefeed at the end of the last parameter
    line=$(sed 's/%0D%0A$//' <<< $line)
    target="$line&afb=1"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&afb=1" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < "$fget"
stats
}

# Function Header Name

headerName() {
while :
do    
    read -p "Enter only header name (ex: User-Agent): " header_name < /dev/tty
    clear
    
# Regex in keeping with RFC 9110 (https://www.ietf.org/rfc/rfc9110.txt)
    ER='^[A-Za-z0-9_-]+$'

if [[ "$header_name" =~ $ER ]]
then
    break
elif [[ -z $header_name ]]
then
    echo "The header name can not be empty!"
    sleep 2
    clear
    continue
else
    echo "Enter a correct header name"
    sleep 2
    clear
    continue
fi
done
}

# Function Custom Cookies

toastCookies() {
clear
while :
do
    read -p "Enter only cookie name (ex: PHPSESSID): " cookie_name < /dev/tty
    read -p "Enter only cookie value (ex: 298zf09hf01): " cookie_value < /dev/tty
    clear
    
# Regex in keeping with RFC 6265 (https://www.ietf.org/rfc/rfc6265.txt)
    ER1='^[A-Za-z0-9#$%&*+^_`|~!'\''-]+$'
    ER2='^"?([]A-Za-z0-9#$%&=@*+`~^!(){}?<>:.'\''[_-]+)"?$'

if [[ "$cookie_name" =~ $ER1 && "$cookie_value" =~ $ER2 ]]
then
    cookie="$cookie_name=$cookie_value"
    break
elif [[ -z "$cookie_name" || -z "$cookie_value" ]]
then
    echo "The cookie name or value can not be empty!"
    sleep 2
    clear
    continue
else
    echo "Please, check if cookie name or value is correct."
    sleep 2
    clear
    continue
fi
done
}

# Function Custom Headers

brainHeaders() {
while :
do    
    read -p "Enter only header name (ex: Referer): " header_name < /dev/tty
    read -p "Enter only header value (ex: some URL): " header_value < /dev/tty
    echo
    
# Regex in keeping with RFC 9110 (https://www.ietf.org/rfc/rfc9110.txt)
    ER3='^[A-Za-z0-9_-]+$'
    ER4='^[]A-Za-z0-9 "#$%&=@*+`~^!(){}?\/<>:.,;'\''[_-]+$'
    
if [[ "$header_name" =~ $ER3 && "$header_value" =~ $ER4 ]]
then
    header="$header_name: $header_value"
    break
elif [[ -z "$header_name" || -z "$header_value" ]]
then
    echo "The header name or value can not be empty!"
    sleep 2
    clear
    continue
else
    echo "Please, check if header name or value is correct."
    sleep 2
    clear
    continue
fi
done
}

# Function More Headers GET

moreHeaders() {
until false
do
    
while :
do

    i=1
    read -n 1 -r -s -p "Another Header? If yes, press any key, if no, \
press ENTER/SPACE key..." stop < /dev/tty ; echo
    clear

if [[ "$stop" != "" ]]
then
    read -p "Enter only header name (ex: Referer): " header_name < /dev/tty
    read -p "Enter only header value (ex: some URL): " header_value < /dev/tty
    clear
if [[ $header_name =~ $ER1 && $header_value =~ $ER2 ]]
then
    new_header="$header_name: $header_value"
elif [[ -z $header_name || -z $header_value ]]
then
    echo "The header name or value can not be empty!"
    sleep 2
    clear
    continue
else
echo "Please, check if header name or value is correct."
    sleep 2
    clear
    continue
fi
    header+="%0D%0A$new_header"
    ((i++))
    continue
else
# Regex to escape the backslash and the forward slash inside the header
    header=$(sed -e 's|\\|\\\\|g' -e 's|/|\\/|g' <<< "$header")
    break
fi
done
    break
done
}

# Function GET method

menuGET() {

clear

while :
do

echo -e "${bold_light_yellow}
+---------------------------------------------------------+
A) To test one or more parameters                         |
B) To test with one custom cookie                         |
C) To test with one or more custom headers                |
D) To test with one cookie and one or more custom header  |
E) Flash Mode Test                                        |
    a) param=[XSS]                                        |
    b) param=value[XSS]                                   |
    c) /[XSS]?param=value                                 |
    d) header:[XSS]                                       |
F) Advanced Filter Bypass (AFB) test                      |
G) To test with AFB and one or more custom header         |
H) Return to main menu                                    |
+---------------------------------------------------------+
${endcolor}"

read -p "Choose an option: " opt_2 < /dev/tty
echo -e "\n"
case ${opt_2^^} in

A)
    clear
    magic
    paramGET
    api_call
;;

B)
    clear
    toastCookies
    magic
    cookieGet
    api_call
;;

C)
    clear
    brainHeaders
    moreHeaders
    magic
    headersGet
    api_call
;;

D)
    clear    
    toastCookies
    brainHeaders
    moreHeaders
    magic
    cookHeadGet
    api_call
;;

E)
clear
while :
do

echo -e "${bold_light_yellow}
+--------------------------------+
E) Flash Mode                    |
    a) param=[XSS]               |
    b) param=value[XSS]          |
    c) /[XSS]?param=value        |
    d) header:[XSS]              |
    e) back                      |
+--------------------------------+
${endcolor}"

read -p "Choose an option: " opt_3 < /dev/tty
case ${opt_3,,} in

a)
    clear
    magic
    flashValueGet
    api_call
;;

b)
    clear
    magic
    flashSuffixGet
    api_call
;;

c)
    clear
    magic
    flashPrefixGet
    api_call
;;

d)
    clear
    headerName
    magic
    flashHeaderGet
    api_call
;;

e)
    clear
    break
;;

*)
    echo -e "\nThe option ${bold_red}[$opt_3]${endcolor} do not exist!"
    sleep 3
    clear
;;

esac
done;;

F)
    clear
    magic
    afbGet
    api_call
;;

G)
    clear
    brainHeaders
    moreHeaders
    magic
    afbHeaderGet
    api_call
;;

H)
    clear
    break
;;

*)
    echo -e "\nThe option ${bold_red}[$opt_2]${endcolor} do not exist!"
    sleep 3
    clear
;;

esac
done
}

# Function one or more parameters POST

paramPOST() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed -e 's/#/\&post=/g' -e 's/&post=$//' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function Custom Cookie POST

cookiePost() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed -e 's/#/\&post=/g' -e 's/&post=$//' <<< "$line")
    target="$line&auth=Cookie:$cookie_name=$cookie_value"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&auth=Cookie:$cookie_name=$cookie_value" \
-H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Funciton Custom Header POST

headersPost() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed "s/#/\&auth=$header\&post=/" <<< "$line")
# Regex to remove the carriage return and the linefeed at the end of the last parameter
    line=$(sed 's/%0D%0A$//' <<< $line)
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function custom Cookie and Header POST

cookHeadPost() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed "s/#/\&auth=Cookie:$cookie\&auth=$header\&post=/" <<< "$line")
# Regex to remove the carriage return and the linefeed at the end of the last parameter
    line=$(sed 's/%0D%0A$//' <<< $line)
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function Flash Mode Value POST

flashValuePost() {
while IFS= read -r line
do
# Regex replaces parameter values with [XSS]
    line=$(sed -E -e 's/([A-Za-z0-9!@#$%*. ]+&|[A-Za-z0-9!@#$%*. ]+&?$)/[XSS]\&/g' \
-e 's/&$//' <<< "$line")
    line=$(sed -E -e 's/&/%26/g' <<< "$line")
    line=$(sed -e 's/#/\&post=/g' -e 's/&post=$//' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function Flash Mode Suffix Post

flashSuffixPost() {
while IFS= read -r line
do
# Regex to add [XSS] at the end of the parameter values
    line=$(sed -E -e 's/(&|&?$)/[XSS]\&/g' -e 's/&$//' <<< "$line")
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed -e 's/#/\&post=/g' -e 's/&post=$//' <<< "$line")
    target="$line"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function Advanced Filter Bypass Post

afbPost() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed -e 's/#/\&post=/g' -e 's/&post=$//' <<< "$line")
    target="$line&afb=1"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&afb=1" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Function Advanced Filter Bypass and Header POST

afbHeaderPost() {
while IFS= read -r line
do
    line=$(sed 's/&/%26/g' <<< "$line")
    line=$(sed "s/#/\&auth=$header\&post=/" <<< "$line")
    target="$line&afb=1"
    result=$(curl -X POST https://knoxss.me/api/v3 \
-d "target=$line&afb=1" -H "X-API-KEY: $knoxss_api" -s \
| tee -a "$fresults" 2>> curl.err | jq '[.XSS, .PoC, .Error, ."API Call"]' 2>> jq.err)
    customOutput
done < <(paste -d '#' "$fpost" "$fdata")
stats
}

# Funciton POST method

menuPOST() {

clear

while :
do

echo -e "${bold_light_yellow}
+---------------------------------------------------------+
A) To test one or more parameters                         |
B) To test with one custom cookie                         |
C) To test with one or more custom headers                |
D) To test with one cookie and one or more custom header  |
E) Flash Mode Test                                        |
    a) param=[XSS]                                        |
    b) param=value[XSS]                                   |
F) Advanced Filter Bypass (AFB) test                      |
G) To test with AFB and one or more custom header         |
H) Return to main menu                                    |
+---------------------------------------------------------+
${endcolor}"

read -p "Choose an option: " opt_4 < /dev/tty
echo -e "\n"
case ${opt_4^^} in

A)
    clear
    magic
    paramPOST
    api_call
;;

B)
    clear
    toastCookies
    magic
    cookiePost
    api_call
;;

C)
    clear
    brainHeaders
    moreHeaders
    magic
    headersPost
    api_call
;;

D)
    clear    
    toastCookies
    brainHeaders
    moreHeaders
    magic
    cookHeadPost
    api_call
;;

E)
clear
while :
do

echo -e "${bold_light_yellow}
+--------------------------------+
E) Flash Mode                    |
    a) param=[XSS]               |
    b) param=value[XSS]          |
    c) back                      |
+--------------------------------+
${endcolor}"

read -p "Choose an option: " opt_5 < /dev/tty
case ${opt_5,,} in

a)
    clear
    magic
    flashValuePost
    api_call
;;

b)
    clear
    magic
    flashSuffixPost
    api_call
;;

c)
    clear
    break
;;

*)
    echo -e "\nThe option ${bold_red}[$opt_6]${endcolor} do not exist!"
    sleep 3
    clear
;;

esac
done;;

F)
    clear
    magic
    afbPost
    api_call
;;

G)
    clear
    brainHeaders
    moreHeaders
    magic
    afbHeaderPost
    api_call
;;

H)
    clear
    break
;;

*)
    echo -e "\nThe option ${bold_red}[$opt_5]${endcolor} do not exist!"
    sleep 3
    clear
;;

esac
done
}

# Function GET file

fileGET() {
while :
do
read -p "Enter a filename path with URLs GET (only): " fget < /dev/tty
if [[ ! -a "$fget" && ! -r "$fget" && ! -f "$fget" ]]
then
	echo -e "\n${bold_purple}File${endcolor} ${white}[$fget]${endcolor} \
${bold_purple}doesn't exist or you don't have read access!${endcolor}\n"
    continue
else
    break
fi
done
}

# Function POST file

filePOST() {
while :
do
read -p "Enter a filename path with URLs POST (only): " fpost < /dev/tty
if [[ ! -a "$fpost" && ! -r "$fpost" && ! -f "$fpost" ]]
then
	echo -e "\n${bold_purple}File${endcolor} ${white}[$fpost]${endcolor} \
${bold_purple}doesn't exist or you don't have read access!${endcolor}\n"
    continue
else
    break
fi
done
}

# Function DATA POST file

dataPOST() {
while :
do
read -p "Enter a filename path with POST data (only): " fdata < /dev/tty
if [[ ! -a "$fdata" && ! -r "$fdata" && ! -f "$fdata" ]]
then
	echo -e "\n${bold_purple}File${endcolor} ${white}[$fdata]${endcolor} \
${bold_purple}doesn't exist or you don't have read access!${endcolor}\n"
    continue
else
    break
fi
done
}

# Function Result file

fileResult() {
while :
do
read -p "Enter a filename path to save results, if no, \
just press ENTER key: " fresults < /dev/tty
if [[ ! -a "$fresults" && ! -w "$fresults" && ! -f "$fresults" && "$fresults" != "" ]]
then
    echo -e "\n${bold_purple}File${endcolor} ${white}[$fresults]${endcolor} \
${bold_purple}doesn't exist or you don't have write access!${endcolor}\n"
continue
else
    break
fi
done
}

# Main menu

mainMenu() {

while :
do

echo -e "${bold_light_yellow}
+---------------------+
1) GET Method         |
2) POST Method        |
3) Exit               |
+---------------------+
${endcolor}"

read -p "Choose an option: " opt_1 < /dev/tty
case $opt_1 in

1)
    echo -e "\n"
    fileGET
    fileResult
    [[ "$fresults" == "" || (-a "$fresults" && -w "$fresults" && -f "$fresults") ]] \
&& menuGET
;;

2)
    echo -e "\n"
    filePOST
    dataPOST
    fileResult
    [[ "$fresults" == "" || (-a "$fresults" && -w "$fresults" && -f "$fresults") ]] \
&& menuPOST
;;

3)
    echo -e "\n${italic_light_blue}Don't cry because it's over. \
Smile because it happened!${endcolor}"
    echo -e "${bold_light_gray}
            ( ▀ ͜͞ʖ▀)
    ${endcolor}"
    sleep 2
    exit 0
;;

*)
    echo -e "\nThe option ${bold_red}[$opt_1]${endcolor} do not exist!"
    sleep 3
    clear
;;

esac
done

}


# Function script name

name() {
    echo -e "${bold_cyan}"
        echo -e "        
    ___         __        __ __ _   ______ _  ____________
   /   | __  __/ /_____  / //_// | / / __ \ |/ / ___/ ___/
  / /| |/ / / / __/ __ \/ ,<  /  |/ / / / /   /\__ \\__ \ 
 / ___ / /_/ / /_/ /_/ / /| |/ /|  / /_/ /   |___/ /__/ / 
/_/  |_\__,_/\__/\____/_/ |_/_/ |_/\____/_/|_/____/____/  
                                                          \n"
    echo -e "${endcolor}"
    echo -e "${bg_red}KNOXSS${endcolor} \
${italic_light_blue}was created by ${endcolor}\
${bold_light_gray}Rodolfo Assis${endcolor} \
${italic_light_blue}(a.k.a @brutelogic)${endcolor}"
    echo -e "${italic_light_blue}This tool by ${endcolor}\
${bold_light_gray}Diego Moicano${endcolor} \
${italic_light_blue}(a.k.a @hihackthis)${endcolor}\n"
}

name

while :
do
    read -p "Enter a KNOXSS API: " knoxss_api < /dev/tty
    clear
    
    # Regex in keeping with KNOXSS API standard    
    ER='[^A-Za-z0-9-]+'
    
    [[ "$knoxss_api" =~ $ER ]] && echo -e "\nEnter a correct \
${bg_red}KNOXSS API${endcolor}\n" ||
    
    if [[ -z "$knoxss_api" || "${#knoxss_api}" -ne 36 ]]
    then
        echo -e "\nOops ${bg_red}KNOXSS API${endcolor} unknown\n"
    else
    echo -e "${bold_light_gray}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@==:::*#-::--@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@%==---*#=-===#@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@%%@@@#==#@@@@#@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@##@*+#**+@%*%@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@*#@+=-:==@#*@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@%+*#=--=**+@%@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@%@@+-======@@%@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@#%@@@*#*#%#@@@%#@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@%*-. .=+#+*@@#=#+-. .:=#@@@@@@@@@@@@@
@@@@@@@@%#**=.  .... .. .. .....:..  .=%@@@@@@@@@@
@@@@%+:.     ......::::-:.:::::::..... ..::-=#@@@@
@@@+.   .......       ..-=..        ....      :#@@
@@-  ...... ............ -. .        .. ......  %@
@+ .........:. ......... -:  ====-==-.:........ -@
@-:.     . :. .............  -==-::--.:       ::.@
@:  :=+##%%#=:.   ....      ...:--.  .===+=-:. :=@
*.+%@@@@@@@@@@%#*...  .:=+#%%@@@@@@#:-@@@@@@@%*: *
+%@@@@@@@@@%@@@@@@%%%%@@@@@@@@@@@@%@@%@@@@@@@@@@*-
@@@@@@@@@@@@@@@@@@@@@@@#+@@@@@@@%%@@@@@@@@@@@@@@@%
@@@@@@@@@@@@@@#+@@++@#=%*-*@@@%#%@@@@@@@@@@@@@@@@@
@@@@@@@@@@%.+%*#+=%*-*+*%#%@%##%@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@#..*@%+*%#%%#%@%##%@@@@@@@@@@@@@@@@@@@@
@@@@@@@@==**++=#@%#@@@@%#*#@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@#++*@@@@@@%#+-::-=*##%%@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@*=--:.      ...::--======%%@@@@@@@@@@
@@@@@@@@@@@@@%.    .......           *@@@@@@@@@@@@
${endcolor}"
        mainMenu
fi
done

# End of script
