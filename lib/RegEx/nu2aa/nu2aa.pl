#!/usr/bin/env perl

sub nu2aa
{
	my %nu2aa_hash=();
	open input,"<nu2aa.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\n\r]//g;
		if($tmp=~/^([ATCG])([ATCG])([ATCG])	([^\t]+)/)
		{
			my $nl=$1;
			my $n2=$2;
			my $n3=$3;
			my $aa=$4;
			$nu2aa_hash{$nl."\t".$n2."\t".$n3}=$aa;
		}
	}
	close input;
	
	open output,">../nu2aa.mapping.txt";
	print output "aa_w	aa_m	nu_w	nu_m\n";
	foreach my $nu1(keys %nu2aa_hash)
	{
		my $aa1 = $nu2aa_hash{$nu1};
		my @nu1_split=split(/\t/,$nu1);
		foreach my $nu2(keys %nu2aa_hash)
		{
			my $aa2 = $nu2aa_hash{$nu2};
			my @nu2_split=split(/\t/,$nu2);
			if($nu1 ne $nu2)
			{
				if(($nu1_split[0] eq $nu2_split[0]) && ($nu1_split[1] eq $nu2_split[1]) && ($nu1_split[2] ne $nu2_split[2]))
				{
					print $nu1."\t".$nu2."\t".$aa1."\t".$aa2."\n";
					print output $aa1."\t".$aa2."\t".$nu1_split[2]."\t".$nu2_split[2]."\n";
				}
				elsif(($nu1_split[0] eq $nu2_split[0]) && ($nu1_split[1] ne $nu2_split[1]) && ($nu1_split[2] eq $nu2_split[2]))
				{
					print $nu1."\t".$nu2."\t".$aa1."\t".$aa2."\n";
					print output $aa1."\t".$aa2."\t".$nu1_split[1]."\t".$nu2_split[1]."\n";
				}
				elsif(($nu1_split[0] ne $nu2_split[0]) && ($nu1_split[1] eq $nu2_split[1]) && ($nu1_split[2] eq $nu2_split[2]))
				{
					print $nu1."\t".$nu2."\t".$aa1."\t".$aa2."\n";
					print output $aa1."\t".$aa2."\t".$nu1_split[0]."\t".$nu2_split[0]."\n";
				}
			}
		}
	}
	close output;
}
sub main
{
	&nu2aa;
}

main();
