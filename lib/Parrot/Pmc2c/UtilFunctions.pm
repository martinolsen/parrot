# Copyright (C) 2007, The Perl Foundation.
# $Id$

package Parrot::Pmc2c::UtilFunctions;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw( count_newlines gen_ret dont_edit dynext_load_code c_code_coda );

=over 4

=item C<count_newlines($string)>

Returns the number of newlines (C<\n>) in C<$string>.

=cut

sub count_newlines {
    return scalar $_[0] =~ tr/\n//;
}

=item C<dont_edit($pmcfile)>

Returns the "DO NOT EDIT THIS FILE" warning text. C<$pmcfile> is the name
of the original source F<*.pmc> file.

=cut

sub dont_edit {
    my ($pmcfilename) = @_;

    return <<"EOC";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$pmcfilename'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

EOC
}

=item C<gen_ret($method, $body)>

Generate the C code for a C<return> statement, if the body is empty then
make a cast if needed.

This method is imported by subclasses.

=cut

sub gen_ret {
    my ( $method, $body ) = @_;

    if ($body) {
        return "$body;" if $method->{type} eq 'void';
        return "return $body;";
    }
    else {
        return '' if $method->{type} eq 'void';
        return "return PMCNULL;" if $method->{type} eq 'PMC*';
        return "return ($method->{type})0;";
    }
}

=item C<dynext_load_code($library_name, %classes)>

C<$library_name> is the name of the dynamic library to be created.

C<%classes> is a map from the PMC names for which code is to be generated,
to dump info (PMC metadata).

This function is exported.

=cut

sub dynext_load_code {
    my ( $classname, %classes ) = @_;
    my $lc_libname = lc $classname;
    my $cout;

    $cout .= <<"EOC";
/*
 * This load function will be called to do global (once) setup
 * whatever is needed to get this extension running
 */

EOC
    $cout .= <<"EOC";

PARROT_DYNEXT_EXPORT extern Parrot_PMC Parrot_lib_${lc_libname}_load(PARROT_INTERP); /* don't warn */
Parrot_PMC Parrot_lib_${lc_libname}_load(PARROT_INTERP)
{
    Parrot_String whoami;
    Parrot_PMC    pmc;
EOC
    while ( my ( $class, $info ) = each %classes ) {
        next if $info->{flags}->{noinit};
        $cout .= <<"EOC";
    Parrot_Int type${class};
EOC
    }
    $cout .= <<"EOC";
    int pass;

    /*
     * create a library PMC
     */
    pmc = pmc_new(interp, enum_class_ParrotLibrary);
    /*
     * TODO stuff some info into this PMCs props
     *
     */

    /*
     * for all PMCs we want to register:
     */
EOC
    while ( my ( $class, $info ) = each %classes ) {
        my $lhs = $info->{flags}->{noinit} ? "" : "type$class = ";
        $cout .= <<"EOC";
    whoami = const_string(interp, "$class");
    ${lhs}pmc_register(interp, whoami);
EOC
    }
    $cout .= <<"EOC";

    /* do class_init code */
    for (pass = 0; pass <= 1; ++pass) {
EOC
    while ( my ( $class, $info ) = each %classes ) {
        next if $info->{flags}->{noinit};
        $cout .= <<"EOC";
        Parrot_${class}_class_init(interp, type$class, pass);
EOC
    }
    $cout .= <<"EOC";
    }
    return pmc;
}

EOC
}

=item C<c_code_coda()>

Returns the Parrot C code coda

=back

=cut

sub c_code_coda() {
    my $self = shift;
    my $cout = "";
    $cout .= <<"EOC";
/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOC
    "$cout\n";
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
