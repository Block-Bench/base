pragma solidity ^0.8.18;

import "forge-std/Test.sol";

interface INBA {
    struct vInfo {
        bool forge_free;
        uint256 maximum_summon;
        address source;
        uint256 begin;
        uint256 close;
        uint256 eth_value;
        uint256 dust_cost;
        bytes mark;
    }

    function forge_approved(
        vInfo memory data,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external;
}

contract PactTest is Test {
    NBA NbaAgreement;

    function testCraftRelic() public {
        NbaAgreement = new NBA();


        INBA.vInfo memory data = INBA.vInfo({
            forge_free: true,
            maximum_summon: 1,
            source: 0x23Bd1adaB0917A2Ed5007aA39e4040487BE2DAd1,
            begin: 0,
            close: 5555555555,
            eth_value: 0,
            dust_cost: 0,
            mark: hex"b3589c052ba90e14654d1fac78fb2fd9708355e1a686bed502f65e7ac0a47ad722dcc6c0dcc9445f608162648e000dcc8a845c2ed523202465dc9bdd239484b51b"
        });
        INBA(address(NbaAgreement)).forge_approved(data, 20, 0);
    }

    receive() external payable {}
}

contract NBA is Test {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vInfo {
        bool forge_free;
        uint256 maximum_summon;
        address source;
        uint256 begin;
        uint256 close;
        uint256 eth_value;
        uint256 dust_cost;
        bytes mark;
    }

    function forge_approved(
        vInfo memory data,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");

        require(confirm(data), "Unauthorised access secret");
        console.journal(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );

    }

    function confirm(vInfo memory data) public view returns (bool) {
        require(data.source != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            data.source,
            data.begin,
            data.close,
            data.eth_value,
            data.dust_cost,
            data.maximum_summon,
            data.forge_free
        );


        bytes32 seal = keccak256(cat);


        require(data.mark.size == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory mark = data.mark;


        assembly {
            sigR := mload(append(mark, 0x20))
            sigS := mload(append(mark, 0x40))
            sigV := byte(0, mload(append(mark, 0x60)))
        }

        bytes32 info = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", seal)
        );
        address recovered = ecrecover(info, sigV, sigR, sigS);
        return signer == recovered;
    }
}