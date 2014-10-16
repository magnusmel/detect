#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Cwd;
use File::Find;
use Getopt::Long;

my %flags;
Getopt::Long::Configure("pass_through");
GetOptions("help"	      => \$flags{'help'},
           "all"	      => \$flags{'all'},
           "wordpress"	      => \$flags{'wordpress'},
           "joomla"	      => \$flags{'joomla'},
           "magento"	      => \$flags{'magento'},
           "drupal"	      => \$flags{'drupal'},
           "whmcs"            => \$flags{'whmcs'},
           "zencart"          => \$flags{'zencart'},
           "moodle"           => \$flags{'moodle'},
           "prestashop"       => \$flags{'prestashop'},
           "mambo"            => \$flags{'mambo'},
           "opencart"         => \$flags{'opencart'},
           "vtiger"           => \$flags{'vtiger'},
           "phpbb"            => \$flags{'phpbb'},
           "tomatocart"       => \$flags{'tomatocart'},
           "mybb"             => \$flags{'mybb'},
           "pligg"            => \$flags{'pligg'}
	  );

foreach my $bad (@ARGV) { print "Unknown option: $bad\n" }
if (@ARGV) { die(show_help()) }
if (defined($flags{'help'})) { die(show_help()) }

my $docroots = from_apache();
my %attr     = (
		PrintError => 0,
		RaiseError => 0
               );

my @wordpress_out = [];
my @joomla_out = [];
my @magento_out = [];
my @drupal_out = [];
my @whmcs_out = [];
my @moodle_out = [];
my @prestashop_out = [];
my @mybb_out = [];
my @phpbb_out = [];
my @pligg_out = [];
my @zencart_out = [];
my @mambo_out = [];
my @opencart_out = [];
my @vtiger_out = [];
my @tomatocart_out = [];

my $dash = "-------------------------";
my %final_out = ('a'	=> @wordpress_out,
		 'b'	=> @joomla_out,
                 'c'	=> @magento_out,
                 'd'	=> @drupal_out,
                 'e'	=> @whmcs_out,
                 'f'	=> @moodle_out,
                 'g'	=> @prestashop_out,
                 'h'	=> @mybb_out,
                 'i'	=> @phpbb_out,
                 'j'	=> @pligg_out,
                 'k'	=> @zencart_out,
                 'l'	=> @mambo_out,
                 'm'	=> @opencart_out,
                 'n'	=> @vtiger_out,
                 'o'	=> @tomatocart_out
		);

