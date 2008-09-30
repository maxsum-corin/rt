# BEGIN BPS TAGGED BLOCK {{{
# 
# COPYRIGHT:
# 
# This software is Copyright (c) 1996-2008 Best Practical Solutions, LLC
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
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
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

package RT::ObjectCustomFieldValues;

use strict;
no warnings qw(redefine);

# {{{ sub LimitToCustomField

=head2 LimitToCustomField FIELD

Limits the returned set to values for the custom field with Id FIELD

=cut
  
sub LimitToCustomField {
    my $self = shift;
    my $cf = shift;
    return $self->Limit(
        FIELD => 'CustomField',
        VALUE => $cf,
    );
}

# }}}

# {{{ sub LimitToObject

=head2 LimitToObject OBJECT

Limits the returned set to values for the given OBJECT

=cut

sub LimitToObject {
    my $self = shift;
    my $object = shift;
    $self->Limit(
        FIELD => 'ObjectType',
        VALUE => ref($object),
    );
    return $self->Limit(
        FIELD => 'ObjectId',
        VALUE => $object->Id,
    );

}

# }}}

=head2 HasEntry VALUE

If this collection has an entry with content that eq VALUE then
returns the entry, otherwise returns undef.

=cut


sub HasEntry {
    my $self = shift;
    my $value = shift;
    return undef unless defined $value && length $value;

    #TODO: this could cache and optimize a fair bit.
    foreach my $item ( @{$self->ItemsArrayRef} ) {
        return $item if lc $item->Content eq lc $value;
    }
    return undef;
}

sub _DoSearch {
    my $self = shift;
    
    # unless we really want to find disabled rows,
    # make sure we\'re only finding enabled ones.
    unless ( $self->{'find_expired_rows'} ) {
        $self->LimitToEnabled();
    }
    
    return $self->SUPER::_DoSearch(@_);
}

sub _DoCount {
    my $self = shift;
    
    # unless we really want to find disabled rows,
    # make sure we\'re only finding enabled ones.
    unless ( $self->{'find_expired_rows'} ) {
        $self->LimitToEnabled();
    }
    
    return $self->SUPER::_DoCount(@_);
}

1;
