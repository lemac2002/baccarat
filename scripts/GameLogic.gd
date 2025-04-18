extends Node2D

# Constants for card sprite sheet layout
const CARD_WIDTH := 48
const CARD_HEIGHT := 64
const SPRITE_PATH := "res://assets/image/1.2 Poker cards.png"

const CHIPS_SPRITE_PATH := "res://assets/image/fiches addon (Poker Cards).png"
const CHIP_SIZE := Vector2(46.0, 48.0)
const CHIP_DENOMINATIONS := [1, 5, 25, 100, 500]
const CHIP_REGION_MAP := {
	1: Vector2(0, 0),
	5: Vector2(0, 1),
	25: Vector2(0, 2),
	100: Vector2(0, 3),
	500: Vector2(4, 0)
}

# Positioning for card rendering on screen
const PLAYER_CARD_POS := Vector2(320, 230)
const BANKER_CARD_POS := Vector2(740, 230)
const CARD_SPACING := 50

# Global vars
var deck = []
var player_hand = []
var banker_hand = []
var num_decks = 8

var player_bankroll := 1000
var selected_bet_amount := 0
var active_bets := {
	"Player": 0,
	"Banker": 0,
	"Tie": 0
}

func _ready():
	display_chips()
	$BankrollLabel.text = "Bankroll: $%d" % player_bankroll
	$InsufficientFundsLabel.dialog_text = "Place a bet by selecting the chip value you want ($1, $5, $25, $100, $500). \n Next select the corresponding bet area (Player,Tie or Banker)"
	$InsufficientFundsLabel.popup_centered()

func new_game_pressed() -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Minimalist1.mp3")
	add_child(sfx)
	sfx.play()
	$Start_Game.visible = false
	print("New Game Pressed")
	new_game()

func new_round_pressed() -> void:
	print("New Round Pressed")
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Minimalist1.mp3")
	add_child(sfx)
	sfx.play()
	$New_Round.visible = false
	new_round()

func display_chips():
	for child in get_children():
		if child.name.begins_with("Chip_"):
			remove_child(child)
			child.queue_free()

	var x_start := 450
	var y := 575
	for i in CHIP_DENOMINATIONS.size():
		var denom = CHIP_DENOMINATIONS[i]
		var chip = create_chip_sprite(denom, Vector2(x_start + i * 70, y))
		add_child(chip)
	
func create_chip_sprite(denomination: int, position: Vector2) -> Area2D:
	var area := Area2D.new()
	area.position = position
	area.name = "Chip_%d" % denomination

	var sprite := Sprite2D.new()
	sprite.texture = load(CHIPS_SPRITE_PATH)
	sprite.region_enabled = true
	sprite.region_rect = get_chip_region(denomination)
	sprite.position = Vector2.ZERO  # Top-left alignment
	area.add_child(sprite)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = CHIP_SIZE
	shape.shape = rect
	shape.position = Vector2.ZERO  # Align shape with sprite
	area.add_child(shape)

	area.connect("input_event", Callable(self, "_on_chip_clicked").bind(denomination))
	return area

func get_chip_region(denomination: int) -> Rect2:
	var pos = CHIP_REGION_MAP.get(denomination, Vector2.ZERO)
	return Rect2(pos.x * CHIP_SIZE.x, pos.y * CHIP_SIZE.y, CHIP_SIZE.x, CHIP_SIZE.y)

func _on_chip_clicked(viewport, event, shape_idx, denomination):
	if event is InputEventMouseButton and event.pressed:
		selected_bet_amount = denomination
		$BetAmountLabel.dialog_text = "Selected Chip: $%d" % denomination
		$BetLabel.text = "Selected Chip: $%d" % denomination
		print("Selected chip: $%d" % denomination)

