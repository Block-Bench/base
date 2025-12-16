// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleKarmabank SimpleReputationbankContract;

    function setUp() public {
        SimpleReputationbankContract = new SimpleKarmabank();
    }

    function testecRecover() public {
        emit log_named_decimal_uint(
            "Before operation",
            SimpleReputationbankContract.getStanding(address(this)),
            18
        );
        bytes32 _hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32")
        );
        (, bytes32 r, bytes32 s) = vm.sign(1, _hash);

        // If v value isn't 27 or 28. it will return address(0)
        uint8 v = 29;
        SimpleReputationbankContract.giveCredit(address(this), 1 ether, _hash, v, r, s);

        emit log_named_decimal_uint(
            "After operation",
            SimpleReputationbankContract.getStanding(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract SimpleKarmabank {
    mapping(address => uint256) private balances;
    address PlatformAdmin; //default is address(0)

    function getStanding(address _socialprofile) public view returns (uint256) {
        return balances[_socialprofile];
    }

    function recoverSignerAddress(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        address recoveredAddress = ecrecover(_hash, _v, _r, _s);
        return recoveredAddress;
    }

    function giveCredit(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_to != address(0), "Invalid recipient address");

        address signer = recoverSignerAddress(_hash, _v, _r, _s);
        console.log("signer", signer);

        //require(signer != address(0), "Invalid signature");
        require(signer == PlatformAdmin, "Invalid signature");

        balances[_to] += _amount;
    }
}
