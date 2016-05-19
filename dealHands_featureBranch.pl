use warnings;
use Data::Dumper;

# Author: William Martin
# Date Created: May 17, 2016
# Program Description: This program takes in a number of players and randomly deals 5 playing cards to each player.
#								 Player names are pulled from a list of supervillians (DC_Villains.txt, in same directory).
#                               Given the size of a standard deck, the maximum number of players is 10.

# Global Variables
my $maxPlayers = 10; # there are 13 face cards times 4 suits, so 52 available cards. Thus, there can be no more than 10 players
my $num_args = 0;
my $num_players = 0;
my %possible_player_names=(); # hash of player names pulled from DC_Villains.txt
my @current_players; # array containing players for this game
my %hands = (); # Hash of hashes that contains all hands. Structure is 
#{player_name}|
#						|>{card_1}|
#										|->{suit}
#										|->{val}
#						|>{card_2}|
#										|->{suit}
#										|->{val}
#						|>{card_3}|
#										|->{suit}
#										|->{val}
#						|>{card_4}|
#										|->{suit}
#										|->{val}
#						|>{card_5}|
#										|->{suit}
#										|->{val}
my %cards= ();   # Hash of all reaining available cards where structure is 
#{card_key}|
#				  |>{suit}
#				  |>{val}
						   
# Parse command line input
if (!defined $ARGV[0] || !@ARGV  || @ARGV!=1 )
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
 
#### START  Main program ####
# Create a list of players
&generatePlayers();

# Create the full playing deck
&generateDeck();

# Distribute cards to the players (random - the same card can only be used once)
&dealCards();

# Print the hands to the command line
&showHands();

#### END  Main program ####

exit 0;

 
#  Function Inputs: N/A
#  Function Description:
#		this function takes in a number of players and randomly generates players from the DC_Villians text file
sub generatePlayers()
{	
	my $file = 'DC_Villians.txt'; 
	open my $FH, $file or die "Could not open $file: $!";
 
	# read file line by line and load player names into hash
	while( my $line = <$FH>)  
	{   
		my @vals=split(/\|/, $line);

		chomp($vals[1]); # strip newline
		$possible_player_names{ $vals[0] } = $vals[1];
	}
	
	close $FH;
	
	# Grab n random names from the hash to use as players for this game
	for(my $iter=0; $iter < $num_players; $iter++)
	{
		my @hash_keys    = keys %possible_player_names;
		my $random_key = $hash_keys[rand @hash_keys];
		my $random_name   = $possible_player_names{$random_key};
		
		# put random name in array of current players
		$current_players[$iter]=$random_name;
		 
		# prevent multiple selection of same player name
		delete $possible_player_names{$random_key};
	}	
}

#  Function Inputs: N/A
#  Function Description:
#		this function takes enumerated lists of values and suits and creates a hash of cards corresponding to a full deck
sub generateDeck()
{
	my @suits = ('Clubs', 'Diamonds', 'Hearts', 'Spades');
	my @faceVals = ('2','3','4','5','6','7','8','9','10','J','Q','K','A');
	
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
}

#  Function Inputs: N/A
#  Function Description:
#		this function randomly deals cards to players, deleting dealt cards from the hash as it goes to prevent repetition
sub dealCards()
{
	# deal to each player
	foreach my $name (@current_players)
	{
		# five cards per player
		for(my $cardNum=1; $cardNum <=5 ; $cardNum++)
		{
			my $cardKey = getCard();
			my $card = $cards{$cardKey};
			$hands{ $name }{ $cardNum }=$card; # assign this cards hash to the currently loaded player
			delete ($cards{$cardKey}); # prevent this card from being dealt again
		}
	}
}

#  Function Inputs: N/A
#  Function Description:
#		this is a helper function for dealCards and is used to grab a random key from the current hash of remaining cards
sub getCard()
{
	my @hash_keys    = keys %cards;
	my $random_key = $hash_keys[rand @hash_keys];
	return $random_key;
}

#  Function Inputs: N/A
#  Function Description:
#		this function prints the hands of all the current players
sub showHands()
{ 
	print "\nIn this epic showdown of scoundrels, here are the hands dealt... Who will reign supreme?\n\n"; # print a newline before displaying hands
	foreach my $name (@current_players)
	{
		print "Player Name: $name\n";
		
		for(my $cardNum=1; $cardNum <=5 ; $cardNum++)
		{
			printCard($name, $cardNum);
		}
		bestHand($name);
		print hasPair($name)."\n";
	}

}

#  Function Inputs: playerName (name of player for current hand), cardNum (card for current hand 1..5)
#  Function Description:
#		this is a helper function for showHands that prints a specific card
sub printCard()
{
	my $playerName = shift;
	my $cardNum = shift;
	my $cardSuit = $hands{ $playerName }{ $cardNum }{Suit};
	my $cardVal = $hands{ $playerName }{ $cardNum }{FaceVal};
	print "\t$cardVal of $cardSuit\n";
}

sub bestHand()
{
	$name = shift;
	if(!hasPair($name))
	{
		print(bestCard($name));
	}
	
	
}

sub hasPair()
{
	my $player = shift;
	my %numbers = ();
	for(my $cardNum=1; $cardNum <=5 ; $cardNum++)
	{
		my $cardVal = $hands{ $player }{ $cardNum }{FaceVal};
		if(!exists $numbers{$cardVal})
		{
			$numbers{$cardVal}=undef;
		}
		else
		{
			return "Hand: 1 Pair of $cardVal"."s\n";
		}
	}
}

sub bestCard()
{
	my $player = shift;
	my %numbers = ();
	my $bestCard = 0;
	for(my $cardNum=1; $cardNum <=5 ; $cardNum++)
	{
		my $val = $hands{ $player }{ $cardNum }{FaceVal};
		# note that switch is depricated in perl
		if ($val eq "J"){$val = 11;}
		if ($val eq "Q"){$val = 12;}
		if ($val eq "K"){$val = 13;}
		if ($val eq "A"){$val = 14;}
		
		if($val gt $bestCard)
		{			
			if($val eq "11")		{ $val = "J";}
			if($val eq "12")		{ $val = "Q";}
			if($val eq "13")		{ $val = "K";}
			if($val eq "14")		{ $val = "A";}
			$bestCard = $val;
		}
	}
	return "Hand: $bestCard high\n";
}
