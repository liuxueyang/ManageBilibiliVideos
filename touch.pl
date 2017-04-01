#!/usr/bin/perl

# Date  : 2017/03/16 19:14:35
# Finish: 2017/03/16 22:04:07

# Update: 2017/04/01 23:14:19
# file extension could be .blv

# NOTE: There MUST NOT be any non-ascii character in the path!!!!!!!!!!

use strict;
use warnings;
use 5.014;
use Cwd;
use JSON qw();
use open ':std', ':encoding(UTF-8)';
use File::Copy;

my $cur_dir = $ARGV[0] or die "Usage: perl ./touch.pl DIRECTORYPATH";
$cur_dir .= '/' unless ($cur_dir =~ '/$');

# my $cur_dir = '/home/repl/Videos/Bilibili/Fanju/TOUCH/s_2425';
# my $cur_dir = '/home/repl/Videos/MV/5028728/';

opendir(DIR, $cur_dir) or dir $!;

while (my $file = readdir(DIR)) {
    next if ($file =~ /^\./);

    # get index_title
    my $json_file = $cur_dir . "/$file" . '/entry.json';

    my $json_text = do {
	open(my $json_fh, "<:encoding(UTF-8)", $json_file)
	    or die("Can not open $json_file\"$!\n\"");
	local $/;
	<$json_fh>
    };

    my $json = JSON->new;
    my $data = $json->decode($json_text);

    # REMEMBER TO CHANGE THIS!
    # get title from json file

    # music set
    # my $index = $data->{'page_data'}->{'part'};

    # bonobono
    my $index = $data->{'ep'}{'index'} . $data->{'ep'}{'index_title'};

    # touch
    # my $index = $data->{'title'};

    # directories like 58116
    my $subdir = "$cur_dir/$file";
    opendir(SUBDIR, $subdir) or dir $!;

    while (my $subfile = readdir(SUBDIR)) {
	next if ($subfile =~ /^\./);
	if (-d "$subdir/$subfile") {
	    # What if there are multiple mp4 files? Is that possible?
	    # I assume it will not happen. :P Maybe there should only be
	    # multiple flv files. :)
	    if ($subfile =~ /mp4/) {
		# only needs to rename
		opendir(DSTDIR, "$subdir/$subfile");
		while (my $dstfile = readdir(DSTDIR)) {
		    next if ($dstfile =~ /^\./);
		    if ($dstfile =~ /mp4$/) {
			$index =~ s/ /_/g;
			rename("$subdir/$subfile/$dstfile", "$index.mp4") or die
			    "failed to copy file" . $index;
		    }
		}
		closedir(DSTDIR);
	    }
	    if ($subfile =~ /[bf]lv/) {
		# concat flv files
		opendir(DSTDIR, "$subdir/$subfile");
		my @flv = ();

		while (my $dstfile = readdir(DSTDIR)) {
		    next if ($dstfile =~ /^\./);
		    if ($dstfile =~ /[bf]lv$/) {
			push @flv, $dstfile;
		    }
		}

		# if there are more than 1 flv videos: merge and rename
		if (@flv > 1) {
		    @flv = sort { $a cmp $b } @flv;
		    @flv = map { "file './$_'" } @flv;
		    my $mylist = "$subdir/$subfile/mylist.txt";
		    open (my $fh, ">", $mylist)
			or dir $!;

		    for (@flv) { print $fh "$_\n"; }
		    close($fh);
		    say "$subdir/$subfile";
		    # output file is: output.flv. Chinese filename will crash. T_T
		    system("cd $subdir/$subfile && ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.flv");
		    # rename the filename of the output.flv to Chinese filename.
		    $index =~ s/ /_/g;
		    rename("$subdir/$subfile/output.flv", "$index.flv") or die
			"failed to copy file" . $index;
		}
		else {
		    $index =~ s/ /_/g;
		    rename("$subdir/$subfile/$flv[0]", "$index.flv") or die
			"failed to copy file" . $index;
		}
		closedir(DSTDIR);
	    }
	}
    }
    close(SUBDIR);
}

closedir(DIR);
exit 0;
