#!/usr/bin/env perl

sub ExchangeMFsub
{
	my $input=$_[0];
	my $output=$_[1];
	
	my %MFsub_len_hash=();
	my %MFsub_hash=();
	open input,"<MFsub.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		if($tmp=~/^([^\t]+)	([^\t]+)$/)
		{
			$MFsub_hash{$1}=$2;
			$MFsub_len_hash{$1}=length($1);
		}
	}
	close input;
	
	my @sorted_MF=reverse sort {$MFsub_len_hash{$a} <=> $MFsub_len_hash{$b}} keys %MFsub_len_hash;
	
	open output,">$output";
	open input,"<$input";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		foreach $sub(@sorted_MF)
		{
			$tmp=~s/$sub/$MFsub_hash{$sub}/g;
		}
		print output $tmp."\n";
	}
	close input;
	close output;
}
sub main
{
	my $input=$ARGV[0];
	my $output=$ARGV[1];
	if($input eq "" || $output eq "")
	{
		print "perl 1.ExchangeMFsub.pl [input]:MF.RegEx.2.beforesub.sorted.txt [output]:MF.RegEx.2.txt\n";
		$input = "MF.RegEx.2.beforesub.sorted.txt";
		$output = "MF.RegEx.2.txt";
		&ExchangeMFsub($input,$output);
	}
	else
	{
		&ExchangeMFsub($input,$output);
	}
}

main();
