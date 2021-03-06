
use RT;
use RT::Test tests => 15, config => 'Set( %FullTextSearch, Enable => 1 );';


{

use RT::Tickets;
use strict;

my $tix = RT::Tickets->new(RT->SystemUser);
{
    my $query = "Status = 'open'";
    my ($status, $msg)  = $tix->FromSQL($query);
    ok ($status, "correct query") or diag("error: $msg");
}


my (@created,%created);
my $string = 'subject/content SQL test';
{
    my $t = RT::Ticket->new(RT->SystemUser);
    ok( $t->Create(Queue => 'General', Subject => $string), "Ticket Created");
    $created{ $t->Id }++; push @created, $t->Id;
}

{
    my $Message = MIME::Entity->build(
                     Subject     => 'this is my subject',
                     From        => 'jesse@example.com',
                     Data        => [ $string ],
            );

    my $t = RT::Ticket->new(RT->SystemUser);
    ok( $t->Create( Queue => 'General',
                    Subject => 'another ticket',
                    MIMEObj => $Message,
                    MemberOf => $created[0]
                  ),
        "Ticket Created"
    );
    $created{ $t->Id }++; push @created, $t->Id;
}

{
    my $query = ("Subject LIKE '$string' OR Content LIKE '$string'");
    my ($status, $msg) = $tix->FromSQL($query);
    ok ($status, "correct query") or diag("error: $msg");

    my $count = 0;
    while (my $tick = $tix->Next) {
        $count++ if $created{ $tick->id };
    }
    is ($count, scalar @created, "number of returned tickets same as entered");
}

{
    my $query = "id = $created[0] OR MemberOf = $created[0]";
    my ($status, $msg) = $tix->FromSQL($query);
    ok ($status, "correct query") or diag("error: $msg");

    my $count = 0;
    while (my $tick = $tix->Next) {
        $count++ if $created{ $tick->id };
    }
    is ($count, scalar @created, "number of returned tickets same as entered");
}

diag "Make sure we don't barf on invalid input for IS / IS NOT";
{
    my ($status, $msg) = $tix->FromSQL("Subject IS 'foobar'");
    ok ($status, "valid query") or diag("error: $msg");
    is $tix->Count, 0, "found no tickets";
    unlike $tix->BuildSelectQuery, qr/foobar/, "didn't find foobar in the select";
    like $tix->BuildSelectQuery, qr/Subject IS NULL/, "found right clause";
    
    ($status, $msg) = $tix->FromSQL("Subject IS NOT 'foobar'");
    ok ($status, "valid query") or diag("error: $msg");
    is $tix->Count, 2, "found two tickets";
    unlike $tix->BuildSelectQuery, qr/foobar/, "didn't find foobar in the select";
    like $tix->BuildSelectQuery, qr/Subject IS NOT NULL/, "found right clause";
}


}

