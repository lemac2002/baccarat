extends Node2D

#Gloabl vars
var deck = []
var player_hand = []
var banker_hand = []

func _ready():
	randomize()
	initialize_game()

func initialize_game():
	init_deck()
	shuffle_deck()
	deal_initial_cards

#temp hand rules
	var player_total = calc_hand_total(player_hand)
	var banker_total = calc_hand_total(banker_hand)
	print("Initial Player Hand: ", player_hand, "Total: ", player_total)
	print("Initial Banker Hand: ", banker_hand, "Total: ", banker_total)
	
	if player_total <= 5:
		var third_card = deck.pop_back()
		player_hand.append(third_card)
		print("Player drew third card: ", third_card)
	
	player_total = calc_hand_total(player_hand)
	banker_total = calc_hand_total(banker_hand)
	
	print("Final Player Hand: ", player_hand, "Total: ", player_total)
	print("Final Banker Hand: ", banker_hand, "Total: ", banker_total)
	
	determine_winner(player_total, banker_total)
	
# Creates a standard 52-card deck.
func init_deck():
	var ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	deck.clear()
	for suit in suits:
		for rank in ranks:
			deck.append({"rank": rank, "suit": suit})
			
# Fisher-Yates shuffle implementation
func fisher_yates_shuffle(array):
	var n = array.size()
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)  # Random index from 0 to i (inclusive)
		# Swap the current element with the element at the random index.
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

# A helper that calls our Fisher-Yates shuffle on the deck.
func shuffle_deck():
	fisher_yates_shuffle(deck)


## CARD DEALING AND HAND MANAGEMENT ##

# Deals two cards to each hand.
func deal_initial_cards():
	player_hand.clear()
	banker_hand.clear()
	player_hand.append(deck.pop_back())
	banker_hand.append(deck.pop_back())
	player_hand.append(deck.pop_back())
	banker_hand.append(deck.pop_back())



func calc_hand_total(hand):
	var total = 0
	for card in hand:
		match card["rank"]:
			"10", "J", "Q", "K":
				total += 0
			"A":
				total += 1
			_:
				total += int(card["rank"])
	return total % 10

# Compares totals to determine the winner.
func determine_winner(player_total, banker_total):
	if player_total > banker_total:
		print("Player wins!")
	elif banker_total > player_total:
		print("Banker wins!")
	else:
		print("Tie!")
	
