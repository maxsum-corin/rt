
use strict;
use warnings;
use RT::Test; use Test::More; 
plan tests => 5;
use RT;



{


use RT::Model::Link;
my $link = RT::Model::Link->new(current_user => RT->system_user);


ok (ref $link);
ok (UNIVERSAL::isa($link, 'RT::Model::Link'));
ok (UNIVERSAL::isa($link, 'RT::Base'));
ok (UNIVERSAL::isa($link, 'RT::Record'));
ok (UNIVERSAL::isa($link, 'Jifty::DBI::Record'));


}

1;
