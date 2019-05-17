#!/usr/bin/perl
#
# @File npdata.pl
# @Author Fredrik Karlsson aka DreamHealer & avade.net
# @Created May 17, 2019 11:05:56 PM
#

use strict;
package NPData;
use warnings;

sub new {
    my $class = shift;
    my $self = { @_ };
    bless ( $self );
    return $self;
}

1;
