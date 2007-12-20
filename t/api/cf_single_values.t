#!/usr/bin/perl
use warnings;
use strict;
use RT::Test; use Test::More tests => 8;

use RT;




my $q = RT::Model::Queue->new(current_user => RT->system_user);
my ($id,$msg) =$q->create(name => "CF-Single-".$$);
ok($id,$msg);

my $cf = RT::Model::CustomField->new(current_user => RT->system_user);
($id,$msg) = $cf->create(name => 'Single-'.$$, Type => 'Select', MaxValues => '1', Queue => $q->id);
ok($id,$msg);


($id,$msg) =$cf->AddValue(name => 'First');
ok($id,$msg);

($id,$msg) =$cf->AddValue(name => 'Second');
ok($id,$msg);


my $t = RT::Model::Ticket->new(current_user => RT->system_user);
($id,undef,$msg) = $t->create(Queue => $q->id,
          Subject => 'CF Test');

ok($id,$msg);
is($t->CustomFieldValues($cf->id)->count, 0, "No values yet");
$t->AddCustomFieldValue(Field => $cf->id, value => 'First');
is($t->CustomFieldValues($cf->id)->count, 1, "One now");

$t->AddCustomFieldValue(Field => $cf->id, value => 'Second');
is($t->CustomFieldValues($cf->id)->count, 1, "Still one");

1;
