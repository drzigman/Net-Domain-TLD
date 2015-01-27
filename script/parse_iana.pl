#!/usr/bin/env perl

use strict;
use warnings;

use Net::Domain::TLD qw( tlds %tld_profile );
use WWW::Mechanize;
use HTML::TableExtract;
use HTML::Entities qw( decode_entities );
use Carp;

use Readonly;

Readonly my $IANA_ROOT_ZONE_DATABASE_URI =>
    'https://www.iana.org/domains/root/db';

my $existing_tlds = tlds();

my $mech = WWW::Mechanize->new();
$mech->get( $IANA_ROOT_ZONE_DATABASE_URI );

my $table_extract = HTML::TableExtract->new(
    headers   => [ 'Domain', 'Type', 'Sponsoring Organisation' ],
    keep_html => 1,
);

$table_extract->parse( $mech->content );
my $table = $table_extract->first_table_found();

if( !$table ) {
    croak "No table was found, unable to parse and extract TLDs!\n";
}

my @new_records;
for my $row ( $table->rows ) {
    $row->[0] =~ m|/root/db/(.*)\.html|;

    my $extracted_tld = $1;
    if(defined $extracted_tld ) {

        if( exists $existing_tlds->{$extracted_tld} ) {
            next;
        }

        my $group;
        if( $extracted_tld =~ m/xn--.*/ ) {
            $group = 'ccidn';
        }
        else {
            $group = 'gtld_new';
        }

        push @new_records, {
            tld            => $extracted_tld,
            group          => $group,
            sponsoring_org => decode_entities( $row->[2] ),
        };
    }
    else {
        croak "Fatal Error Parsing TLD From " . $row->[0] . "\n";
    }
}

for my $new_record ( @new_records ) {
    printf( "New Record: %s - %s - %s\n", $new_record->{group},
        $new_record->{tld}, $new_record->{sponsoring_org} );

    $tld_profile{ $new_record->{group} }->{ $new_record->{tld} } =
        $new_record->{sponsoring_org};
}

print "(\n";
for my $group ( sort keys %tld_profile ) {
    print "  $group => {\n";

    for my $tld ( sort keys $tld_profile{$group} ) {
        print "    '$tld' => q{" . $tld_profile{$group}{$tld} . "},\n";
    }

    print "  },\n";
}

print ");\n";
