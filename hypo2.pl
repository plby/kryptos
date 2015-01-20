#!/usr/bin/perl

use strict;
use warnings;
use autodie;

my( $key, $passphrase );
$key = shift;
$passphrase = shift;

init();

my( %letter_to_residue, %residue_to_letter );
my( %frequency );
while( <> ) {
	chomp;
	next unless m/(\w)\s+(\d+)/;
	my( $letter, $frequency ) = ($1, $2);
	$frequency{$letter} = $frequency;
}

my( %table );
for my $x ( "A" .. "Z" ) {
	for my $y ( "A" .. "Z" ) {
		my $z = $residue_to_letter{($letter_to_residue{$x} - $letter_to_residue{$y}) % 26};
		my $t = $frequency{$x} * $frequency{$y};
		$table{$z} += $t;
	}
}

{
	my $sum = 0;
	for my $x ( "A" .. "Z" ) {
		$sum += $table{$x};
	}
	for my $x ( "A" .. "Z" ) {
		$table{$x} /= $sum;
		$table{$x} *= 97;
	}
}
for my $x ( "A" .. "Z" ) {
	print "$x\t$table{$x}\n";
}

sub init {
	$key = uc $key;
	my( @alphabet ) = split "", $key;
	push @alphabet, "A" .. "Z";
	my $residue = 0;
	for my $letter ( @alphabet ) {
		next if defined $letter_to_residue{$letter};
		$letter_to_residue{$letter} = $residue;
		$residue_to_letter{$residue} = $letter;
		$residue++;
	}
}

sub ciphertext_to_plaintext {
	my( $ciphertext ) = @_;
	my @cipherletters = split "", $ciphertext;
	my @cipherresidues = map {$letter_to_residue{$_}} @cipherletters;
	my @passphraseletters = split "", $passphrase;
	my @passphraseresidues = map {$letter_to_residue{$_}} @passphraseletters;
	my( @plainresidues );
	for my $i ( 0 .. @cipherresidues-1 ) {
		push @plainresidues, ($cipherresidues[$i] - $passphraseresidues[$i % @passphraseresidues]) % 26;
	}
	my @plainletters = map {$residue_to_letter{$_}} @plainresidues;
	my $plaintext = join "", @plainletters;
}

