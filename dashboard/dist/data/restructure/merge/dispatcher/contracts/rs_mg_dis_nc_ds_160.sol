pragma solidity ^0.4.19;


contract CryptoRoulette {

    uint256 private secretNumber;
    uint256 public lastPlayed;
    uint256 public betPrice = 0.1 ether;
    address public ownerAddr;

    struct Game {
        address player;
        uint256 number;
    }
    Game[] public gamesPlayed;

    function CryptoRoulette() public {
        ownerAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {

        secretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 20 + 1;
    }

    function play(uint256 number) payable public {
        require(msg.value >= betPrice && number <= 10);
        Game game;
        game.player = msg.sender;
        game.number = number;
        gamesPlayed.push(game);

        if (number == secretNumber) {

            msg.sender.transfer(this.balance);
        }

        shuffle();
        lastPlayed = now;
    }

    function kill() public {
        if (msg.sender == ownerAddr && now > lastPlayed + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }

    // Unified dispatcher - merged from: play, CryptoRoulette, kill
    // Selectors: play=0, CryptoRoulette=1, kill=2
    function execute(uint8 _selector, uint256 number) public payable {
        // Original: play()
        if (_selector == 0) {
            require(msg.value >= betPrice && number <= 10);
            Game game;
            game.player = msg.sender;
            game.number = number;
            gamesPlayed.push(game);
            if (number == secretNumber) {
            msg.sender.transfer(this.balance);
            }
            shuffle();
            lastPlayed = now;
        }
        // Original: CryptoRoulette()
        else if (_selector == 1) {
            ownerAddr = msg.sender;
            shuffle();
        }
        // Original: kill()
        else if (_selector == 2) {
            if (msg.sender == ownerAddr && now > lastPlayed + 1 days) {
            suicide(msg.sender);
            }
        }
    }
}