package Data::Context;

# Created on: 2012-03-18 16:54:56
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use 5.010;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;


our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;



1;

__END__

=head1 NAME

Data::Context - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Data::Context version 0.1.


=head1 SYNOPSIS

   use Data::Context;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

    /path/to/file.dc.js:
    {
        "PARENT" : "/path/to/default.dc.js:,
        "replace_me" : "#replaced.from.input.variables.0#"
        "structure" : {
            "MODULE": "My::Module",
            "METHOD": "do_stuff",
            ....
        },
        ...
    }

Get object
Build -> parse file
    -> if "PARENT" build parent
    -> mrege self and raw parent
    -> contruct instance
        -> itterate to all values
            -> if the value is a string of the form "#...#" make sub refrence to add to call list
            -> if the value is a HASHREF & "MODULE" or "METHOD" keys exist add to call list
    -> cache result

Use object
    -> clone raw data
    -> call each method call list
        -> if return is a CODEREF assume it's an event handler
        -> else replace data with returned value
   -> if any event handlers are returned run event loop
   -> return data

MODULE HASHES
{
    "MODULE" : "My::Module",
    "METHOD" : "get_data",
    "NEW"    : "new",
    ...
}
or
{
    "METHOD" : "do_something",
    "ORDER"  : 1,
    ....
}

1st : calls My::Module->new->get_data (if NEW wasn't present would just call My::Module->get_data)
2nd : calls Data::Context::Actions->do_something

the parameters passed in both cases are
    $value = the hashref containing the method call
    $dc    = The whole data context raw data
    $path  = A path of how to get to this data
    $vars  = The variables that the  get was called with

Data::Context Configuration
    PATH      string or list of strings containing directory names to be searched config files
    fall_back bool if true if a config isn't found the parent config will be searched for etc
    fall_back_depth
              If set to a non zero value the fall back will limited to this number of times
    actions   hashref of coderefs, allows simple adding of extra methods to Data::Context::Actions
    action_class
              Allows the using of an action class other than Data::Context::Actions. Although it is suggested that the alt class should inhreit from Data::Context::Actions
    file_suffixes HASHREF
             json => '.dc.json' : JSON
             js   => '.dc.js'   : JSON->relaxed
             yaml => '.dc.yml'  : YAML or YAML::XS
             xml  => '.dc.xml'  : XML::Simple
    log      logging object, creates own object that just writes to STDERR if not specified
    debug    set the debugging level default is WARN (DEBUG, INFO, WARN, ERROR or FATAL)
    cache ...

=head1 SUBROUTINES/METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
