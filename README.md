# autoKNOXSS

<div align="center">

![](https://img.shields.io/badge/build-passing-yellow) ![](https://img.shields.io/badge/bash-linux-brightgreen) ![](https://img.shields.io/badge/release-v1.0-blue) ![](https://img.shields.io/badge/hack-life-orange) ![](https://img.shields.io/badge/made-brazil-red)


$\large\color{cyan}{\textsf{autoKNOXSS}}$ is a $\large\color{red}{\textsf{KNOXSS API}}$ wrapper.
  
![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/01.png)

</div>

### Summary


:small_blue_diamond: [About autoKNOXSS](#about-autoknoxss)

:small_blue_diamond: [How to install](#how-to-install)

:small_blue_diamond: [How to use](#how-to-use)

:small_blue_diamond: [Menu](#menu)

:small_blue_diamond: [Cookies and headers names and values](#cookies-and-headers-names-and-values)

:small_blue_diamond: [Flash Mode](#flash-mode)

:small_blue_diamond: [Advanced Filter Bypass](#advanced-filter-bypass)

:small_blue_diamond: [Output and Logs](#output-and-logs)

:small_blue_diamond: [Firewall and WAF](#firewall-and-waf)

:small_blue_diamond: [Final words](#final-words)

## About autoKNOXSS

$\large\color{cyan}{\textsf{autoKNOXSS}}$ is a tool that uses a $\large\color{red}{\textsf{KNOXSS API}}$ and automates all tasks easily and quickly.

Do you know $\large\color{purple}{\textsf{KNOXSS}}$?

*KNOXSS has a high level of confidence by design. It has almost zero false positive rates and a low false negative rate regarding its XSS coverage.*

More info: [KNOXSS](https://knoxss.me/)

*KNOXSS API is another way to query KNOXSS system if it can find and prove an XSS vulnerability in a given target page.*

More info: [KNOXSS API](https://knoxss.me/?page_id=2729)

## How to install

Very easy, doesn't need to install, just:

```
1. clone this repo:
   - git clone https://github.com/hihackthis/autoKNOXSS
2. cd autoKNOXSS/
3. chmod +x autoKNOXSS.sh
   - ./autoKNOXSS.sh
```

**NOTE**: $\large\color{cyan}{\textsf{autoKNOXSS}}$ does use the **jq** tool. :warning:

## How to use

$\large\color{cyan}{\textsf{autoKNOXSS}}$ is really simple to use:

1. Enter your $\large\color{red}{\textsf{KNOXSS API}}$
2. Choose a request method (GET or POST)
3. Enter the [PATH/]filename and DO NOT put it between quotes

If you choose the GET method then you must provide a filename containing one or more URLs one below the other. DO NOT put URL with the POST method here.

Example:

```
URL1
URL2
URL3
BLANK
```
Look this:

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/05.png)

If you choose the POST method then you must provide two filenames:

The first filename **(A)**, and always the first, must contain one or more URLs one below the other. DO NOT put the URL with the GET method here.
the second filename **(B)**, and always the second, must contain the parameters (data) one below the other of their respective URLs.

Like this:
```
(A)                                (B)
URL1                              DATA1
URL2                              DATA2
URL3                              DATA3
BLANK                             BLANK
```

Pay attention: these two filenames are, let's say, complementary, one completes the other, of course. In other words, the first URL in **A** has its data corresponding to the first line in **B**; the second URL of **A** has its corresponding data on the second line in **B**, and so on. Just like this:

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/04.png)

- **NOTE1**: always leave the last line blank in the file, otherwise the last or unique URL not will be loaded by $\large\color{cyan}{\textsf{autoKNOXSS}}$.

- **NOTE2**: you can enter the filename by absolute or relative path.

- **NOTE3**: if the filename contains space(s) then just type the filename with the space(s). Ex: urls GET

- **NOTE4**: if the path file contains space(s) then just type the file path with the space(s). Ex: /home/BLA BLA/

- **NOTE5**: don't use the backslash [ \ ] as an espace separator, or quotes [ " or ' ].

- **NOTE6**: the parameter separator, ampersand [ & ], it's not necessary to encode [ %26 ], as the $\large\color{cyan}{\textsf{autoKNOXSS}}$ does that for you. :vulcan_salute:

## Menu

After entering your $\large\color{red}{\textsf{KNOXSS API}}$ key, a simple menu will appear for you (GET or POST), after that, we have a complete menu. Let's say you choose the GET method (pretty much the two menus are the same):

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/10.png)

- A) You will test one or more parameters of each URL;
- B) Same as option A, but you can add a custom cookie (mandatory);
- C) Same as option A, but you can add one (mandatory) or more custom headers (optional);
- D) Same as option A, plus options B and C;
- E) You will test all parameters of each URL using Flash Mode;
- F) You will test one or more parameters of each URL using AFB;
- G) You will test one or more parameters of each URL using AFB, plus option C.

## Cookies and headers names and values

You don't need to escape any special character contained in cookie and header names and values. For example, if use a ***User-Agent***, then it looks like this:

> Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36

In this case, does not necessarily escape the forward slash [ / ] and the parentheses [ ( ) ].

About the names and values of cookies and headers, $\large\color{cyan}{\textsf{autoKNOXSS}}$ follows the standard of RFC 6265 and RFC 9110, that is, if any disallowed character is part of a cookie or header, then it will be blocked through a stubborn regex. :muscle:

- **NOTE1**: the regex controls which characters are allowed, and not how you write them. So if you write 'Host' like this, it will be sent to $\large\color{cyan}{\textsf{autoKNOXSS}}$ like this.

- **NOTE2**: be careful with the Host header as it can crash some requests made by $\large\color{purple}{\textsf{KNOXSS}}$.

- **NOTE3**: it's good to know that the ***User-Agent*** arriving at the client is the one being sent by $\large\color{purple}{\textsf{KNOXSS}}$, that means that if you add a ***User-Agent*** then two ***User-Agents*** will arrive at the client, the one from $\large\color{purple}{\textsf{KNOXSS}}$ and yours.

- **NOTE4**: the $\large\color{cyan}{\textsf{autoKNOXSS}}$ accepts one cookie and one or more headers.

## Flash Mode

$\large\color{cyan}{\textsf{autoKNOXSS}}$ does all the tests allowed in this mode, and all of them, in an automated way.

```
a) param=value[XSS]
b) param=[XSS]
c) /[XSS]?param=value 
d) header:[XSS]
```

- **NOTE1**: all parameters will be tested with **[XSS]**, it is still not possible to choose which parameter will receive **[XSS]**, at least in this version of $\large\color{cyan}{\textsf{autoKNOXSS}}$.

Ex:
```
p1=[XSS]
p1=[XSS]&p2=[XSS]
p1=[XSS]&p2=[XSS]&p2=[XSS]
```

- **NOTE2**: you don't need to add the **[XSS]**, because the $\large\color{cyan}{\textsf{autoKNOXSS}}$ does that for you. :heart_eyes:

## Advanced Filter Bypass

$\large\color{cyan}{\textsf{autoKNOXSS}}$ does all tests allowed in this mode in an automated way.

## Output and Logs

After you add the filename containing the URLs, $\large\color{cyan}{\textsf{autoKNOXSS}}$ will ask if you want to add a file to save the output, that is, a result in addition to the one shown on the screen. Close attention now, we have to notice a big difference between one (screen output) and the other (file output).

The screen output is fully customized by $\large\color{cyan}{\textsf{autoKNOXSS}}$ as its main objective is to show in a few lines the result(s) obtained.

The file output is more verbose, it is the traditional output of the $\large\color{red}{\textsf{KNOXSS API}}$, so in this file, you will have more details of the results, so that you can later do your own debugging and select contents using, for example, the grep command.

***Screen Output***

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/02.png)

***File Output***

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/03.png)