find (\&find_stuff, getcwd);
foreach my $key(sort keys %final_out) {
    if ($key eq 'a' and defined($final_out{$key}) and (defined($flags{'wordpress'}) or defined($flags{'all'}))) {
	print "$dash\nWordPress\n$dash\n";
	foreach my $val (@{$final_out{$key}}) {
	    print "$val";
	}
    }
    if ($key eq 'b' and defined($final_out{$key}) and (defined($flags{'joomla'}) or defined($flags{'all'}))) {
        print "$dash\nJoomla\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'c' and defined($final_out{$key}) and (defined($flags{'magento'}) or defined($flags{'all'}))) {
        print "$dash\nMagento\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'd' and defined($final_out{$key}) and (defined($flags{'drupal'}) or defined($flags{'all'}))) {
        print "$dash\nDrupal\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'e' and defined($final_out{$key}) and (defined($flags{'whmcs'}) or defined($flags{'all'}))) {
        print "$dash\nWHMCS\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'f' and defined($final_out{$key}) and (defined($flags{'moodle'}) or defined($flags{'all'}))) {
        print "$dash\nMoodle\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'g' and defined($final_out{$key}) and (defined($flags{'prestashop'}) or defined($flags{'all'}))) {
        print "$dash\nPrestashop\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'h' and defined($final_out{$key}) and (defined($flags{'mybb'}) or defined($flags{'all'}))) {
        print "$dash\nMyBB\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'i' and defined($final_out{$key}) and (defined($flags{'phpbb'}) or defined($flags{'all'}))) {
        print "$dash\nphpBB\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'j' and defined($final_out{$key}) and (defined($flags{'pligg'}) or defined($flags{'all'}))) {
        print "$dash\nPligg\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'k' and defined($final_out{$key}) and (defined($flags{'zencart'}) or defined($flags{'all'}))) {
        print "$dash\nZenCart\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'l' and defined($final_out{$key}) and (defined($flags{'mambo'}) or defined($flags{'all'}))) {
        print "$dash\nMambo\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'm' and defined($final_out{$key}) and (defined($flags{'opencart'}) or defined($flags{'all'}))) {
        print "$dash\nOpenCart\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'n' and defined($final_out{$key}) and (defined($flags{'vtiger'}) or defined($flags{'all'}))) {
        print "$dash\nvTiger\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
    if ($key eq 'o' and defined($final_out{$key}) and (defined($flags{'tomatocart'}) or defined($flags{'all'}))) {
        print "$dash\nTomatoCart\n$dash\n";
        foreach my $val (@{$final_out{$key}}) {
            print "$val";
        }
    }
}

sub show_help {
    my $output = "\nUsage:\tdetect [options]\n";
    $output .= "\t--help\t\tShow help page\n";
    $output .= "\t--all\t\tShow information on all CMS installations\n";
    $output .= "\t--wordpress\tShow information on all WordPress installations\n";
    $output .= "\t--joomla\tShow information on all Joomla installations\n";
    $output .= "\t--magento\tShow information on all Magento installations\n";
    $output .= "\t--drupal\tShow information on all Drupal installations\n";
    $output .= "\t--whmcs\t\tShow information on all WHMCS installations\n";
    $output .= "\t--zencart\tShow information on all ZenCart installations\n";
    $output .= "\t--moodle\tShow information on all Moodle installations\n";
    $output .= "\t--prestashop\tShow information on all Prestashop installations\n";
    $output .= "\t--mambo\t\tShow information on all Mambo installations\n";
    $output .= "\t--opencart\tShow information on all OpenCart installations\n";
    $output .= "\t--vtiger\tShow information on all vTiger installations\n";
    $output .= "\t--phpbb\t\tShow information on all phpBB installations\n";
    $output .= "\t--tomatocart\tShow information on all TomatoCart installations\n";
    $output .= "\t--mybb\t\tShow information on all MyBB installations\n";
    $output .= "\t--pligg\t\tShow information on all Pligg installations\n\n";
    return $output;
}

sub find_stuff {
    my ($wp,$mag,$jml,$drp,$whm,$zen,$moo) = ('','','','','','','');
    my ($ps,$mam,$tc,$vt,$php,$pl,$oc,$bb) = ('','','','','','','','');
    if (-d and $File::Find::dir =~ /(.*)?(virtfs|mail|ima?ge?s?|cache|cpan|mail)(.*)?/) {
	$File::Find::prune = 1;
	return
    }
    $wp  .= wordpress($File::Find::name) if $File::Find::name =~ /(.*)?wp-admin$/;
    $jml .= joomla($File::Find::name) if $File::Find::name =~ /(.*)?libraries\/joomla$/;
    $mag .= magento($File::Find::name) if $File::Find::name =~ /(.*)?Mage_All.txt$/;
    $drp .= drupal($File::Find::name) if $File::Find::name =~ /(.*)?drupal.js$/;
    $whm .= whmcs($File::Find::name) if $File::Find::name =~ /(.*)?whmcs.js$/;
    $zen .= zencart($File::Find::name) if $File::Find::name =~ /(.*)?0.about_zen_cart.html$/;
    $moo .= moodle($File::Find::name) if $File::Find::name =~ /(.*)?moodlelib.php$/;
    $ps  .= prestashop($File::Find::name) if $File::Find::name =~ /(.*)?prestashop.pub$/;
    $mam .= mambo($File::Find::name) if $File::Find::name =~ /(.*)?mambo_admin$/;
    $tc  .= tomatocart($File::Find::name) if $File::Find::name =~ /(.*)?tomatocart_clock.png$/;
    $vt  .= vtiger($File::Find::name) if $File::Find::name =~ /(.*)?uninstallvtiger.sh$/;
    $php .= phpbb($File::Find::name) if $File::Find::name =~ /(.*)?\/bbcode.php$/;
    $pl  .= pligg($File::Find::name) if $File::Find::name =~ /(.*)?Pligg-API-Installation.txt$/;
    $oc  .= opencart($File::Find::name) if $File::Find::name =~ /(.*)?catalog\/controller\/amazonus$/;
    $bb  .= mybb($File::Find::name) if $File::Find::name =~ /(.*)?mybb_group.php$/;
    push(@{$final_out{'a'}}, $wp) if $wp ne '';
    push(@{$final_out{'b'}}, $jml) if $jml ne '';
    push(@{$final_out{'c'}}, $mag) if $mag ne '';
    push(@{$final_out{'d'}}, $drp) if $drp ne '';
    push(@{$final_out{'e'}}, $whm) if $whm ne '';
    push(@{$final_out{'f'}}, $moo) if $moo ne '';
    push(@{$final_out{'g'}}, $ps) if $ps ne '';
    push(@{$final_out{'h'}}, $bb) if $bb ne '';
    push(@{$final_out{'i'}}, $php) if $php ne '';
    push(@{$final_out{'j'}}, $pl) if $pl ne '';
    push(@{$final_out{'k'}}, $zen) if $zen ne '';
    push(@{$final_out{'l'}}, $mam) if $mam ne '';
    push(@{$final_out{'m'}}, $oc) if $oc ne '';
    push(@{$final_out{'n'}}, $vt) if $vt ne '';
    push(@{$final_out{'o'}}, $tc) if $tc ne '';
}

sub from_apache {
    my %out;
    my $dom = '';
    my $root = '/usr/local/apache/htdocs';
    my $file = '/usr/local/apache/conf/httpd.conf';
    my $host = 'cpanel.';
    open(DATA, "<$file");
    while (<DATA>) {
        chomp $_;
        $dom = (split(' ', $_))[1] if $_ =~ /ServerAlias/ and $_ !~ /$host/;
	if ($dom =~ /^www\./) { $dom = (split('www.', $dom))[-1] }
        $out{$dom} = '' if $_ =~ /ServerAlias/ and $_ !~ /$host/;
        $out{$dom} = (split(' ', $_))[1] if $_ =~ /DocumentRoot/ and $_ !~ /$root/;
    }
    close DATA;
    return \%out; }

sub from_hash {
    my $p = $_;
    my ($end, $out) = ('','');
    while ($out eq '') {
	foreach my $key (keys %{$docroots}) {
	    if ($p eq ${$docroots}{$key}.'/') {
		my @tmp = split($p, $_);
		if (@tmp == 2) { $end = $tmp[-1] }
		$out = "http://$key/$end";
	    }
	}
	my $last = (split('/', $p))[-1].'/';
	$p = join('/', (split("$last", $p)));
	if ($p eq '/') {
	    $out = "Unable to be determined";
	    last;
	}
    }
    return $out; }

sub define {
    my $out = $_[0];
    $out = (split(',', $out))[-1];
    $out =~ s/\s//g;
    $out = (split(';', $out))[0];
    $out =~ s/^.(.*)..$/$1/g;
    return $out; }

sub equals {
    my $out = $_[0];
    $out = (split('=', $out))[-1];
    $out =~ s/\s//g;
    $out =~ s/^.(.*)..$/$1/g;
    return $out; }

sub xml {
    my $out = $_[0];
    $out = (split(/\]/, (split(/\[/, $out))[2]))[0];
    return $out; }

sub wordpress {
    my $output = '';
    $_ = (split('wp-admin', $File::Find::name))[0];
    my $cfg = $_."wp-config.php";
    my $inc = $_."wp-includes/version.php";
    my $last = (split('/', $_))[-1].'/';
    my $alt = join('/', (split("$last", $_))).'wp-config.php';
    if ( ! -f $cfg) { $cfg = $alt }
    if (-f $cfg and -f $inc) {
	my ($url,$name,$pass,$user,$host,$ver,$pre) = ('','','','','', '', '');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['"]DB_NAME/) { $name = define($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['"]DB_USER/) { $user = define($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['"]DB_PASS/) { $pass = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['"]DB_HOST/) { $host = define($line) }
	    if ($line =~ /^( +)?(\t)?\$table_prefix/) { $pre = equals($line) }
        }
	close DATA;
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$wp_version = /) { $ver = equals($line) }
	}
	close DATA;
	$ver = 'Unknown' if $ver eq '';
	my $con = DBI->connect("dbi:mysql:$name", $user, $pass, \%attr);
	if ($con) {
	    my $qry = $con->prepare("SELECT option_value FROM ".$pre."options WHERE option_name='siteurl'");
	    $qry->execute();
	    while (my @row = $qry->fetchrow_array) { $url = join(", ", @row) }
	    my $discon = $con->disconnect;
	}
	$url = from_hash($_) if $url eq '';
	$output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub joomla {
    my $output = '';
    $_ = (split('libraries/joomla', $File::Find::name))[0];
    my $cfg = $_."configuration.php";
    my $inc = $_."libraries/cms/version/version.php";
    if (-f $cfg and -f $inc and -d $_."administrator") {
	my ($ver, $url) = ('','');
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?public \$RELEASE/) { $ver = equals($line) }
	}
	close DATA;
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    if ($line =~ /^( +)?(\t)?public \$live_site/) { $url = equals($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub magento {
    my $output = '';
    $_ = (split('pkginfo/Mage_All.txt', $File::Find::name))[0];
    my $user = '';
    my $inc = $_."app/Mage.php";
    my $cfg = $_."app/etc/local.xml";
    if (-f $cfg and -f $inc) {
	my ($ver,$url,$host,$name,$pass,$user,$pre) = ('','','','','','','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\<username\>/) { $user = xml($line) }
	    if ($line =~ /^( +)?(\t)?\<password\>/) { $pass = xml($line) }
            if ($line =~ /^( +)?(\t)?\<dbname\>/) { $name = xml($line) }
            if ($line =~ /^( +)?(\t)?\<host\>/) { $host = xml($line) }
            if ($line =~ /^( +)?(\t)?\<table_prefix\>/) { $pre = xml($line) }
	}
	close DATA;
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?["']?minor/) {
		$ver = (split('=>', $line))[1];
		$ver =~ s/\s//g;
		$ver =~ s/^.(.*)..$/$1/;
	    }
	}
        my $con = DBI->connect("DBI:mysql:$name", $user, $pass, \%attr);
        if ($con) {
            my $qry = $con->prepare("SELECT option_value FROM ".$pre."options WHERE option_name='siteurl'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $url = join(", ", @row) }
            my $discon = $con->disconnect;
        }
	$url = from_hash($_) if $url eq '';
	$ver eq '' ? $ver = 'Unknown' : $ver = "1.$ver";
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub drupal {
    my $output = '';
    $_ = (split('misc/drupal.js', $File::Find::name))[0];
    my ($cfg,$url,$ver) = ('','','');
    if (-f $_."includes/bootstrap.inc") {
	open(DATA, "<".$_."includes/bootstrap.inc");
	while (my $line = <DATA>) {
	    if ($line =~ /^( +)?(\t)?define\( ?['"]VERSION/) { $ver = define($line) }
	}
	close DATA;
    }
    if (-f $_."modules/system/system.module" and $ver eq '') {
	open(DATA, "<".$_."modules/system/system.module");
	while (my $line = <DATA>) {
	    if ($line =~ /^( +)?(\t)?define\( ?['"]VERSION/) { $ver = define($line) }
        }
        close DATA;
    }
    $ver = 'Unknown' if $ver eq '';
    if (-f $_."sites/default/settings.php" and -d $_."misc") {
	$url = from_hash($_);
	$output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub whmcs {
    my $output = '';
    $_ = (split('templates/default/js/whmcs.js', $File::Find::name))[0];
    my $cfg = $_."configuration.php";
    if (-f $cfg and -f $_."clientarea.php") {
	my ($ver,$url,$host,$name,$pass,$user) = ('','','','','','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$db_password/) { $pass = equals($line) }
            if ($line =~ /^( +)?(\t)?\$db_username/) { $user = equals($line) }
            if ($line =~ /^( +)?(\t)?\$db_name/) { $name = equals($line) }
            if ($line =~ /^( +)?(\t)?\$db_host/) { $host = equals($line) }
	}
	close DATA;
        my $con = DBI->connect("DBI:mysql:$name", $user, $pass, \%attr);
        if ($con) {
            my $qry = $con->prepare("SELECT value FROM tblconfiguration WHERE setting='SystemURL'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $url = join("", @row) }
            $qry = $con->prepare("SELECT value FROM tblconfiguration WHERE setting='Version'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $ver = join("", @row) }
            my $discon = $con->disconnect;
        }
	$url = from_hash($_) if $url eq '';
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub opencart {
    my $output = '';
    $_ = (split('catalog/controller/amazonus', $File::Find::name))[0];
    my $cfg = $_."config.php";
    my $inc = $_."index.php";
    if (-f $cfg and -f $inc and -d $_."catalog") {
	my ($url, $ver) = ('','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    if ($line =~ /^( +)?(\t)?define\( ?['"]HTTP_SERVER/) { $url = define($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    if ($line =~ /^( +)?(\t)?define\( ?['"]VERSION/) { $ver = define($line) }
	}
	close DATA;
	$ver = 'Unknown' if $ver eq '';
	$output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub vtiger {
    my $output = '';
    $_ = (split('pkg/bin/uninstallvtiger.sh', $File::Find::name))[0];
    my $cfg = $_."config.inc.php";
    my $inc = $_."vtigerversion.php";
    if (-f $cfg and -f $inc and -f $_."vtigercron.php") {
	my ($url,$ver) = ('','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$site_URL/) { $url = equals($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$vtiger_current_version/) { $ver = equals($line) }
	}
	close DATA;
	$ver = 'Unknown' if $url eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub moodle {
    my $output = '';
    $_ = (split('lib/moodlelib.php', $File::Find::name))[0];
    my $cfg = $_."config.php";
    my $inc = $_."version.php";
    if (-f $cfg and -f $inc) {
	my ($url,$ver) = ('','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$CFG->wwwroot/) { $url = equals($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$release/) { $ver = equals($line) }
	}
	close DATA;
	$ver = (split(/\+/, $ver))[0] if $ver ne '';
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub phpbb {
    my $output = '';
    $_ = (split('includes/bbcode.php', $File::Find::name))[0];
    my $cfg = $_."config.php";
    my $inc = $_."includes/constants.php";
    if (-f $cfg and -f $inc and -f $_."includes/constants.php") {
	my ($url,$ver,$host,$name,$pass,$user,$pre,$dom,$path) = ['','','','','','','','',''];
	open (DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$dbuser/) { $user = equals($line) }
            if ($line =~ /^( +)?(\t)?\$dbpass/) { $pass = equals($line) }
            if ($line =~ /^( +)?(\t)?\$dbname/) { $name = equals($line) }
            if ($line =~ /^( +)?(\t)?\$dbhost/) { $host = equals($line) }
            if ($line =~ /^( +)?(\t)?\$table_prefix/) { $pre = equals($line) }
	}
	close DATA;
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]?PHPBB_VERSION/) { $ver = define($line) }
	}
	close DATA;
	$ver = 'Unknown' if $ver eq '';
        my $con = DBI->connect("DBI:mysql:$name", $user, $pass, \%attr);
        if ($con) {
            my $qry = $con->prepare("SELECT config_value FROM ".$pre."config WHERE config_name='server_name'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $dom = join("", @row) }
            $qry = $con->prepare("SELECT config_value FROM ".$pre."config WHERE config_name='script_path'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $path = join("", @row) }
            my $discon = $con->disconnect;
	    $url = "http://$dom$path" if $dom ne '';
        }
	$url = from_hash($_) if $url eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub prestashop {
    my $output = '';
    $_ = (split('modules/gamification/prestashop.pub', $File::Find::name))[0];
    my $cfg = $_."config/settings.inc.php";
    if (-f $cfg and -d $_."config" and -d $_."controllers") {
	my ($ver,$url,$host,$name,$user,$pass,$pre) = ('','','','','','','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]_DB_USER_/) { $user = define($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]_DB_PASSWD_/) { $pass = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]_DB_NAME_/) { $name = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]_DB_SERVER_/) { $host = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]_DB_PREFIX_/) { $pre = define($line) }
	}
	close DATA;
        my $con = DBI->connect("DBI:mysql:$name", $user, $pass, \%attr);
        if ($con) {
            my $qry = $con->prepare("SELECT domain,physical_uri FROM ".$pre."shop_url WHERE main=1");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $url = join("", @row) }
	    $url = "http://$url" if $url ne '';
	    $qry = $con->prepare("SELECT value FROM ".$pre."configuration WHERE name='PS_INSTALL_VERSION'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $ver = join("/", @row) }
            my $discon = $con->disconnect;
        }
	$url = from_hash($_) if $url eq '';
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub mambo {
    my $output = '';
    $_ = (split('administrator/templates/mambo_admin', $File::Find::name))[0];
    my $cfg = $_."configuration.php";
    my $inc = $_."includes/version.php";
    if (-f $cfg and -f $inc) {
	my ($ver,$url,$maj,$min) = ('','','','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$mosConfig_live_site/) { $url = equals($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?var \$RELEASE/) { $maj = equals($line) }
	    if ($line =~ /^( +)?(\t)?var \$DEV_LEVEL/) { $min = equals($line) }
	}
	close DATA;
	if ($maj eq '' or $min eq '') {
	    $ver = 'Unknown';
	} else { $ver = "$maj.$min" }
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub zencart {
    my $output = '';
    $_ = (split('docs/0.about_zen_cart.html', $File::Find::name))[0];
    my $cfg = $_."includes/configure.php";
    my $inc = $_."includes/version.php";
    if (-f $cfg and -f $inc) {
	my ($ver,$url,$maj,$min) = ['','','',''];
	$url = from_hash($_);
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]PROJECT_VERSION_MAJOR/) { $maj = define($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]PROJECT_VERSION_MINOR/) { $min = define($line) }
	}
	close DATA;
	if ($maj eq '' or $min eq '') { $ver = 'Unknown' }
	if ($maj ne '' or $min ne '') { $ver = "$maj.$min" }
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub pligg {
    my $output = '';
    $_ = (split('libs/api/Pligg-API-Installation.txt', $File::Find::name))[0];
    my $cfg = $_."libs/dbconnect.php";
    my $inc = $_."settings.php";
    if (-f $cfg and -f $inc and -f $_."libs/karma.php") {
	my ($ver,$url,$host,$pre,$name,$user,$pass,$dom,$path) = ('','','','','','','','','');
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$my_base_url/) { $dom = equals($line) }
	    if ($line =~ /^( +)?(\t)?\$my_pligg_base/) { $path = equals($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]?table_prefix/) { $pre = define($line) }
	}
	close DATA;
	$url = from_hash($_) if $dom eq '';
	$url = "$dom$path" if $dom ne '';
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]?EZSQL_DB_USER/) { $user = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]?EZSQL_DB_PASS/) { $pass = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]?EZSQL_DB_NAME/) { $name = define($line) }
            if ($line =~ /^( +)?(\t)?define\( ?['\"]?EZSQL_DB_HOST/) { $host = define($line) }
	}
	close DATA;
        my $con = DBI->connect("DBI:mysql:$name", $user, $pass, \%attr);
        if ($con) {
            my $qry = $con->prepare("SELECT data FROM ".$pre."misc_data WHERE name='pligg_version'");
            $qry->execute();
            while (my @row = $qry->fetchrow_array) { $ver = join("/", @row) }
            my $discon = $con->disconnect;
        }
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub tomatocart {
    my $output = '';
    $_ = (split('admin/external/devAnalogClock', $File::Find::name))[0];
    my $cfg = $_."includes/configure.php";
    my $inc = $_."includes/application_top.php";
    if (-f $cfg and -f $inc and -d $_."includes/work") {
	my ($url,$ver,$dom,$path) = ('','','','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]HTTP_SERVER/) { $dom = define($line) }
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]HTTP_COOKIE_PATH/) { $path = define($line) }
	}
	close DATA;
	$url = "$dom$path" if $dom ne '';
	$url = from_hash($_) if $dom eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?define\( ?['\"]PROJECT_VERSION/) { $ver = define($line) }
	}
	close DATA;
        $ver = (split('v', $ver))[-1] if $ver ne '';
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }

sub mybb {
    my $output = '';
    $_ = (split('inc/mybb_group.php', $File::Find::name))[0];
    my $cfg = $_."inc/settings.php";
    my $inc = $_."index.php";
    if (-f $cfg and -f $inc and -d $_."inc/datahandlers") {
	my ($url,$ver) = ('','');
	open(DATA, "<$cfg");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\$settings\['bburl'\]/) { $url = equals($line) }
	}
	close DATA;
	$url = from_hash($_) if $url eq '';
	open(DATA, "<$inc");
	while (my $line = <DATA>) {
	    chomp $line;
	    if ($line =~ /^( +)?(\t)?\* MyBB/) { $ver = (split(' ',$line))[2] }
	}
	close DATA;
	$ver = 'Unknown' if $ver eq '';
        $output .= sprintf("    %-75s%-10s%s\n", $_, $ver, $url);
    }
    return $output; }
