use ExtUtils::MakeMaker;

# Write the makefile
WriteMakefile(
    'NAME'      => 'Number::Interval',
    'VERSION_FROM' => 'Interval.pm', # finds $VERSION

    'PREREQ_PM' => {
	 Test::More => 0,
       },
    'dist'      => { COMPRESS => "gzip -9f" },
  ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
        (ABSTRACT_FROM => 'Interval.pm',
         AUTHOR     => 'Tim Jenness <tjenness@cpan.org>') : ()),
);
