#!/usr/bin/perl

use strict;
use warnings;
use lib qw(blib/lib blib/arch/auto/Person);
use Time::HiRes qw(tv_interval gettimeofday);
use Person;

my $start;
my $elapsed;

my $REPEAT = 10000;
my $id     = 123;
my $name   = 'Bob';
my $email  = 'bob@example.com';
my $data;
my $packed;

my $person = Person->new;
my $child = Person::Child->new({ id => 1, child => { id => 2 }, person => { id => 11, name => "test", child => { id => 22 } } });

$start = [gettimeofday];

# Take the 'Person' protocol buffer through its life cycle.

$person->add_children($child);
foreach ( 1 .. $REPEAT ) {
    $person->set_id($id);
    $person->set_name($name);
    $person->set_email($email);
    $person->set_child($child);
    $packed = $person->pack();
    $person->clear();
    $person->unpack($packed);
    $id = $person->id();
    $name = $person->name();
    $email = $person->email();
}

$elapsed = tv_interval($start);

print "1) [$id] $name <$email>: $REPEAT iterations in $elapsed seconds.\n";

# Try again, but this time, populate the object with a hashref.

$data = { id => $id, name => $name, email => $email, child => { id => 11 } };

$start = [gettimeofday];

foreach ( 1 .. $REPEAT ) {
    $person->copy_from($data);
    $packed = $person->pack();
    $person->clear();
    $person->unpack($packed);
    $data = $person->to_hashref();
}

$elapsed = tv_interval($start);

print "2) [$id] $name <$email>: $REPEAT iterations in $elapsed seconds.\n";

$start = [gettimeofday];

foreach ( 1 .. $REPEAT ) {
    $person = Person->new($data);
    $data = $person->to_hashref();
}

$elapsed = tv_interval($start);

print "3) [$id] $name <$email>: $REPEAT iterations in $elapsed seconds.\n";

$start = [gettimeofday];

foreach ( 1 .. $REPEAT ) {
    $packed = Person->new($data)->pack;
}

$elapsed = tv_interval($start);

print "4) [$id] $name <$email>: $REPEAT iterations in $elapsed seconds.\n";

$start = [gettimeofday];

foreach ( 1 .. $REPEAT ) {
    $data = Person->new(Person->new($data)->pack)->to_hashref;
}

$elapsed = tv_interval($start);

print "5) [$id] $name <$email>: $REPEAT iterations in $elapsed seconds.\n";

$person = Person->new( { id => 1, name => "123", child => { id =>1 }, children => [ { id => 1000 } ] } );
my @children = @{$person->to_hashref->{children}} if $person->to_hashref->{children};
die "6) repeated doesn't work - no children" unless @children;
die "6) repeated doesn't work - no child data" unless $children[0]->{id} == 1000;
print "6) repeated recursive works.\n";
