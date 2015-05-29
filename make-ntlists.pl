use strict;
use warnings;

my $usage = "perl make-ntlists.pl <.nbr file from ncbi viral genomes>";
if(scalar(@ARGV) != 1) { die $usage; }

my ($nbr_file) = (@ARGV);

open(IN, $nbr_file) || die "ERROR unable to open $nbr_file for reading";

my %ntlist_HA = ();
my @rep_accn_A = ();

my $line_ctr = 0;
while(my $line = <IN>) { 
  $line_ctr++;
  ### Columns:	"Representative"	"Neighbor"	"Host"	"Selected lineage"	"Taxonomy name"	"Segment name"
  #NC_003663	KC813499	vertebrates	Poxviridae,Orthopoxvirus,Cowpox virus	Cowpox virus	segment  
  if($line !~ m/^\#/) { 
    my ($accn, $neighbor, $host, $selected_lineage, $taxonomy_name, $segment_name) = split(/\t/, $line);

    # deal with special representative case of multiple representative accessions:
    my @accn_A = split(",", $accn);
    my $rep_accn = $accn_A[0];
    if($rep_accn !~ m/^N\w\_/) { die "ERROR round non-NC_ prefixed rep accession line: $line_ctr\n"; }
    if(scalar(@accn_A) > 1) { 
      # only want to add the secondary representative accessions once
      if(! exists $ntlist_HA{$rep_accn}) { 
        @{$ntlist_HA{$rep_accn}} = ();
        push(@rep_accn_A, $rep_accn);
        for(my $i = 1; $i < scalar(@accn_A); $i++) { 
          push(@{$ntlist_HA{$rep_accn}}, $accn_A[$i]);
        }
      }
    }

    if(! exists $ntlist_HA{$rep_accn}) { 
      @{$ntlist_HA{$rep_accn}} = ();
      push(@rep_accn_A, $rep_accn);
    }
    push(@{$ntlist_HA{$rep_accn}}, $neighbor); 
  }
}

foreach my $rep_accn (@rep_accn_A) { 
  my $ntlist_file = $rep_accn . ".ntlist";
  open(OUT, ">" . $ntlist_file) || die "ERROR unable to open $ntlist_file for writing"; 
  print OUT $rep_accn . "\n";
  foreach my $accn (@{$ntlist_HA{$rep_accn}}) { 
    print OUT $accn . "\n";
  }
  close(OUT);
}

