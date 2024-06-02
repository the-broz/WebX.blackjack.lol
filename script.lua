local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
local values = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"}

local function createDeck()
    local deck = {}
    for _, suit in ipairs(suits) do
        for _, value in ipairs(values) do
            table.insert(deck, {value = value, suit = suit})
        end
    end
    return deck
end

local function shuffleDeck(deck)
    local seed = math.random(1, 1000000)
    math.randomseed(seed)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

local function calculateHandValue(hand)
    local value = 0
    local aceCount = 0
    for _, card in ipairs(hand) do
        if card.value == "Ace" then
            aceCount = aceCount + 1
            value = value + 11
        elseif card.value == "King" or card.value == "Queen" or card.value == "Jack" then
            value = value + 10
        else
            value = value + tonumber(card.value)
        end
    end
    while value > 21 and aceCount > 0 do
        value = value - 10
        aceCount = aceCount - 1
    end
    return value
end

local function dealCard(deck)
    return table.remove(deck)
end

local function printHand(hand, name)
    print(name .. "'s hand:")
    for _, card in ipairs(hand) do
        print(card.value .. " of " .. card.suit)
    end
    print("Total value: " .. calculateHandValue(hand) .. "\n")
end


local playerTurn = true
local FILEHOST = "https://raw.githubusercontent.com/the-broz/blackjack.lol-assets/main/"
local unDealedCard = "https://raw.githubusercontent.com/the-broz/blackjack.lol-assets/main/nothing.png"
local playerHand = {}
local dealerHand = {}
local deck = {}
local PLAYER_BET = 0
local PLAYER_BALANCE = 1000 -- TEMPORARY
--local MIN_BET = 5
local PAY_RATE = 1.5
local BJ_RATE = 3

local function playBlackjack()
    if PLAYER_BALANCE < PLAYER_BET then
        warn("Insufficient funds")
        return
    end
    PLAYER_BALANCE = PLAYER_BALANCE - PLAYER_BET
    get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
    get("pcard3").set_source(unDealedCard)
    get("pcard4").set_source(unDealedCard)
    get("dcard3").set_source(unDealedCard)
    get("dcard4").set_source(unDealedCard)
    get("restart").set_content("NEW GAME")
    get("status").set_content("Player Turn")
    deck = createDeck()
    shuffleDeck(deck)

    playerHand = {dealCard(deck), dealCard(deck)}
    dealerHand = {dealCard(deck), dealCard(deck)}

    print("Dealer's face-up card: " .. dealerHand[1].value .. " of " .. dealerHand[1].suit .. "\n")

    local dealerValue = calculateHandValue(dealerHand)
    local DISP_dealerValue = calculateHandValue({dealerHand[1]})
    print(DISP_dealerValue)

    local playerValue = calculateHandValue(playerHand)
    get("dlr-value").set_content(DISP_dealerValue)
    get("plr-value").set_content(playerValue)
    get("pcard1").set_source(FILEHOST..string.lower(playerHand[1].value).."_of_"..string.lower(playerHand[1].suit)..".png")
    get("pcard2").set_source(FILEHOST..string.lower(playerHand[2].value).."_of_"..string.lower(playerHand[2].suit)..".png")
    print("TRYING TO 'SET' SOURCE AS "..FILEHOST..string.lower(dealerHand[1].value).."_of_"..string.lower(dealerHand[1].suit)..".png")
    get("dcard1").set_source(FILEHOST..string.lower(dealerHand[1].value).."_of_"..string.lower(dealerHand[1].suit)..".png")
    print("set source!")
    playerTurn = true
end


