#!/usr/bin/perl

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
while ($lineSet->get_nodelist) {
    my $line = $lineSet->pop()->findvalue('.//@class');
    $line =~ s/\s+/ /g;
    $key = $line;
    $key =~ s/\s//g;
    $key = lc($key);

    my $status = $statusSet->pop()->findvalue('.//text()');
    $status =~ s/\s+/ /g;
    $info{$key}{'status'} = $status;
    $info{$key}{'name'} = $line
}

my $nodeset = $xp->find('//*[@class="col2"]/div');
foreach my $node ($nodeset->get_nodelist) {
    my $detail = $node->findvalue('./p[1]/text()');
    $detail =~ s/\s+/ /g;
    $detail =~s/^(.*):(.*)/$2/;
    $line = $1;
    $detail =~ s/^ //;
    $detail =~ s/ $//;
    $line =~ s/\s//g;
    $line = lc($line);
    $line =~ s/line//;
    if ($info{$line}) {
    	$info{$line}{'message'} = $detail;
   } 
}

my $date = `env TZ=Europe/London date --iso-8601=minutes`;
chomp($date);
print "<?xml version=\"1.0\"?>\n<tube date=\"$date\">\n";
foreach $line (keys %info) {
    print " <line name=\"$info{$line}{'name'}\" status=\"$info{$line}{'status'}\"".($time{$line} ? " time=\"$time{$line}\"" : "").">$info{$line}{'message'}<\/line>\n";
}
print "</tube>\n";
