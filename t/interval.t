#!perl

use 5.006;
use strict;
use warnings;
use Test::More tests => 164;

require_ok( 'Number::Interval' );

my $r = new Number::Interval( Min => 5, Max => 20 );
isa_ok( $r, "Number::Interval" );

# Easy
is($r->min, 5,"Check min");
is($r->max, 20,"Check max");
is("$r","(5,20)","Check stringification");
ok(!$r->isinverted,"Check not inverted interval");

# Test an accessor
my @range = $r->minmax;
is($range[0], 5);
is($range[1], 20);
$r->minmax(10,30);
is($r->min, 10);
is($r->max, 30);
$r->minmax(@range);
is($range[0], 5);
is($range[1], 20);

# Specify some test particles
my @inside = (6,19.5,10);
my @outside = (-1,0,35,60);
for (@inside) {
  #print "# Testing contains: $_\n";
  ok($r->contains($_));
}
for (@outside) {
  #print "# Testing does not contain: $_\n";
  ok(!$r->contains($_));
}

# change interval
$r->min( 30 );

is("$r","< 20 and > 30" );
ok($r->isinverted);

# Test arrays
@inside = (0,-5,31,2406);
@outside = (21,29.56);

# inverted
for (@inside) {
  #print "# Testing contains: $_\n";
  ok($r->contains($_));
}
for (@outside) {
  #print "# Testing does not contain: $_\n";
  ok(!$r->contains($_));
}


# Unbound interval
$r = new Number::Interval( Min => 5 );
ok($r->contains( 6 ));
ok(!$r->contains( 4 ));

$r = new Number::Interval( Max => 5 );
ok(!$r->contains( 6 ));
ok($r->contains( 4 ));

# Merging

print "# Merge 2 unbound intervals\n";
my $r1 = new Number::Interval( Max => 4 );
my $r2 = new Number::Interval( Min => 1 );

ok($r1->intersection($r2));
is($r1->max, 4);
is($r1->min, 1);

$r1 = new Number::Interval( Max => 4 );
$r2 = new Number::Interval( Min => 6 );

ok(!$r1->intersection($r2));
is($r1->max, 4);
is($r1->min, undef);

$r1 = new Number::Interval( Max => 4 );
$r2 = new Number::Interval( Max => 6 );

ok($r1->intersection($r2));
is($r1->max, 4);
is($r1->min, undef);

$r1 = new Number::Interval( Min => 4 );
$r2 = new Number::Interval( Min => 6 );

ok($r1->intersection($r2));
is($r1->min, 6);
is($r1->max, undef);

# 2 infinite 

$r1 = new Number::Interval( );
$r2 = new Number::Interval( );

ok($r1->intersection($r2));
is($r1->max, undef);
is($r1->min, undef);

# 1 infinite

$r1 = new Number::Interval( );
$r2 = new Number::Interval( Max => 6 );

ok($r1->intersection($r2));
is($r1->max, 6);
is($r1->min, undef);

$r1 = new Number::Interval( Min => 4);
$r2 = new Number::Interval(  );

ok($r1->intersection($r2));
is($r1->min, 4);
is($r1->max, undef);


$r1 = new Number::Interval( Min => 1 );
$r2 = new Number::Interval( Max => 4 );

ok($r1->intersection($r2));
is($r1->max, 4);
is($r1->min, 1);

# unbound, no overlap

$r1 = new Number::Interval( Max => 1 );
$r2 = new Number::Interval( Min => 4 );

ok(!$r1->intersection($r2));

print "# Merge 2 bound intervals\n";
$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Min => 2, Max => 4 );

ok($r1->intersection($r2));
is($r1->max, 4);
is($r1->min, 2);

$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Min => 6, Max => 20 );

ok(!$r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 1);

print "# Merge 1 bound and 1 unbound\n";
$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Min => 2 );

ok($r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 2);

$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Min => 0 );

ok($r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 1);

$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Max => 3 );

ok($r1->intersection($r2));
is($r1->max, 3);
is($r1->min, 1);

$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Max => 6 );

ok($r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 1);

$r1 = new Number::Interval( Min => 1, Max => 5);
$r2 = new Number::Interval( Min => 6 );

ok(!$r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 1);

# and finally reverse the inputs
$r2 = new Number::Interval( Min => 1, Max => 5);
$r1 = new Number::Interval( Max => 6 );

ok($r1->intersection($r2));
is($r1->max, 5);
is($r1->min, 1);

print "# 2 inverted intervals\n";

$r2 = new Number::Interval( Max => 1, Min => 5);
$r1 = new Number::Interval( Max => 6, Min => 8 );

ok($r1->intersection($r2));
is($r1->max, 1);
is($r1->min, 8);

print "# 1 inverted and 1 bound\n";

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => 2, Max => 3 );

ok(!$r1->intersection($r2));
is($r1->max, 1);
is($r1->min, 5);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => -4, Max => -3 );

ok($r1->intersection($r2));
is($r1->max, -3);
is($r1->min, -4);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => -4, Max => 3 );

ok($r1->intersection($r2));
is($r1->max, 1);
is($r1->min, -4);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => -4, Max => 7 );

eval { $r1->intersection($r2)};
like($@, qr/two/, "Error contains 'two'");

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => 3, Max => 7 );

ok($r1->intersection($r2));
is($r1->max, 7);
is($r1->min, 5);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => 6, Max => 7 );

