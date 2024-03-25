#!perl

use HTML::Entities;
use LWP;
my $browser = LWP::UserAgent->new;

BEGIN {
    $| = 1;
    $ENV{'LANG'} = 'C';
}

sub GeneVariantMention
{
	my $input=$_[0];
	my $output=$_[1];
	
	my $pmid="";
	my $gene="";
	my $var="";
	my %GeneVariantMention=();
	open input,"<$input";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\n\r]//g;
		if($tmp=~/^([0-9]+)\|t\|A Gene ([^ ]+) with a variant ([^ ]+)./)
		{
			$pmid=$1;
			$gene=$2;
			$var=$3;
		}
		elsif($tmp=~/([0-9]+)	[0-9]+	[0-9]+	[^\t]+	[^\t]+	([^\t]+);(RS#:([0-9]+))/)
		{
			$pmid=$1;
			my $tmVarform=$2;
			my $rs=$3;
			my $rsid=$4;
			my $utils = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=snp&id=".$rsid;
			my $response = $browser->get($utils) || print "die";
			my $utils_result = $response->content ;
			$utils_result =~s/[\n\r]//g;
			if($utils_result=~/<GENE_ID>([0-9]+)<\/GENE_ID>/)
			{
				$geneid=$1;
				$GeneVariantMention{$gene.$var}=$tmVarform.";CorrespondingGene:".$geneid.";".$rs;
			}
			sleep(1);
		}
	}
	close input;
	
	open output,">$output";
	foreach my $gv(keys %GeneVariantMention)
	{
		print output "ProteinMutation\t".$GeneVariantMention{$gv}."\t".$gv."\n";
	}
	open input,"<GeneVariantMention.add.txt";
	while(<input>)
	{
		my $tmp=$_;
		$tmp=~s/[\n\r]//g;
		if($tmp=~/^(.+);(RS#:([0-9]+))	([\t]+)/)
		{
			my $pre=$1;
			my $rs=$2;
			my $rsid=$3;
			my $post=$4;
			my $utils = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=snp&retmode=xml&id=".$rsid;
			my $response = $browser->get($utils) || print "die";
			my $utils_result = $response->content ;
			$utils_result =~s/[\n\r]//g;
			if($utils_result=/<GENE_ID>([0-9]+)<\/GENE_ID>/)
			{
				$geneid=$1;
				$GeneVariantMention{$gene.$var}=$tmVarform.";CorrespondingGene:".$geneid.";".$rs;
			}
			sleep(1);
		}
	
	}
	close input;
	close output;
}

sub main
{
	my $input=$ARGV[0];
	my $output=$ARGV[1];
	$input="GetString.tiabs.PubTator";
	$output="GeneVariantMention.txt";
	&GeneVariantMention($input,$output);

}
main();
