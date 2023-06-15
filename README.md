# autoKNOXSS

- Wrapper KNOXSS API

## About autoKNOXSS

autoKNOXSS is a tool that uses a KNOXSS API and automates all tasks easily and quickly.

Do you know KNOXSS?

KNOXSS has a high level of confidence by design. It has almost zero false positive rates and a low false negative rate regarding its XSS coverage.

More info: [KNOXSS](https://knoxss.me/)

KNOXSS API is another way to query KNOXSS system if it can find and prove an XSS vulnerability in a given target page.

More info: [KNOXSS API](https://knoxss.me/?page_id=2729)

## How to use

autoKNOXSS is really simple to use:

1. Enter your KNOXSS API
2. Choose a request method (GET or POST)
3. Enter the [PATH/]filename and DO NOT put it between quotes

If you choose the GET method then you must provide a filename containing one or more URLs one below the other. DO NOT put URL with the POST method here.

Example:

```
URL1
URL2
URL3
ESPACE
```

If you choose the POST method then you must provide two filenames:

the first filename (A), and always the first, must contain one or more URLs one below the other. DO NOT put the URL with the GET method here.
the second filename (B), and always the second, must contain the parameters (data) one below the other of their respective URLs.

Like this:
```
(A)                                (B)
URL1                              DATA1
URL2                              DATA2
URL3                              DATA3
ESPACE                            ESPACE
```

Pay attention: these two filenames are, let's say, complementary, one completes the other, of course. In other words, the first URL in A has its data corresponding to the first line in B; the second URL of A has its corresponding data on the second line in B, and so on.

- NOTE1: always leave the last line blank in the file, otherwise the last or unique URL not will be loaded by autoKNOXSS.

- NOTE2:  you can enter the filename by absolute or relative path.

- NOTE3: if the filename contains space(s) then just type the filename with the space(s). Ex: urls GET

- NOTE4: if the path file contains space(s) then just type the file path with the space(s). Ex: /home/BLA BLA/

- NOTA5: don't use the backslash [ \ ] as an espace separator, or quotes [ " or ' ].

- NOTE6: the parameter separator, ampersand [ & ], it's not necessary to encode [ %26 ], because the autoKNOXSS is prepared to do that itself.

## Cookies and headers names and values

You don't need to escape any special character contained in cookie and header names and values. For example, if use a User-Agent, then it looks like this:

Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36

In this case, does not necessarily escape the forward slash [ / ] and the parentheses [ ( ) ].

About the names and values of cookies and headers, autoKNOXSS follows the standard of RFC 6265 and RFC 9110, that is, if any disallowed character is part of a cookie or header, then it will be blocked through a stubborn regex.

- NOTE1: It's good to know that the User-Agent arriving at the client is the one being sent by KNOXSS, that means that if you add a User-Agent then two User-Agents will arrive at the client, the one from KNOXSS and yours.

- NOTE2: the autoKNOXSS accepts one cookie and one or more headers.

## Flash Mode

autoKNOXSS does all the tests allowed in this mode, and all of them, in an automated way.

```
a) param=value[XSS]
b) param=[XSS]
c) /[XSS]?param=value 
d) header:[XSS]
```

- NOTE1: all parameters will be tested with [XSS], it is still not possible to choose which parameter will receive [XSS], at least in this version of autoKNOXSS.

Ex:
```
p1=[XSS]
p1=[XSS]&p2=[XSS]
p1=[XSS]&p2=[XSS]&p2=[XSS]
```

- NOTE2: you don't need to add the [XSS], because the autoKNOXSS does that for you.

## AFB

autoKNOXSS does all tests allowed in this mode in an automated way.

## Output and Logs

After you add the filename containing the URLs, autoKNOXSS will ask if you want to add a file to save the output, that is, a result in addition to the one shown on the screen. Close attention now, we have to notice a big difference between one (screen output) and the other (file output).

The screen output is fully customized by autoKNOXSS as its main objective is to show in a few lines the result(s) obtained.

The file output is more verbose, is the traditional output of KNOXSS API, so in this file, you will have more details of the results, you will make your own debug and select content using, for example, the grep command.

The file output is more verbose, it is the traditional output of the KNOXSS API, so in this file, you will have more details of the results, so that you can later do your own debugging and select contents using, for example, the grep command.

Another thing, whenever autoKNOXSS is run it will create two files: curl.err and jq.err.

- [x] curl.err ==> this will log all errors in the KNOXSS API curl command
- [x] jq.err ==> this will log any errors in the jq command in the JSON output of the KNOXSS API curl command

For example, if you decide not to include a file to store the results, the following message will be logged in curl.err:

> tee: '': No such file or directory

- NOTE: Logged errors will not be overwritten, but logged on the next line.

## Firewall

Some firewalls block the KNOXSS API, and this crashes the JSON output, and the URL source code will be shown on the screen, and in this case, autoKNOXSS hides the output, it will be sent to limbo, the /dev/null.