local function handlePlayerTurnHit()
    if playerTurn then
        local playerValue = calculateHandValue(playerHand)
        if playerValue > 21 then
            get("status").set_content("Dealer wins!")
            get("plr-value").set_content("BUST")
            playerTurn = false
            return
        end
        playerTurn = false
        table.insert(playerHand, dealCard(deck))
        playerValue = calculateHandValue(playerHand)
        get("plr-value").set_content(playerValue)
        get("pcard"..#playerHand).set_source(FILEHOST..string.lower(playerHand[#playerHand].value).."_of_"..string.lower(playerHand[#playerHand].suit)..".png")
        if playerValue > 21 then
            get("status").set_content("Dealer wins!")
            get("plr-value").set_content("BUST")
            playerTurn = false
        elseif playerValue == 21 then
            get("status").set_content("Player wins!")
            get("plr-value").set_content("BJ")
            playerTurn = false
        else
            playerTurn = true
        end
    end
end

local function handlePlayerTurnStand(forced)
    if playerTurn or forced then
        get("dcard2").set_source(FILEHOST..string.lower(dealerHand[2].value).."_of_"..string.lower(dealerHand[2].suit)..".png")
        playerTurn = false
        get("status").set_content("Dealer Turn")
        table.insert(dealerHand, dealCard(deck))
        local dealerValue = calculateHandValue(dealerHand)
        local playerValue = calculateHandValue(playerHand)
        get("dlr-value").set_content(dealerValue)
        get("dcard"..#dealerHand).set_source(FILEHOST..string.lower(dealerHand[#dealerHand].value).."_of_"..string.lower(dealerHand[#dealerHand].suit)..".png")
        if playerValue == 21 and #playerHand == 2 then
            get("status").set_content("Player wins!")
            get("plr-value").set_content("BJ")
            PLAYER_BALANCE = PLAYER_BET * BJ_RATE + PLAYER_BALANCE
            get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
            return
        end
        if dealerValue < 17 then
            handlePlayerTurnStand(true)
        else
            if dealerValue > 21 or playerValue > dealerValue then
                get("status").set_content("Player wins!")
                PLAYER_BALANCE = math.floor(PLAYER_BET * PAY_RATE + PLAYER_BALANCE)
                get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
                if dealerValue > 21 then
                    get("dlr-value").set_content("BUST")
                end
            elseif dealerValue > playerValue then
                get("status").set_content("Dealer wins!")
            elseif dealerValue == playerValue then
                get("status").set_content("Tie!")
                PLAYER_BALANCE = PLAYER_BET + PLAYER_BALANCE
                get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
            else
                    get("status").set_content("Tie!")
                    PLAYER_BALANCE = PLAYER_BET + PLAYER_BALANCE
                    get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
            end
        end
    end
end

local function resetGame()
    playerTurn = true
    playerHand = {}
    dealerHand = {}
    deck = {}
    playBlackjack()
end

local function handleBet5()
    local betAmount = 5
    if PLAYER_BALANCE - PLAYER_BET >= betAmount then
        
        PLAYER_BET = PLAYER_BET + betAmount
        get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
        get("bet").set_content("Current Bet: $"..PLAYER_BET)
    else
        warn("Insufficient funds")
    end
end
local function handleBet10()
    local betAmount = 10
    if PLAYER_BALANCE - PLAYER_BET >= betAmount then
        PLAYER_BET = PLAYER_BET + betAmount
        get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
        get("bet").set_content("Current Bet: $"..PLAYER_BET)
    else
        warn("Insufficient funds")
    end
end

local function handleBet50()
    local betAmount = 50
    if PLAYER_BALANCE - PLAYER_BET >= betAmount then
        PLAYER_BET = PLAYER_BET + betAmount
        get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
        get("bet").set_content("Current Bet: $"..PLAYER_BET)
    else
        warn("Insufficient funds")
    end
end

local function handleBet100()
    local betAmount = 100
    if PLAYER_BALANCE - PLAYER_BET >= betAmount then
        PLAYER_BET = PLAYER_BET + betAmount
        get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
        get("bet").set_content("Current Bet: $"..PLAYER_BET)
    else
        warn("Insufficient funds")
    end
end

local function clearBet()
        PLAYER_BET = 0
        get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
        get("bet").set_content("Current Bet: $"..PLAYER_BET) 
end

local function allIn()
    PLAYER_BET = PLAYER_BALANCE
    get("balance").set_content("Remaining Balance: $"..PLAYER_BALANCE)
    get("bet").set_content("Current Bet: $"..PLAYER_BET) 
end


get("hit").on_click(handlePlayerTurnHit)

get("stand").on_click(handlePlayerTurnStand)

get("restart").on_click(resetGame)

get("bet_5").on_click(handleBet5)
get("bet_10").on_click(handleBet10)
get("bet_25").on_click(handleBet50)
get("bet_100").on_click(handleBet100)
get("clear").on_click(clearBet)
get("all_in").on_click(allIn)