#!/usr/bin/perl

use File::Slurp;
use File::Basename;
use File::Copy;
use File::Path qw(make_path remove_tree);

$PASS_CERT_NEW='shit123';
$FRAMEWORK='android.jar';
$SRCVERSION='1.7';

$src_apk=$ARGV[0];
if(!$src_apk){
die "Usage: ".__FILE__." file.apk\n\n";
}

# read dummy classes
%ref_code=();
map{$ref_code{$_}=read_file("ref_code/".$_.".java")}qw/a b c s o ccf/;
%types=qw/activity a receiver b service s provider c application o ccf ccf/;

# prepare fresh space
`rm -rf new_code new_app new_bin obj raw unpacked`;

print "Unpacking resources using apktool...\n";
print `java -jar apktool_2.12.1.jar d -s -p . -o unpacked "$src_apk"`;

print "Unpacking raw apk with unzip...\n";
print `unzip -d raw "$src_apk"`;

# code gen
$m=read_file('unpacked/AndroidManifest.xml');
$pkg='';
if($m=~/ package=\"([^\"]+)\"/){$pkg=$1;}
if($m=~/ android:appComponentFactory=\"([^\"]+)\"/){push(@coms,["ccf",$1]);}
@els=();
while($m=~/(<(activity|receiver|service|provider|application)[^>]+>)/gs){
push(@els,[$2,$1]);
}
foreach(@els){
($type,$line)=@{$_};
if($line=~/android:name=\"([^\"]+)\"/){
$name=$1;
push(@coms,[$type,$name]);
}
}

$FILE_CERT_INFO='cert_'.$pkg.'_orig_verify.txt';
$FILE_CERT_NEW='cert_'.$pkg.'_new.jks';


# create new cert
if(!-s($FILE_CERT_NEW)){

if(!-s($FILE_CERT_INFO)){
`apksigner verify --verbose --print-certs "$src_apk" > "$FILE_CERT_INFO"`;
}

$oc=read_file($FILE_CERT_INFO);
$keysize=1024;
$dn="CN=1";
if($oc=~/key size \(bits\): (\d+)/){$keysize=$1;}
if($oc=~/certificate DN: ([^\n]+)/){$dn=$1;}

`keytool -genkey -keyalg rsa -keystore $FILE_CERT_NEW -storepass $PASS_CERT_NEW -keypass $PASS_CERT_NEW -alias shit -keysize $keysize -dname "$dn" -validity 5555`
}

# copy original resources and images
if(!-d("new_app")){
@orig_files=`find raw -type f | cut -d/ -f2-`;
chomp(@orig_files);
@keep_files=grep{/\.(jpe?g|png|webp|xml|arsc)$/i || /^res\/drawable/s}@orig_files;
foreach $f(@keep_files){
$o="raw/".$f;
$n="new_app/".$f;
$d=dirname($n);
make_path($d);
print "Copy $o --> $n\n";
copy($o,$n);
}
}

# generating components code
foreach(@coms){
($type,$name)=@{$_};
if(substr($name,0,1) eq "."){
$name=$pkg.$name;
}
$path=$name;
$path=~tr/\./\//;
$classname=basename($path);
$filename="new_code/".$path.".java";
$compiled="obj/".$path.".class";
$cf=$ref_code{$types{$type}};
$package_file=$name;
$package_file=~s/\.[^\.]+$//s;
$cf=~s/^package [^\n]+/package $package_file;/s;
$cf=~s/public class \S/public class $classname/s;
print "Writing ---> $filename\n";
make_path(dirname($filename));
write_file($filename,$cf);
push(@javas,$filename);
push(@classes,$compiled);
}
write_file('compile_java.txt',join("\n",@javas));

print "Compiling generated code...\n";
make_path('obj');
`javac -Xlint:removal,-deprecation,-options -d obj -sourcepath src -source $SRCVERSION -target $SRCVERSION --class-path "$FRAMEWORK" \@compile_java.txt`;

foreach(@classes){
print "Compiled $_ ".(-s($_))." bytes\n";
}

print "Converting code to DEX...\n";
make_path('new_bin');
print `dx --dex --verbose --no-optimize --keep-classes --output=new_bin/classes.dex obj`;

print "Packaging in APK...\n";

$apk=$pkg.'.apk';

$OUT_APK="../new_bin/out.apk";
chdir 'new_app';
print `zip -0r "$OUT_APK" AndroidManifest.xml resources.arsc res`;
print `zip -9j "$OUT_APK" ../new_bin/classes.dex`;
chdir '..';

print `zipalign -f -v 4 new_bin/out.apk new_bin/out-aligned.apk`;
unlink('new_bin/out.apk');
move('new_bin/out-aligned.apk',$apk);

print "Signing APK $apk...\n";
print `apksigner sign --v1-signing-enabled --v2-signing-enabled --v3-signing-enabled --ks $FILE_CERT_NEW --ks-pass pass:$PASS_CERT_NEW --key-pass pass:$PASS_CERT_NEW "$apk"`;
print `apksigtool parse "$apk"`;

print "Creating 7z distributive $apk -> $pkg.7z...\n";
unlink("$pkg.7z");
print `7z a $pkg.7z "$apk"`;

print "Uploading to device...\n";
print `adb push "$apk" /sdcard/`;
