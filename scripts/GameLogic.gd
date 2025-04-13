extends Node2D
#ends

#Global vars
var deck = []
var player_hand = []
var banker_hand = []
var num_decks = 8

func _on_deal_pressed() -> void:
	print("Deal Pressed")
	new_round()
	

# Start a new game round
func new_round():
	print("\n--- Starting New Round ---\n")
	# Check if deck is getting low and reshuffle if needed
	if deck.size() < 50:  # Reshuffles when fewer than 50 cards remain in the shoe
		print("Shoe is low with ", deck.size(), " cards remaining, reshuffling...")
		init_deck()
		shuffle_deck()
	deal_initial_cards()
	evaluate_game()
	

func new_game():
	randomize()
	print("\n--- Starting New Game ---\n")
	print("\n--- Welcome To The Baccarat Table ---\n")
	init_deck()
	shuffle_deck()
	deal_initial_cards()
	evaluate_game()
	
# Creates 8 standard 52-card decks in shoe.
func init_deck():
	var ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	deck.clear()
	
	# Add 8 decks
	for deck_num in range(num_decks):
		for suit in suits:
			for rank in ranks:
				deck.append({"rank": rank, "suit": suit})
	print("Shoe is initialized")
			
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
	print("Shoe shuffled")


## CARD DEALING AND HAND MANAGEMENT ##

# Deals two cards to each hand.
func deal_initial_cards():
	player_hand.clear()
	banker_hand.clear()
	player_hand.append(deck.pop_back())
	banker_hand.append(deck.pop_back())
	player_hand.append(deck.pop_back())
	banker_hand.append(deck.pop_back())

func calc_card_value(card):
	match card["rank"]:
		"10", "J", "Q", "K":
			return 0
		"A":
			return 1
		_:
			return int(card["rank"])

func calc_hand_total(hand):
	var total = 0
	for card in hand:
		total += calc_card_value(card)
	return total % 10

# Compares totals to determine the winner.
func determine_winner(player_total, banker_total):
	if player_total > banker_total:
		print("Player wins!")
	elif banker_total > player_total:
		print("Banker wins!")
	else:
		print("Tie!")
	
# Simulate game
func evaluate_game():
	# Calculate initial totals
	var player_score = calc_hand_total(player_hand)
	var banker_score = calc_hand_total(banker_hand)

	print("Initial Hands:")
	print("Player: ", player_hand, " Total: ", player_score)
	print("Banker: ", banker_hand, " Total: ", banker_score)

	# Check for naturals (8 or 9)
	if player_score >= 8 or banker_score >= 8:
		print("Natural!")
		determine_winner(player_score, banker_score)
		return

	## PLAYERS THIRD CARD RULE ##
	var player_draws_third = false
	var player_third_card = null
	
	if player_score <= 5:
		player_third_card = deck.pop_back()
		player_hand.append(player_third_card)
		player_draws_third = true
		player_score = calc_hand_total(player_hand) # Update player hand with third card
		print("Player draws third card: ", player_third_card, " (Rule: player <= 5)")
	else:
		print("Player stands with ", player_score, " (Rule: player 6 or 7)")
	
	## BANKERS THIRD CARD RULE ##
	if not player_draws_third: # Player did not draw
		if banker_score <= 5:
			var banker_third_card = deck.pop_back()
			banker_hand.append(banker_third_card)
			print("Banker draws third card: ", banker_third_card, " (Rule: banker <= 5 when player stands)")
		else:
			print("Banker stands with ", banker_score, " (Rule: banker 6 or 7 when player stands)")
	else: # Player drew a third card
		var third_card_value = calc_card_value(player_third_card)
		print("Checking banker drawing rule based on player's third card value: ", third_card_value)
		
		if banker_score == 0 or banker_score == 1 or banker_score == 2: # Banker always draws on 0-2
			var banker_third_card = deck.pop_back()
			banker_hand.append(banker_third_card)
			print("Banker draws third card: ", banker_third_card, " (Rule: banker 0-2 always draws)")
		elif banker_score == 3: # Banker draws unless player's third card was 8
			if third_card_value != 8:
				var banker_third_card = deck.pop_back()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 3 draws unless player's third is 8)")
			else:
				print("Banker stands with 3 (Rule: banker 3 stands when player's third is 8)")
		elif banker_score == 4: # Banker draws if player's third card was 2-7
			if third_card_value >= 2 and third_card_value <= 7:
				var banker_third_card = deck.pop_back()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 4 draws when player's third is 2-7)")
			else:
				print("Banker stands with 4 (Rule: banker 4 stands when player's third is 0, 1, 8, or 9)")
		elif banker_score == 5: # Banker draws if player's third card was 4-7
			if third_card_value >= 4 and third_card_value <= 7:
				var banker_third_card = deck.pop_back()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 5 draws when player's third is 4-7)")
			else:
				print("Banker stands with 5 (Rule: banker 5 stands when player's third is 0-3, 8, or 9)")
		elif banker_score == 6: # Banker draws if player's third card was 6-7
			if third_card_value == 6 or third_card_value == 7:
				var banker_third_card = deck.pop_back()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 6 draws when player's third is 6-7)")
			else:
				print("Banker stands with 6 (Rule: banker 6 stands when player's third is 0-5, 8, or 9)")
		elif banker_score == 7: # Banker always stands on 7
			print("Banker stands with 7 (Rule: banker 7 always stands)")
	
	# Calculate final scores
	banker_score = calc_hand_total(banker_hand)
	
	print("Final Hands:")
	print("Player: ", player_hand, " Total: ", player_score)
	print("Banker: ", banker_hand, " Total: ", banker_score)
	
	# Determine winner
	determine_winner(player_score, banker_score)