Another thing, whenever $\large\color{cyan}{\textsf{autoKNOXSS}}$ is run it will create two files: curl.err and jq.err.

:ballot_box_with_check: curl.err: this will log all errors in the $\large\color{red}{\textsf{KNOXSS API}}$ curl command

:ballot_box_with_check: jq.err: this will log any errors in the jq command in the JSON output of the $\large\color{red}{\textsf{KNOXSS API}}$ curl command

For example, if you decide not to include a file to store the results, the following message will be logged in curl.err:

> tee: '': No such file or directory

- **NOTE**: logged errors will not be overwritten, but logged on the next line.

## Firewall and WAF

Some firewalls block the $\large\color{red}{\textsf{KNOXSS API}}$, and this crashes the JSON output, and the URL source code will be shown on the screen, and in this case, $\large\color{cyan}{\textsf{autoKNOXSS}}$ shows the following output:

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/09.png)

Now, if you see the output in the file (if you added it) will be:

![](https://github.com/hihackthis/autoKNOXSS/blob/main/images/08.png)

## Final words 

Have fun! :money_mouth_face:

<div align="center">

[!["Buy Me A Cake"](https://github.com/hihackthis/autoKNOXSS/blob/main/images/06.png)](https://bmc.link/moicanodieQ) 

[!["Paypal"](https://github.com/hihackthis/autoKNOXSS/blob/main/images/07.png)](https://www.paypal.com/donate/?hosted_button_id=UC7N8XFXNQCPA)

</div>

Heartfelt thanks :sunglasses:
