#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell
BEGIN{foreach (@INC) {s/\/usr\/local\/packages/\/local\/platform/}};
use lib (@INC,$ENV{"PERL_MOD_DIR"});
no lib "$ENV{PERL_MOD_DIR}/i686-linux";
no lib ".";

=head1 NAME

create_mothur_unique_seqs_iterator_list.pl - Default output is a workflow iterator that can be used to iterator over input for screen.seqs

=head1 SYNOPSIS

USAGE: ./create_mothur_unique_seqs_iterator_list.pl --sequence_file=/path/to/mothur/align/seqs/output --sequence_file_list=/path/to/mothur/align/seqs/output 
                                                    --names_file_list=/path/to/name/files/list --output=/path/to/output/iterator
                                               
=head1 OPTIONS

B<--sequence_file, -i>
    A single sequence file in FASTA format

B<--sequence_file_list, -s>
    A list of sequence files in FASTA format

B<--names_file_list, -n>
    A list of mothur unique.seqs generated name files.
       
B<--output, -o>
    Desired path to output iterator file
    
B<--log, -l>
    Optional. Log file.
    
B<--debug, -d>
    Optional. Debug level.
    
B<--help>
    Print perldocs for this script.
    
=head1 DESCRIPTION

Creates an ergatis/workflow iterator list file for a distributed mothur unique.seqs job. The iterator contains all the parameters needed to run 
unique.seqs successfully, attempting to pair up groups of files (sequence file - name file) based of the base filename prefix
(e.x. AMP01_LUNG.trim.fsa - AMP01_LUNG.trim.names would be grouped together as they all carry the AMP01_LUNG prefix).

=head1 INPUT

The only mandatory input file is FASTA formatted sequence file. Optionanlly a names file generated by trim.seqs can also be included.
                    
=head1 OUTPUT

An ergatis iterator list.

=head1 CONTACT

    Cesar Arze
    carze@som.umaryland.edu
    
=cut

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;
use File::Basename;
use Ergatis::Logger;
umask(0000);
my $logger;

my %options = &parse_options();
my $sequence_file = $options{'sequence_file'};
my $sequence_list = $options{'sequence_file_list'};
my $names_list = $options{'names_file_list'};
my $output = $options{'output'};

# Parse input...
my @sequence_files = parse_sequence_files($sequence_file, $sequence_list);
my $name_files = parse_list_file($names_list) if defined ($options{'names_file_list'});

open (OUTFILE, "> $output") or $logger->logdie("Could not open output iterator $output for writing: $!");
print OUTFILE '$;I_FILE_BASE$;' . "\t" .
              '$;I_FILE_NAME$;' . "\t" .
              '$;I_FILE_PATH$;' . "\t" .
              '$;NAME_FILE$;' . "\n";
                            
# Iterate over all sequence files and if a corresponding name file exists print it out
# to the iterator list as well.                            
foreach my $sequence (@sequence_files) {
    my $filename = basename($sequence);
    my $file_base = fileparse($sequence, '\.(.*)');
    my $name = $name_files->{$file_base};
    
    print OUTFILE "$file_base\t$filename\t$sequence\t$name\n";    
}              

close OUTFILE;
              
#########################################################################
#                                                                       #
#                           SUBROUTINES                                 #
#                                                                       #
#########################################################################

## Parses a list file, creating a hash containing file prefix as key and 
## absolute filename as value.
sub parse_list_file {
    my $file = shift;
    my $files = ();
    
    open (FILELIST, $file) or $logger->logdie("Could not open list $file: $!");
    while (my $line = <FILELIST>) {
        chomp ($line);
        my $file_prefix = fileparse($line, '\.(.*)');
        
        if ( &verify_file($line) && !( exists($files->{$file_prefix}) ) ) {
            $files->{$file_prefix} = $line;
        } else {
            $logger->logwarn("Duplicate file prefix found for file $line");
        }
    }
    
    close (FILELIST);   
    return $files;
}
                 
# Parses list of sequence files returning an array containing absolute
# paths to each sequence file.                 
sub parse_sequence_files {
    my ($sequence_file, $sequence_list) = @_;
    my @files;
    
    ## Handle a single sequence file being passed in...
    push (@files, $sequence_file) if ( defined($sequence_file) && &verify_file($sequence_file) );
    if ( &verify_file($sequence_list) ) {
        open (SEQLIST, $sequence_list) or $logger->logdie("Could not open sequence file list $sequence_list: $!");
        
        while (my $line = <SEQLIST>) {
            chomp ($line);
            push (@files, $line) if ( &verify_file($line) );
        }
        
        close (SEQLIST);
    }
    
    $logger->logdie("No sequence files found in input provided.") if (scalar @files == 0);
    return @files;
}                 

# Verifies that a file exists, is readable and is not zero-content.
sub verify_file {
    my @files = @_;
    
    foreach my $file (@files) {
        next if ( (-e $file) && (-r $file) && (-s $file) );
        
        if      (!-e $file) { $logger->logdie("File $file does not exist")   }
        elsif   (!-r $file) { $logger->logdie("File $file is not readable")  }
        elsif   (!-s $file) { $logger->logdie("File $file has zero content") }
    }
    
    return 1;
}
                    
sub parse_options {
    my %opts = ();
    
    GetOptions(\%opts,
                'sequence_file|i=s',
                'sequence_file_list|a=s',
                'names_file_list|n=s',
                'output|o=s',
                'log|l=s',
                'debug|d=s',
                'help') || pod2usage();
       
    if ($opts{'help'}) {
        pod2usage ( { -exitval => 0, -verbose => 2, -output => \*STDERR } );
    }
    
    ## Initialize and configure logging...
    my $logfile = $opts{'log'} || Ergatis::Logger::get_default_filename();
    my $debug = $opts{'debug'} ||= 4;
    $logger = new Ergatis::Logger( 'LOG_FILE'   =>  $logfile,
                                   'LOG_LEVEL'  =>  $debug );
    $logger = Ergatis::Logger::get_logger();
   
    ## Check to make sure certain parameters are defined...
    defined ($opts{'output'}) || $logger->logdie("Please specify an output iterator file.");
                       
    return %opts;                
}                                                                                        
