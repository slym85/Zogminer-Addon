# Zogminer-Addon
Autostart.sh

This little script is intended to sun 2 instance per GPU of Zogminer 

I run it on Ubuntu 15.10 with no issues 

Prereq : typescript moreutils screen
For Ubuntu run : 
$ sudo apt-get update && sudo apt-get install typescript moreutils screen

If you still have dependencies issues, especially with typescript,  run : ( thx GGG ! )

$ sudo apt-get install npm
$ npm install -g typescript
$ sudo apt-get install moreutils screen


Put the scrip in Zogminer folder and run it after editing your wallet, POOL, GPU number, donation preferences ( default is ON ! )  and "MAXTIME"

Maxtime is the maximum lag time allowed before restarting the miner .. 
Be aware there is some lag from the time the miner executes hashes and the time the script writes it in the file.
I have a good result with 300 sec


Improvement CLI will be added asap.

Njoy !
