#!perl -T

use 5.8.1;
use strict;
use warnings FATAL => 'all';

use Test::Exception;
use Test::More;

plan tests => 8;

use Bio::Taxonomy::GlobalNames;

# Make sure that empty objects don't cause the script to die.
#
# "The user shall get what they deserve for not reading the
# documentation!"
{
    my $query = Bio::Taxonomy::GlobalNames->new();
    lives_ok { $query->get() } 'Send an empty GET request.';
    lives_ok { $query->post() } 'Send an empty POST request.';
}

# Make sure that empty input files don't cause the script to die.
#
# Likewise.
{
    my $path = q{};

    # Set the path to the test script's directory.
    if ( $0 =~ /data-input[.]t$/ )
    {
        $path = $`;
    }

    my $query =
      Bio::Taxonomy::GlobalNames->new( file => $path . 'empty-input.txt', );

    lives_ok { $query->post() }
    'Send a POST request with data from an empty input file.';
}

# Make sure that input files with Unicode contents are read correctly.
{
    my $path = q{};

    # Set the path to the test script's directory.
    if ( $0 =~ /data-input[.]t$/ )
    {
        $path = $`;
    }

    my $query =
      Bio::Taxonomy::GlobalNames->new( file => $path . 'unicode-input.txt', );

    my $output = $query->post();
    my @data   = @{ $output->data };
    is( $data[0]->supplied_name_string,
        'エラブウミヘビ',
        'Send a POST request with data from a Unicode file.' );
}

# Make sure that objects with input in names, file and data die,
# when trying to perform a GET or POST request.
{
    my $query = Bio::Taxonomy::GlobalNames->new(
        names => 'Daubentonia madagascariensis',
        data  => 'Laticauda semifasciata',
        file  => './input.txt',
    );

    dies_ok { $query->get() }
    'Tried to perform a GET request with input in both names and data.';
    dies_ok { $query->post() }
    'Tried to perform a POST request with input in names, file and data.';
}

# Make sure that the script dies when invalid input is given.
{
    my $query = Bio::Taxonomy::GlobalNames->new( names => 'Mus musculus' );

    dies_ok { $query->resolve_once = 'potato' }
    'Entered "potato" in resolve_once.';
    dies_ok { $query->with_context = 'for pony' }
    'Entered "for pony" in with_context.';
}