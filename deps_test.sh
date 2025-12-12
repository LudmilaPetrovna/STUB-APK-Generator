#!/bin/bash

echo -e "\n. . . - - - ---=:[java version]:=--- - - . . ."
java --version

echo -e "\n. . . - - - ---=:[javac version]:=--- - - . . ."
javac --version

echo -e "\n. . . - - - ---=:[unzip version]:=--- - - . . ."
unzip -v | grep UnZip | grep Info-ZIP

echo -e "\n. . . - - - ---=:[apksigner version]:=--- - - . . ."
apksigner --version

echo -e "\n. . . - - - ---=:[keytool version]:=--- - - . . ."
keytool --help 2>&1 | grep "Certificate Management"

echo -e "\n. . . - - - ---=:[dx version]:=--- - - . . ."
dx --version

echo -e "\n. . . - - - ---=:[zip version]:=--- - - . . ."
zip -v | grep "This is Zip"

echo -e "\n. . . - - - ---=:[apksigtool version]:=--- - - . . ."
apksigtool --version

echo -e "\n. . . - - - ---=:[7z version]:=--- - - . . ."
7z | grep "p7zip Version"

echo -e "\n. . . - - - ---=:[adb version]:=--- - - . . ."
adb version | grep version

echo -e "\n. . . - - - ---=:[android.jar]:=--- - - . . ."
[ `unzip -l android.jar | grep resources.arsc | wc -l` = '0' ] && echo "NO" || echo "YES"

echo -e "\n. . . - - - ---=:[apktool_2.12.1.jar]:=--- - - . . ."
[ `unzip -l apktool_2.12.1.jar | grep brut/androlib | wc -l` = '0' ] && echo "NO" || echo "YES"
