use warnings;
use Data::Dumper;

my $maxPlayers = 10; # there are 9 face cards times 4 suits, so 36 available cards. Thus, there can be no more than 7 players
my $num_args = 0;
my $num_players = 0;
my %possible_player_names=();
my @current_players;
my %hands = ();
my %cards= ();

if (!defined $ARGV[0])
{
		print "\nUsage: dealHands.pl num_players\n";
		exit;
}
else
{
	$num_players = $ARGV[0];
	if($num_players > $maxPlayers)
	{
		die "Maximum number of players is $maxPlayers. Exiting...\n";
	}
}

&generatePlayers();

&generateDeck();

&dealCards();

#print Dumper(%cards);
#print Dumper(%hands);
 

 
#  Function Inputs:
#  Function Description:
#		this function takes in a number of players and randomly generates players from the DC_Villians text file
sub generatePlayers()
{	
	#print "num players is $num_players\n";
	my $file = 'DC_Villians.txt';
	open my $FH, $file or die "Could not open $file: $!";

	while( my $line = <$FH>)  
	{   
		my @vals=split(/\|/, $line);

		#$possible_player_names->{'$vals[0]'}='$vals[1]';
		chomp($vals[1]);
		$possible_player_names{ $vals[0] } = $vals[1];
	}
	
	close $FH;
	
	# Grab n random names from the hash to use as players for this game
	for(my $iter=0; $iter < $num_players; $iter++)
	{
		my @hash_keys    = keys %possible_player_names;
		#print "$_\n" for keys %possible_player_names;
		my $random_key = $hash_keys[rand @hash_keys];
		#print "rand key is $random_key\n";
		my $random_name   = $possible_player_names{$random_key};
		
		$current_players[$iter]=$random_name;
		#print "ans is $random_name\n";
	}	
}

sub generateDeck()
{
	my @suits = ('Clubs', 'Diamonds', 'Hearts', 'Spades');
	my @faceVals = ('2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace');
	

	#$cards{"1"}{Suit}   = $suits[0];
	#$cards{"1"}{FaceVal}   = $faceVals[2];
	
	my $tmp_key = 1; # keys will go from 1 o 52
	foreach my $suit (@suits) 
	{
		foreach my $val (@faceVals) 
		{
			$cards{$tmp_key}{Suit}   = $suit;
			$cards{$tmp_key}{FaceVal}   = $val;
			$tmp_key++;
		}
	}
	
	#print Dumper(%cards);
}

sub dealCards()
{
	foreach my $name (@current_players)
	{
		for(my $cardNum=1; $cardNum <=5 ; $cardNum++)
		{
			my $cardKey = getCard();
			my $card = $cards{$cardKey};
			$hands{ $name }{ $cardNum }=$card;#$cards{$cardNum};
			delete ($cards{$cardKey});
		}
	}
	
	#print Dumper(%hands);
}

sub getCard()
{
		my @hash_keys    = keys %cards;
		#print "$_\n" for keys %possible_player_names;
		my $random_key = $hash_keys[rand @hash_keys];
		#print "rand key is $random_key\n";
		return $random_key;

}

