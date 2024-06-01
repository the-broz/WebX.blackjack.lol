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
local playerHand = {}
local dealerHand = {}
local deck = {}
local PLAYER_CUR_INDEX = 3
local DEALER_CUR_INDEX = 3
local function playBlackjack()
    get("status").set_content("Player Turn")
    deck = createDeck()
    shuffleDeck(deck)

    playerHand = {dealCard(deck), dealCard(deck)}
    dealerHand = {dealCard(deck), dealCard(deck)}
    DEALER_CUR_INDEX = 3
    PLAYER_CUR_INDEX = 3
   -- printHand(playerHand, "Player")
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
 --   printHand(dealerHand, "Dealer")

--[[
    if dealerValue > 21 or playerValue > dealerValue then
        print("Player wins!\n")
    elseif dealerValue > playerValue then
        print("Dealer wins!\n")
    else
        print("It's a tie!\n")
    end]]

local function handlePlayerTurnHit()
    if playerTurn then
    playerTurn = false
    table.insert(playerHand, dealCard(deck))
    local playerValue = calculateHandValue(playerHand)
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
    if dealerValue < 17 then
        handlePlayerTurnStand(true)
    else
        if dealerValue > 21 or playerValue > dealerValue then
            get("status").set_content("Player wins!")
            if dealerValue > 21 then
                get("dlr-value").set_content("BUST")
            end
        elseif dealerValue > playerValue then
            get("status").set_content("Dealer wins!")
        else
            get("status").set_content("Tie!")
        end
    end
    end
end

get("hit").on_click(function()
handlePlayerTurnHit()
end)

get("stand").on_click(function()
    handlePlayerTurnStand()
end)
    

playBlackjack()
