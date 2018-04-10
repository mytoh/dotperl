#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DDP;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;

my $data = { a => 1,
             b => 2,
             c => 3,
           };


# p $data->{c}->{f};
# p $data->{c}->{e}[1];

my sub hash_keys ($hash) {
  my @vals = values %{$hash};
  p @vals;
}

hash_keys $data;

my sub hash_values ($hash) {
  my @kys = keys %{$data};
  p @kys;
}

hash_values $data;

my sub all_keys ($hash) {
  foreach my $key (keys %{$hash}) {
    say  "%hash->{$key} = " . $hash->{$key} ;
  }
}

say 'all keys';
all_keys $data;

my sub all_keys_sorted ($hash) {
  for my $key (sort keys %{$hash}) {
    say  "%hash->{$key} = " . $hash->{$key};
  }
}

say  'sort';
all_keys_sorted $data;

my sub all_keys_reversed ($hash) {
  for my $key (reverse sort keys %{$hash}) {
    say  "%hash->{$key} = " . $hash->{$key};
  }
}
say 'reverse';
all_keys_reversed $data;



my sub all_values ($hash) {
  my $total_math_score = 0 ;
  for my $val (values %{$hash}) {
    $total_math_score += $val;
  }
  $total_math_score;
}

p all_values $data;

my sub check_key_existance ($hash, $key) {
  if (exists $hash->{$key}) {
    say '$key exists';
  } else {
    say '$key not exists';
  }
}

p check_key_existance($data, 'a');
p check_key_existance($data, 'not_exists');


my sub delete_key ($hash, $key) {
  delete $hash->{$key};
}

delete_key($data, 'c');
p $data;


my sub all_keys_sorted_ref ($hash) {
  for my $key (sort keys $hash) {
    say "%hash->{$key} = " . $hash->{$key};
  }
}
# not work
# say 'sorted ref';
# all_keys_sorted_ref($data);
