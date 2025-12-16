pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract CryptoRoulette  is ReentrancyGuard {

    uint256 private secretNumber;
    uint256 public lastPlayed;
    uint256 public betPrice = 0.1 ether;
    address public ownerAddr;

    struct Game {
        address player;
        uint256 number;
    }
    Game[] public gamesPlayed;

    function CryptoRoulette() public nonReentrant {
        ownerAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {

        secretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 20 + 1;
    }

    function play(uint256 number) payable public nonReentrant {
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

    function kill() public nonReentrant {
        if (msg.sender == ownerAddr && now > lastPlayed + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}