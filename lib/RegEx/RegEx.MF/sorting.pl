#!/usr/bin/env perl

sub sorting
{
	my $input=$_[0];
	my $output=$_[1];
	
	my %tmp_hash=();
	open input,"<$input";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		if($tmp=~/^(.+)\t(.+)/)
		{
			my $Reg=$1;
			my $type=$2;
			if($type eq "DNAMutation")
			{
				$tmp_hash{$tmp}=length($tmp)+100000;
			}
			else
			{
				$tmp_hash{$tmp}=length($tmp)+90000;
			}
		}
		
	}
	close input;

	open input,"<MF.RegEx.2.beforesub.add.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		if($tmp=~/^(.+)\t(.+)/)
		{
			my $Reg=$1;
			my $type=$2;
			if($type eq "DNAMutation")
			{
				$tmp_hash{$tmp}=length($tmp)+100000;
			}
			else
			{
				$tmp_hash{$tmp}=length($tmp)+90000;
			}
		}
		
	}
	close input;
	
	open input,"<Allele.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		if($tmp=~/^(.+)\t(.+)/)
		{
			my $Reg=$1;
			my $type=$2;
			if($type eq "DNAAllele")
			{
				$tmp_hash{$tmp}=length($tmp)+80000;
			}
			else
			{
				$tmp_hash{$tmp}=length($tmp)+70000;
			}
		}
		
	}
	close input;
	
	open input,"<AcidChange.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\r\n]//g;
		if($tmp=~/^(.+)\t(.+)/)
		{
			my $Reg=$1;
			my $type=$2;
			if($type eq "DNAAcidChange")
			{
				$tmp_hash{$tmp}=length($tmp)+60000;
			}
			else
			{
				$tmp_hash{$tmp}=length($tmp)+50000;
			}
		}
		
	}
	close input;

	open output,">$output";
	my @rank = reverse sort {$tmp_hash{$a} <=> $tmp_hash{$b}} keys %tmp_hash;
	foreach my $tmp(@rank)
	{
		print output $tmp."\n";
	}
	close output;
}
sub main
{
	my $input=$ARGV[0];
	my $output=$ARGV[1];
	if($input eq "" || $output eq "")
	{
		print "perl 1.sorting.pl [input]:MF.RegEx.2.beforesub.txt [output]:MF.RegEx.2.beforesub.sorted.txt\n";
		$input = "MF.RegEx.2.beforesub.txt";
		$output = "MF.RegEx.2.beforesub.sorted.txt";
		&sorting($input,$output);
	}
	else
	{
		&sorting($input,$output);
	}
}

main();
