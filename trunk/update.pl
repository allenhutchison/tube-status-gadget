#!/usr/bin/perl#!/usr/bin/perl

# This parses the tidy(1) output of
# http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html
# Here for information purposes only - this is run on the server so you
# won't have to worry about it.

use XML::XPath;

my $in = join("\n",<>);
my $xp = XML::XPath->new(xml => $in);
my %info;
my $lineSet = $xp->find('//*[@id="service-board"]/dl[@id="lines"]/dt');
my $statusSet = $xp->find('//*[@id="service-board"]/dl[@id="lines"]/dd');
foreach my $node ($lineSet->get_nodelist) {
  my $line = $node->findvalue('.//@class');
  $line =~ s/\s+//g;
  $line = lc($line);
  $info{$line}{'name'} = $line;

  my $status = $node->findvalue('.//following-sibling::dd[position()=1]/text()');
  if ($status =~ /^\s+$/) {
    $status = $node->findvalue('.//following-sibling::dd[@class="problem"]/h3/text()');
    my $message = $node->findvalue('.//following-sibling::dd[@class="problem"]/div[@class="message"]/p/text()');
    $message =~ s/^(.*): (.*)/$2/;
    $message =~ s/\s+/ /g;
    $info{$line}{'message'} = $message;
  }
  $info{$line}{'status'} = $status
}

my $date = `env TZ=Europe/London date --iso-8601=minutes`;
chomp($date);
print "<?xml version=\"1.0\"?>\n<tube date=\"$date\">\n";
foreach $line (keys %info) {
    print " <line name=\"$info{$line}{'name'}\" status=\"$info{$line}{'status'}\">$info{$line}{'message'}<\/line>\n";
}
print "</tube>\n";


# This parses the tidy(1) output of http://www.tfl.gov.uk/tfl/realtime/
# Here for information purposes only - this is run on the server so you
# won't have to worry about it.

use XML::XPath;

my $in = join("\n",<>);
my $xp = XML::XPath->new(xml => $in);
my $nodeset = $xp->find('//div[@class="tubelines"]/div');
foreach my $node ($nodeset->get_nodelist) {
    my $line = $node->findvalue('.//h3/span/@class');
    my $status = $node->findvalue('./span//text()');
    $status =~ s/\s+/ /g;
    $status =~ s/delays/Delays/g;
    $status{$line} = $status;
}
my $nodeset = $xp->find('//div[@id="details"]/div');
foreach my $node ($nodeset->get_nodelist) {
    my @lines;
    foreach ($node->find('.//span')->get_nodelist) {
        push (@lines, $_->findvalue('./@class'));
    }
    my $detail = $node->findvalue('./div[@class="body"]/p[1]/text()');
    my $time = $node->findvalue('./div[@class="body"]/p[2]/text()');
    $detail =~ s/\s+/ /g;
    $detail =~ s/^[^:]*://;
    $detail =~ s/^ //;
    $detail =~ s/ $//;
    $time =~ s/Message received //;
    foreach (@lines) {
        $message{$_} = $detail;
        $time{$_} = $time;
    }
}

my $date = `env TZ=Europe/London date --iso-8601=minutes`;
chomp($date);
print "<?xml version=\"1.0\"?>\n<tube date=\"$date\">\n";
foreach $line (keys %status) {
    $message = $message{$line};
#    $message =~ s/&/&amp;/;
    print " <line name=\"$line\" status=\"$status{$line}\"".($time{$line} ? " time=\"$time{$line}\"" : "").">$message<\/line>\n";
}
print "</tube>\n";