func _on_PlayerBetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if active_bets["Banker"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Banker — you can’t also bet on Player."
			$InsufficientFundsLabel.popup_centered()
			return  0
		if active_bets["Tie"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Tie — you can’t also bet on Player."
			$InsufficientFundsLabel.popup_centered()
			return
		if selected_bet_amount == 0:
			print("No chip selected.")
			return
		active_bets["Player"] += selected_bet_amount
		selected_bet_amount = 0
		$BetAmountLabel.dialog_text = "Bet $%d on Player" % active_bets["Player"]
		$BetLabel.text = "Bet $%d on Player" % active_bets["Player"]
		print("Player Bet Total: $%d" % active_bets["Player"])

func _on_BankerBetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if active_bets["Player"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Player — you can’t also bet on Banker."
			$InsufficientFundsLabel.popup_centered()
			return
		if active_bets["Tie"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Tie — you can’t also bet on Banker."
			$InsufficientFundsLabel.popup_centered()
			return
		if selected_bet_amount == 0:
			print("No chip selected.")
			return
		active_bets["Banker"] += selected_bet_amount
		selected_bet_amount = 0
		$BetAmountLabel.dialog_text = "Bet $%d on Banker" % active_bets["Banker"]
		$BetLabel.text = "Bet $%d on Banker" % active_bets["Banker"]
		print("Banker Bet Total: $%d" % active_bets["Banker"])

func _on_TieBetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if active_bets["Player"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Player — you can’t also bet on Tie."
			$InsufficientFundsLabel.popup_centered()
			return
		if active_bets["Banker"] > 0:
			$InsufficientFundsLabel.dialog_text = "You’ve already bet on Banker — you can’t also bet on Tie."
			$InsufficientFundsLabel.popup_centered()
			return
		if selected_bet_amount == 0:
			print("No chip selected.")
			return
		active_bets["Tie"] += selected_bet_amount
		selected_bet_amount = 0
		$BetAmountLabel.dialog_text = "Bet $%d on Tie" % active_bets["Tie"]
		$BetLabel.text = "Bet $%d on Tie" % active_bets["Tie"]
		print("Tie Bet Total: $%d" % active_bets["Tie"])

func place_bet() -> bool:
	var total_bet: int = active_bets["Player"] + active_bets["Banker"] + active_bets["Tie"]
	if total_bet == 0:
		$InsufficientFundsLabel.dialog_text = "Place a bet before starting!"
		$InsufficientFundsLabel.popup_centered()
		await get_tree().create_timer(2.0).timeout
		$InsufficientFundsLabel.hide()
		$Start_Game.visible = true
		return false
	if total_bet > player_bankroll:
		$InsufficientFundsLabel.dialog_text = "Not enough money for all your bets!"
		$InsufficientFundsLabel.popup_centered()
		await get_tree().create_timer(2.0).timeout
		$InsufficientFundsLabel.hide()
		$Start_Game.visible = true
		active_bets = {
		"Player": 0,
		"Banker": 0,
		"Tie": 0
		}
		$BetLabel.text = ""
		return false
	player_bankroll -= total_bet
	$BankrollLabel.text = "Bankroll: $%d" % player_bankroll
	return true

func clear_cards():
	for child in get_children():
		if child.name.begins_with("Card_"):
			remove_child(child)
			child.queue_free()
# Show player and banker cards visually
func display_cards(player_hand: Array, banker_hand: Array):
	clear_cards()
	
	for i in player_hand.size():
		var card_sprite = create_card_sprite(player_hand[i])
		card_sprite.position = PLAYER_CARD_POS + Vector2(i * CARD_SPACING, 0)
		card_sprite.name = "Card_Player_%d" % i
		add_child(card_sprite)

	for i in banker_hand.size():
		var card_sprite = create_card_sprite(banker_hand[i])
		card_sprite.position = BANKER_CARD_POS + Vector2(i * CARD_SPACING, 0)
		card_sprite.name = "Card_Banker_%d" % i
		add_child(card_sprite)

func create_card_sprite(card: Dictionary) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(SPRITE_PATH)
	sprite.region_enabled = true
	sprite.region_rect = get_card_region(card)
	sprite.scale = Vector2(1.5, 1.5)
	return sprite

func get_card_region(card: Dictionary) -> Rect2:
	var value_map := {"A": 0, "2": 1, "3": 2, "4": 3, "5": 4, "6": 5, "7": 6,
		"8": 7, "9": 8, "10": 9, "J": 10, "Q": 11, "K": 12}
	var suit_map := {"Hearts": 0,"Diamonds": 1,"Spades": 2,"Clubs": 3}
	var value = str(card["rank"])
	var suit = card["suit"]
	var col: int = value_map.get(value, 0)
	var row: int = suit_map.get(suit, 0)

	return Rect2(col * CARD_WIDTH, row * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT)

func new_game():
	randomize()
	print("\n--- Starting New Game ---\n")
	print("\n--- Welcome To The Baccarat Table ---\n")
	
	if await place_bet() != true:
		$Start_Game.visible = true
		return
		
	init_deck()
	shuffle_deck()
	deal_initial_cards()
	display_cards(player_hand, banker_hand)
	evaluate_game()

func new_round():
	print("\n--- Starting New Round ---\n")
	if deck.size() < 50:
		print("Shoe is low with ", deck.size(), " cards remaining, reshuffling...")
		init_deck()
		shuffle_deck()
	
	if await place_bet() != true:
		$New_Round.visible = true
		$Start_Game.visible = false
		return
		
	deal_initial_cards()
	display_cards(player_hand, banker_hand)
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
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Shuffle.mp3")
	add_child(sfx)
	sfx.play()
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
	var player_score = calc_hand_total(player_hand)
	var banker_score = calc_hand_total(banker_hand)
	var payout = 0

	if player_total > banker_total:
		payout += active_bets["Player"] * 2
		$Game_Outcome.dialog_text = "Player wins!\n\nPlayer Hand Total: %d\nBanker Hand Total: %d\n\nPayout: $%d \n\nPlace a new bet for the next round" % [player_score, banker_score, payout]
		print("Player wins!")
	elif banker_total > player_total:
		payout += int(active_bets["Banker"] * 1.95)
		$Game_Outcome.dialog_text = "Banker wins!\n\nPlayer Hand Total: %d\nBanker Hand Total: %d\n\nPayout: $%d \n\nPlace a new bet for the next round" % [player_score, banker_score, payout]
		print("Banker wins!")
	else:
		payout += active_bets["Tie"] * 8
		$Game_Outcome.dialog_text = "Tie!\n\nPlayer Hand Total: %d\nBanker Hand Total: %d\n\nPayout: $%d \n\nPlace a new bet for the next round" % [player_score, banker_score, payout]
		print("Tie!")

	player_bankroll += payout
	$BankrollLabel.text = "Bankroll: $%d" % player_bankroll
	$Game_Outcome.popup_centered()
	$Game_Outcome.visible = true
	await $Game_Outcome.confirmed
	clear_cards()
	$New_Round.visible = true

	# Reset all bets
	active_bets = {
		"Player": 0,
		"Banker": 0,
		"Tie": 0
	}
		

# Create a wait between drawing the 2 initial cards and extra cards
func prompt_player_draw():
	$Drawing.position = Vector2(240, 160)
	$Drawing.text = "Drawing a third card for Player..."
	$Drawing.visible = true
	await get_tree().create_timer(2.0).timeout
	$Drawing.visible = false
	
# Create a wait between drawing the 2 initial cards and extra cards
func promt_banker_draw():
	$Drawing.position = Vector2(660, 160)
	$Drawing.text = "Drawing a third card for Banker..."
	$Drawing.visible = true
	await get_tree().create_timer(2.0).timeout
	$Drawing.visible = false

# Create a wait between drawing the 2 initial cards and extra cards
func end_game():
	$Drawing.position = Vector2(500, 160)
	$Drawing.text = "Calculating Outcome..."
	$Drawing.visible = true
	await get_tree().create_timer(2.0).timeout
	$Drawing.visible = false
	
# Run game
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
		await end_game()
		determine_winner(player_score, banker_score)
		return

	## PLAYERS THIRD CARD RULE ##
	var player_draws_third = false
	var player_third_card = null
	
	if player_score <= 5:
		await prompt_player_draw()
		player_third_card = deck.pop_back()
		player_hand.append(player_third_card)
		player_draws_third = true
		player_score = calc_hand_total(player_hand) # Update player hand with third card
		display_cards(player_hand, banker_hand)
		print("Player draws third card: ", player_third_card, " (Rule: player <= 5)")
	else:
		print("Player stands with ", player_score, " (Rule: player 6 or 7)")
	
	## BANKERS THIRD CARD RULE ##
	if not player_draws_third: # Player did not draw
		if banker_score <= 5:
			var banker_third_card = deck.pop_back()
			await promt_banker_draw()
			banker_hand.append(banker_third_card)
			print("Banker draws third card: ", banker_third_card, " (Rule: banker <= 5 when player stands)")
		else:
			print("Banker stands with ", banker_score, " (Rule: banker 6 or 7 when player stands)")
	else: # Player drew a third card
		var third_card_value = calc_card_value(player_third_card)
		print("Checking banker drawing rule based on player's third card value: ", third_card_value)
		
		if banker_score == 0 or banker_score == 1 or banker_score == 2: # Banker always draws on 0-2
			var banker_third_card = deck.pop_back()
			await promt_banker_draw()
			banker_hand.append(banker_third_card)
			print("Banker draws third card: ", banker_third_card, " (Rule: banker 0-2 always draws)")
		elif banker_score == 3: # Banker draws unless player's third card was 8
			if third_card_value != 8:
				var banker_third_card = deck.pop_back()
				await promt_banker_draw()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 3 draws unless player's third is 8)")
			else:
				print("Banker stands with 3 (Rule: banker 3 stands when player's third is 8)")
		elif banker_score == 4: # Banker draws if player's third card was 2-7
			if third_card_value >= 2 and third_card_value <= 7:
				var banker_third_card = deck.pop_back()
				await promt_banker_draw()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 4 draws when player's third is 2-7)")
			else:
				print("Banker stands with 4 (Rule: banker 4 stands when player's third is 0, 1, 8, or 9)")
		elif banker_score == 5: # Banker draws if player's third card was 4-7
			if third_card_value >= 4 and third_card_value <= 7:
				var banker_third_card = deck.pop_back()
				await promt_banker_draw()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 5 draws when player's third is 4-7)")
			else:
				print("Banker stands with 5 (Rule: banker 5 stands when player's third is 0-3, 8, or 9)")
		elif banker_score == 6: # Banker draws if player's third card was 6-7
			if third_card_value == 6 or third_card_value == 7:
				var banker_third_card = deck.pop_back()
				await promt_banker_draw()
				banker_hand.append(banker_third_card)
				print("Banker draws third card: ", banker_third_card, " (Rule: banker 6 draws when player's third is 6-7)")
			else:
				print("Banker stands with 6 (Rule: banker 6 stands when player's third is 0-5, 8, or 9)")
		elif banker_score == 7: # Banker always stands on 7
			print("Banker stands with 7 (Rule: banker 7 always stands)")
	
	banker_score = calc_hand_total(banker_hand)
	
	print("Final Hands:")
	print("Player: ", player_hand, " Total: ", player_score)
	print("Banker: ", banker_hand, " Total: ", banker_score)
	
	display_cards(player_hand, banker_hand)
	await end_game()
	determine_winner(player_score, banker_score)
	$BankrollLabel.text = "Bankroll: $%d" % player_bankroll
	selected_bet_amount = 0
