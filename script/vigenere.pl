#!/usr/bin/perl

use strict;
use warnings;
use autodie;

my( $key, $passphrase, $direction );
$key        = shift // "KRYPTOS";
$passphrase = shift // "PALIMPSEST";
$direction  = shift // "decrypt";

init();

while( <> ) {
	chomp;
	s/[^A-Z]//g;
	my $ciphertext = $_;
	my $plaintext = ciphertext_to_plaintext( $ciphertext );
	print $plaintext, "\n";
}

my( %letter_to_residue, %residue_to_letter );
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
	my $sign = ($direction =~ m/^e/i ? +1 : -1);
	my( @plainresidues );
	for my $i ( 0 .. @cipherresidues-1 ) {
		push @plainresidues, ($cipherresidues[$i] + $sign*$passphraseresidues[$i % @passphraseresidues]) % 26;
	}
	my @plainletters = map {$residue_to_letter{$_}} @plainresidues;
	my $plaintext = join "", @plainletters;
}
