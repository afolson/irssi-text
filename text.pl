#!/usr/bin/perl
use warnings;
use strict;
use Irssi;
use Email::Send qw/Sendmail/;
$Email::Send::Sendmail::SENDMAIL = "/usr/lib/sendmail";

my %IRSSI = (
	version		=> '0.1',
	author		=> 'Amanda Folson',
	contact		=> 'amanda@incredibl.org',
	name		=> 'irssi-text',
	uri		=> 'https://github.com/afolson/irssi-text',
	description	=> 'A script that will text your phone when you are /away and someone PMs you.',
	license		=> 'GPL',
);

# Ha, load.
my $load = "$IRSSI{name} $IRSSI{version} by $IRSSI{author} <$IRSSI{contact}>";

# Add a switch for this so I don't have to unload it anymore :D?
Irssi::settings_add_bool('text', 'paging_enabled', 1);
Irssi::settings_add_str('text', 'your_name', 'irssi');
Irssi::settings_add_str('text', 'sms_address', '');
Irssi::settings_add_str('text', 'local_email', 'irssi@localhost');

sub text {
	# Check if we even want to get messages
	if (Irssi::settings_get_bool('paging_enabled')) {
		my($server, $msg, $nick, $address) = @_;
		my $your_name = Irssi::settings_get_str('your_name');
		my $sms_address = Irssi::settings_get_str('sms_address');
		my $local_email = Irssi::settings_get_str('local_email');
		if ($sms_address eq '') {
			Irssi::print "ERROR: You must set an SMS address via /set sms_address";
			Irssi::print "If you don't know your SMS address, use the following page for help: http://www.textsendr.com/emailsms.php";
		}
		elsif  ($server->{usermode_away}) {
			my $email = "To: $your_name (SMS) <$sms_address>\n";
			$email .= "From: $nick ($server->{tag}) <$local_email>\n";
			$email .= "\n".$msg;
			send_email($email,$nick,$server);
		}
	}
}

sub send_email {
	my ($email) = @_;
	my $sendmail = Email::Simple->new($email);
	send Sendmail => $sendmail or Irssi::print "Failed to send SMS.";
}

Irssi::signal_add("message private", \&text);
Irssi::print "$load";
