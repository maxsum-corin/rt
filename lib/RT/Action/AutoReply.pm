# $Header$

package RT::Action::AutoReply;

require RT::Action::SendEmail;
@ISA = qw(RT::Action::SendEmail);

sub Describe {
  return ("Sends an autoresponse to the requestor and all interested parties.");
}

sub Commit {
  my $self = shift;
  print "AutoReply Commiting\n";
  return($self->SUPER::Commit());
}

sub Prepare {
  my $self = shift;

  print "Preparing\n";
  
  my $id=$self->{TicketObject}->id || die;
  my $subject=$self->{TransactionObject}->Subject || "(no subject)";

  $self->{'Header'}->add('Subject', 
			 "[$RT::rtname \#$id] Autoreply: $subject");

  $self->{'Header'}->add('Precedence', 'bulk');

  return $self->SUPER::Prepare();
}

1;