ok($r1->intersection($r2));
is($r1->max, 7);
is($r1->min, 6);

$r1 = new Number::Interval( Min => 0);
$r2 = new Number::Interval( Min => 0, Max => 2 );

ok($r1->intersection($r2));
is($r1->max, 2);
is($r1->min, 0);

$r2 = new Number::Interval( Min => 0);
$r1 = new Number::Interval( Min => 0, Max => 2 );

ok($r1->intersection($r2));
is($r1->max, 2);
is($r1->min, 0);

$r1 = new Number::Interval( Max => 2);
$r2 = new Number::Interval( Max => 2, Min => 0 );

ok($r1->intersection($r2));
is($r1->max, 2);
is($r1->min, 0);

$r1 = new Number::Interval( Max => 0, Min => 2 );
$r2 = new Number::Interval();

ok($r1->intersection($r2));
is($r1->max, 0);
is($r1->min, 2);


$r1 = new Number::Interval( Max => 2, Min => 0 );
$r2 = new Number::Interval();

ok($r1->intersection($r2));
is($r1->max, 2);
is($r1->min, 0);

$r2 = new Number::Interval( Max => 2, Min => 0 );
$r1 = new Number::Interval();

ok($r1->intersection($r2));
is($r1->max, 2);
is($r1->min, 0);


print "# 1 inverted and 1 unbound\n";


# Need to test both upper and lower limits
# Test max
$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Max => 6 );

eval { $r1->intersection($r2) };
like($@, qr/two/, "Error contains 'two'");

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Max => -5 );

ok($r1->intersection($r2));
is($r1->max, -5);
is($r1->min, 5);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Max => 3.6 );

ok($r1->intersection($r2));
is($r1->max, 1);
is($r1->min, 5);

# Test Min
$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => 6 );

ok($r1->intersection($r2));
is($r1->max, 1);
is($r1->min, 6);

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => -5 );

eval { $r1->intersection($r2) };
like($@, qr/two/, "Error contains 'two'");

$r1 = new Number::Interval( Max => 1, Min => 5);
$r2 = new Number::Interval( Min => 3.6 );

ok($r1->intersection($r2));
is($r1->max, 1);
is($r1->min, 5);


# Inclusive interval
my $int2 = new Number::Interval( Min => 5, Max => 10, IncMin => 1);
is("$int2","[5,10)","Check stringification");
ok( $int2->contains( 5 ), "Contains 5");
ok( $int2->contains( 6 ), "Contains 6");
ok( !$int2->contains( 10 ), "Does not contain 10");
ok( !$int2->contains( 4 ), "Does not contain 4");

# Test equality
$r1 = new Number::Interval( Max => 20, Min => 4);
ok( $r1->equate( new Number::Interval( Max => 20, Min => 4) ), 
    "Bound Equality");

$r1 = new Number::Interval( Max => undef, Min => 4);
ok( $r1->equate( new Number::Interval( Min => 4) ), "Unbound Equality");

$r2 = new Number::Interval( Min => 4 );

ok($r1 eq $r2, "overloaded 'eq' equals");
ok($r1 == $r2, "overloaded '==' equals");
is($r1, $r2, "Test::More overloaded is equals");

# and make something not match
$r2 = new Number::Interval();
ok($r1 != $r2,"not equal to undef interval");

$r2 = new Number::Interval( Max => 4, Min => 20);
ok($r1 != $r2,"not equal to 4 - 20");

# make sure that the Inc flags work properly
$r2 = new Number::Interval( Min => 4, IncMin => 1 );
ok($r1 != $r2,"not equal to >= 4");

$r2 = new Number::Interval( Min => 4, IncMax => 1 );
ok($r1 != $r2,"not equal to >= 4 (with incmax set)");


# min == max
$r1 = new Number::Interval( Min => 4, Max => 4 );
is( "$r1", "==4", "min == max");

ok( $r1->contains( 4 ), "Does 4==4 contain 4");
ok( !$r1->contains( 5 ), "Does 4==4 contain 5");

# positive definite
$r1 = new Number::Interval( Max => 4, posdef => 1);
ok( $r1->pos_def, "is positive definite");
is( $r1->min, 0, "automatically zero bound");
ok( $r1->contains( 3 ), "posdef includes 3");
ok( !$r1->contains( -1 ), "posdef does not include -1");
is( "$r1", "< 4", "stringify posdef");

# copy constructor
$r2 = $r1->copy;
isa_ok($r2, "Number::Interval");
ok( $r2->pos_def, "is positive definite");
is( $r2->min, 0, "automatically zero bound");
ok( $r2->contains( 3 ), "posdef includes 3");
ok( !$r2->contains( -1 ), "posdef does not include -1");
is( "$r2", "< 4", "stringify posdef");

# Test sizeof
my $r_sizeof = new Number::Interval( Min => 4, Max => 12 );
is( $r_sizeof->sizeof, 8, "sizeof of bounded interval" );
$r_sizeof->max( undef );
is( $r_sizeof->sizeof, undef, "sizeof of unbounded interval" );
$r_sizeof->min( undef );
is( $r_sizeof->sizeof, undef, "sizeof of unbounded interval (2)" );
$r_sizeof->max( 12 );
is( $r_sizeof->sizeof, undef, "sizeof of unbounded interval (3)" );
$r_sizeof->min( 18 );
is( $r_sizeof->sizeof, 6, "sizeof of reversed interval" );
