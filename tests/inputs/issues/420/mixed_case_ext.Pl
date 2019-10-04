# https://stackoverflow.com/questions/1721807/how-do-i-create-then-use-long-windows-paths-from-perl#1722223
use Win32::API;
$cd = Win32::API->new('kernel32', 'CreateDirectoryW', 'PP', 'N');
$dir = '\\\\?\\c:\\Users\\IEUser\\!long_dir';

$res = 1;

my $i = 1;
do {
    print 'path length: ' . length($dir) . "\n";
    $dirname = pack('S*', unpack('C*', "$dir\0"));  #dirty way to produce UTF-16LE string

    $res = $cd->Call($dirname, 0);
    print "$res\n";

    $dir .= '\\' . sprintf "D%09d", $i;
    ++$i;
    $res = 0 if $i > 30;

} while ( $res );
