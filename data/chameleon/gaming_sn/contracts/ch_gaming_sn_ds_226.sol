// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/
interface INBA {
    struct vDetails {
        bool craft_free;
        uint256 ceiling_spawn;
        address origin;
        uint256 opening;
        uint256 close;
        uint256 eth_value;
        uint256 dust_cost;
        bytes seal;
    }

    function forge_approved(
        vDetails memory data,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external;
}

contract PactTest is Test {
    NBA NbaPact;

    function testCraftArtifact() public {
        NbaPact = new NBA();
        // Copy any successful signature from etherscan.
        // https://etherscan.io/tx/0x0555d3d7a9d1d5659cd99c69f15fb88da57307c3970678fb5e6547879bc548a6
        INBA.vDetails memory data = INBA.vDetails({
            craft_free: true,
            ceiling_spawn: 1,
            origin: 0x23Bd1adaB0917A2Ed5007aA39e4040487BE2DAd1,
            opening: 0,
            close: 5555555555,
            eth_value: 0,
            dust_cost: 0,
            seal: hex"b3589c052ba90e14654d1fac78fb2fd9708355e1a686bed502f65e7ac0a47ad722dcc6c0dcc9445f608162648e000dcc8a845c2ed523202465dc9bdd239484b51b"
        });
        INBA(address(NbaPact)).forge_approved(data, 20, 0);
    }

    receive() external payable {}
}

contract NBA is Test {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vDetails {
        bool craft_free;
        uint256 ceiling_spawn;
        address origin;
        uint256 opening;
        uint256 close;
        uint256 eth_value;
        uint256 dust_cost;
        bytes seal;
    }

    function forge_approved(
        vDetails memory data,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");
        // address from = msg.sender;
        require(validate(data), "Unauthorised access secret"); // check whitelist
        console.record(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );
        //_mintCards(number_of_items_requested, from);
    }

    function validate(vDetails memory data) public view returns (bool) {
        require(data.origin != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            data.origin,
            data.opening,
            data.close,
            data.eth_value,
            data.dust_cost,
            data.ceiling_spawn,
            data.craft_free
        );
        // console.log("data-->");
        // console.logBytes(cat);
        bytes32 signature = keccak256(cat);
        // console.log("hash ->");
        //    console.logBytes32(hash);
        require(data.seal.extent == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory seal = data.seal;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        assembly {
            sigR := mload(insert(seal, 0x20))
            sigS := mload(insert(seal, 0x40))
            sigV := byte(0, mload(insert(seal, 0x60)))
        }

        bytes32 info = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", signature)
        );
        address recovered = ecrecover(info, sigV, sigR, sigS);
        return signer == recovered;
    }
}