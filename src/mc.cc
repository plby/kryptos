/*
  Read in a Markov chain from a data file.

  Format:
N K
ALPHABET
NGRAM LOGFREQUENCY
NGRAM LOGFREQUENCY
...

  N is the width of each N-gram.  K is the number of different
  characters in the alphabet, probably 26.  The alphabet line is all
  of the K characters of the alphabet one after another.  Each
  following line is a single ngram followed by the (natural) log
  frequency of that ngram.

  Newlines are forbidden as part of the alphabet, so this is not
  suitable for binary data.  At the moment, no whitespace is allowed,
  actually.

  The NGRAMs should be sorted in lexicographical order according to
  the ALPHABET.

 */

#include "deps.hh"

struct alphabet {
	int K;
	std::vector<char> letters;
	std::map<char, int> index;

	void make_index( ) {
		index = std::map<char, int>();
		for( int i = 0; i < K; i++ ) {
			index[ letters[i] ] = i;
		}
	}
};

struct ngram {
	bool done;
	int N, K;
	std::vector<int> indices;

	ngram( int N, int K ) :
		N(N),
		K(K),
		done(false),
		indices(N,0) {
	}

	ngram& operator++ ( ) {
		int i;
		for( i = N-1; i >= 0; i-- ) {
			if( indices[i] < K-1 )
				break;
		}
		if( i < 0 ) {
			done = false;
		} else {
			indices[i]++;
			for( ; i < N; i++ ) {
				indices[i] = 0;
			}
		}
		return *this;
	}

	ngram operator++ ( int ) {
		ngram result = *this;
		++*this;
		return result;
	}
};

struct markov_chain {
	alphabet A;
	int N;
	std::vector<double> log_freq;
};

std::istream& operator >> ( std::istream& in, alphabet& a ) {
	in >> a.K;
	a.letters = std::vector<char>( a.K, '\n' );
	for( int i = 0; i < a.K; i++ ) {
		char t;
		while( in >> t ) {
			if( t != '\n' )
				break;
		}
		if( in ) {
			a.letters[i] = t;
		} else {
			std::cerr << "Failed to read alphabet." << std::endl;
			exit( 1 );
		}
	}
	a.make_index();
	return in;
}

std::istream& operator >> ( std::istream& in, markov_chain& m ) {
	in >> m.N;
	in >> m.A;

	int entries = 1;
	for( int i = 0; i < m.N; i++ ) {
		entries *= m.A.K;
	}
	m.log_freq = std::vector<double>( entries );

	// Loop over N-grams
	int i = 0;
	for( ngram g(m.N, m.A.K); not g.done; i++, g++ ) {
		std::string t;
		in >> t;

		// Verify this is the right n-gram
		for( int j = 0; j < m.N; j++ ) {
			if( t[j] != m.A.letters[g.indices[j]] ) {
				std::cerr << "Got the wrong N-gram, lexicographically speaking." << std::endl;
				exit( 2 );
			}
		}

		in >> m.log_freq[i];
	}
	if( i != entries ) {
		std::cerr << "Got the wrong number of N-gram log-frequency entries." << std::endl;
		exit( 3 );
	}
	
	return in;
}
