use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Module::Selector',
    AUTHOR              => 'Odin Kroeger <okroeger@cpan.org>',
    VERSION_FROM        => 'lib/Module/Selector.pm',
    ABSTRACT_FROM       => 'lib/Module/Selector.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Module-Selector-*' },
);
