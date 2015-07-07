$edir = "/panfs/pan1/dnaorg/programs";

$ctr = 0;
while($line = <>) { 
#NC_003977 Hepatitis-B_r1
  chomp $line;
  ($accn, $name) = split(/\s+/, $line);
  $name_accn = $name . "." . $accn;
  $jobname = $name_accn;
  $errfile = $name_accn . ".err";
  printf("qsub -N $jobname -b y -v SGE_FACILITIES -P unified -S /bin/bash -cwd -V -j n -o /dev/null -e $errfile -m n \"perl $edir/dnaorg_virus_wrapper.pl -d $name_accn $accn.ntlist > $name_accn.virus_wrapper.out\"\n");
  $ctr++;
  if($ctr % 200 == 0) { 
    print("sleep 10\n");
  }
}
