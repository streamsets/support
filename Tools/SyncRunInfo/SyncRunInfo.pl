#!/usr/bin/perl -w
use strict;
use warnings;
use integer;

## this should only be run from the $SDC_DATA directory. 

# are we in the parent or pipelines and runInfo? 
my $ROOT = ".";
opendir(my $MH, $ROOT) or die "can't open pwd";

my $hasRunInfo = 0;
my $hasPipelines = 0;
while (my $record = readdir $MH) {
    if($record eq "runInfo") { 
        $hasRunInfo = 1;
    } elsif($record eq "pipelines") {
        $hasPipelines = 1;
    } 
}

if($hasRunInfo && $hasPipelines) { 
} else {
    print "we may not be in the correct directory (0 means the directory is missing)" . "\n";
    print "runInfo: " . $hasRunInfo . "\n";
    print "pipelines: " . $hasPipelines . "\n";
    exit;
} 

close $MH;

# read all directories from the pipelines directory
my %pipelines;
opendir(my $PD, $ROOT . "/pipelines") or die "Cannot open $ROOT/pipelines";
while(my $record = readdir $PD) { 
    if($record eq "." || $record eq "..") { 
        next;
    }
    print "keep pipeline: " . $record . "\n";
   $pipelines{$record} = "yes";
}
close $PD;

# read all directories from the runInfo directory
my %runInfo;
opendir(my $RD, $ROOT . "/runInfo") or die "Cannot open $ROOT/runInfo";
while(my $record = readdir $RD) { 
    if($record eq "." || $record eq "..") { 
        next;
    }
   $runInfo{$record} = "yes";
}
close $RD;

# check if each pipleine is in runInfo, if so delete it from runInfo hash.
# later we're going to delete the pipelines which are in runInfo hash. 
for my $pipelineName (keys %pipelines) { 
    if(exists $runInfo{$pipelineName}) { 
        delete($runInfo{$pipelineName});
    }
}    

# here we have the runinfo list which *dont* have pipleine directories. 
for my $runInfoToDelete (keys %runInfo) {
    print "WANT TO rm -rf ./runInfo/" . $runInfoToDelete . "\n";
### uncomment the next line to permit the deletes to happen. 
#  and notice there is even an additional comment on the rm command.  
###    system("#rm -rf ./runInfo/" . $runInfoToDelete);
}
