#!/usr/bin/perl
#
# @File nparser.pl
# @Author Fredrik Karlsson aka DreamHealer & avade.net
# @Created May 17, 2019 11:04:06 PM
#

use strict;
use warnings;
use Data::Dumper;
use Switch;
use Irssi;
require 'npclass/npdata.pl';

my $setting = new NPData (
    authors     => 'DreamHealer',
    contact     => 'dreamhealer@avade.net',
    name        => 'nparser',
    version     => '0.01',
    description => 'This script will parse notices and snotices into their own windows',
    license     => 'Public Domain',    
);

my $server = Irssi::active_server()->{'tag'};

Irssi::theme_register ( ['nparser_loaded', '%R>>%n %_Scriptinfo:%_ Loaded $0 version $1 by $2.' ] );
Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'nparser_loaded', $setting->{name}, $setting->{version}, $setting->{authors});

# NOTICE WIN ( Default )
my $noticeWin = new NPData (
    name    => "Notice",
    window  => 0,
);
# NOTICE WINDOW. FIND OR CREATE
my $notice = getWindow ( $noticeWin );
if ( defined $notice ) {
    $noticeWin->{type} = $notice;
} else {
    createWindow ( $server, $noticeWin->{name}, 2 );
}
$noticeWin->{window} = Irssi::window_find_name ( $noticeWin->{name} );

# SNOTICE WINDOW
my $snoticeWin = new Data (
    name    => "SNotice",
    window  => 0,
);
# SNOTICE WINDOW. FIND OR CREATE
my $snotice = getWindow ( $snoticeWin );
if ( defined $snotice ) {
    $snoticeWin->{type} = $snotice;
} else {
    createWindow ( $server, $snoticeWin->{name}, 3 );
}
$snoticeWin->{window} = Irssi::window_find_name ( $snoticeWin->{name} );



###################
### SUBROUTINES ###
###################

# FILTER NOTICE
sub filterIncomingNotice {
    my ( $serv, $data, $from, $addr ) = @_; 
    my ( $target, $text ) = split / :/, $data, 2;

    # SNOTICE
    if ( defined $from && $from =~ m/\./ || ! defined $addr ) {
        winPrint ( $snoticeWin, "%K".$from."%n: %W".$text );
        Irssi::signal_stop ( );

    # CHANNEL NOTICE
    } elsif ( defined $target && $target =~ m/#/ ) {
        winPrint ( $noticeWin, "%K[%M".$target."%n%K]%n: %G".$from."%n%K!".$addr."%n: %W".$text );

    # NOTICE
    } else {
        winPrint ( $noticeWin, "%G".$from."%n%K!".$addr."%n: %W".$text );
        Irssi::signal_stop ( );
    }
}


# Print to window
sub winPrint {
    my ( $win, $text ) = @_;
    $win->{window}->print ( $text, MSGLEVEL_CLIENTCRAP );
}

# Print incoming server notice to window
sub winPrintSNotice {
    my ( $win, $text ) = @_;
    $win->{window}->print ( $text, MSGLEVEL_SNOTES );
}


# Return the action array position based of existing window
sub getWindow {
    my ( $win ) = @_;
    if ( my $window = Irssi::window_find_name ( $win->{name} ) ) {
        return $window;
    }
    return;
}


# Create new window
sub createWindow {
    my ( $server, $name, $position ) = @_;
    Irssi::command ( "window new hidden" );
    Irssi::command ( "window name ".$name );
    Irssi::command ( "window server ".$server );
    Irssi::command ( "window move ".$position );
}

##################
### Signal Add ###
##################
Irssi::signal_add ( "event notice", "filterIncomingNotice" );
