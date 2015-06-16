#!/usr/bin/env perl
# EPN, Thu May 28 14:26:07 2015
#
use strict;
use warnings;
use Getopt::Long;
use Time::HiRes qw(gettimeofday);

# hard-coded-paths:
my $exec_dir = "/panfs/pan1/dnaorg/programs/";
my $fetch_wrapper   = $exec_dir . "dnaorg_fetch_dna_wrapper.pl";
my $parse_ftable    = $exec_dir . "dnaorg_parse_ftable.pl";
my $compare_genomes = $exec_dir . "dnaorg_compare_genomes.pl";

my $usage  = "\ndnaorg_virus_wrapper.pl\n";
$usage .= "\t<list of accessions with representative genome first (must end in .ntlist)>\n";
$usage .= "\n";
$usage .= " OPTIONS:\n";
$usage .= " -d <s> : create directory called <s> instead of auto-determined dir name\n";
$usage .= "\n";

my $outdir = undef;
&GetOptions( "d=s" => \$outdir);

if(scalar(@ARGV) != 1) { die $usage; }
my ($listfile) = (@ARGV);

if($listfile !~ m/\.ntlist$/) { die "ERROR $listfile does not end in .ntlist"; }
my $accn = $listfile;
$accn =~ s/\.ntlist$//;

if(! defined $outdir) { $outdir = $accn; }
$outdir =~ s/\/$//; # remove final char if it's a '/'
my $outdirroot = $outdir;
$outdirroot =~ s/^.+\///;

my $cmd;

if(! -s $listfile) { die "ERROR $listfile does not exist or is empty"; }

# Step 1: create feature table with dnaorg_fetch_dna_wrapper.pl:
printf("Step 1: creating feature table ... ");
$cmd = "perl $fetch_wrapper -f -ntlist -ftable -d $outdir $listfile > /dev/null";
runCommand($cmd, 0);
printf("done. [$cmd]\n");

# Step 2: parse feature table into CDS and other tables with dnaorg_parse_ftable.pl:
printf("Step 2: parsing feature table ... ");
$cmd = "perl $parse_ftable -d $outdirroot $outdir/$outdirroot.ftable $outdirroot > /dev/null"; 
runCommand($cmd, 0);
printf("done. [$cmd]\n");

# Step 3: compare genomes 
printf("Step 3: comparing genomes ... ");
$cmd = "perl $compare_genomes -s -product $outdir $outdir/$accn.ntlist.not_suppressed > $outdir/$outdirroot.compare"; 
runCommand($cmd, 0);
printf("done. [$cmd]\n");

# Output $accn.compare file 
$cmd = "cat $outdir/$outdirroot.compare";
runCommand($cmd, 0);

#############
# SUBROUTINES
#############
# Subroutine: runCommand()
# Args:       $cmd:            command to run, with a "system" command;
#             $be_verbose:     '1' to output command to stdout before we run it, '0' not to
#
# Returns:    amount of time the command took, in seconds
# Dies:       if $cmd fails

sub runCommand {
  my $sub_name = "runCommand()";
  my $nargs_exp = 2;

  my ($cmd, $be_verbose) = @_;

  if($be_verbose) { 
    print ("Running cmd: $cmd\n"); 
  }

  my ($seconds, $microseconds) = gettimeofday();
  my $start_time = ($seconds + ($microseconds / 1000000.));
  system($cmd);
  ($seconds, $microseconds) = gettimeofday();
  my $stop_time = ($seconds + ($microseconds / 1000000.));

  if($? != 0) { die "ERROR command failed:\n$cmd\n"; }

  return ($stop_time - $start_time);
}
