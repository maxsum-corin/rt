# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2007 Best Practical Solutions, LLC
#                                          <jesse@bestpractical.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/copyleft/gpl.html.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# END BPS TAGGED BLOCK }}}
# This Action will resolve all members of a resolved group ticket

package RT::ScripAction::ResolveMembers;
require RT::Model::LinkCollection;

use strict;
use base 'RT::ScripAction';

#Do what we need to do and send it out.

#What does this type of Action does

sub describe {
    my $self = shift;
    return _( "%1 will resolve all members of a resolved group ticket.", ref $self );
}


sub prepare {

    # nothing to prepare
    return 1;
}


sub commit {
    my $self = shift;

    my $Links = RT::Model::LinkCollection->new( current_user => RT->system_user );
    $Links->limit( column => 'type',   value => 'MemberOf' );
    $Links->limit( column => 'target', value => $self->ticket_obj->id );

    while ( my $Link = $Links->next() ) {

        # Todo: Try to deal with remote URIs as well
        next unless $Link->base_uri->is_local;
        my $base = RT::Model::Ticket->new( $self->ticket_obj->current_user );

        # Todo: Only work if base is a plain ticket num:
        $base->load( $Link->base );

        # I'm afraid this might be a major bottleneck if ResolveGroupTicket is on.
        $base->resolve;
    }
}

# Applicability checked in Commit.

sub is_applicable {
    my $self = shift;
    1;
    return 1;
}

1;
