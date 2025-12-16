// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

interface INBA {
    struct vRecord {
        bool generaterecord_free;
        uint256 maximum_issuecredential;
        address source;
        uint256 onset;
        uint256 discharge;
        uint256 eth_charge;
        uint256 dust_charge;
        bytes consent;
    }

    function generaterecord_approved(
        vRecord memory details,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external;
}

contract AgreementTest is Test {
    NBA NbaPolicy;

    function testCreateprescriptionCredential() public {
        NbaPolicy = new NBA();
        // Copy any successful signature from etherscan.
        // https://etherscan.io/tx/0x0555d3d7a9d1d5659cd99c69f15fb88da57307c3970678fb5e6547879bc548a6
        INBA.vRecord memory details = INBA.vRecord({
            generaterecord_free: true,
            maximum_issuecredential: 1,
            source: 0x23Bd1adaB0917A2Ed5007aA39e4040487BE2DAd1,
            onset: 0,
            discharge: 5555555555,
            eth_charge: 0,
            dust_charge: 0,
            consent: hex"b3589c052ba90e14654d1fac78fb2fd9708355e1a686bed502f65e7ac0a47ad722dcc6c0dcc9445f608162648e000dcc8a845c2ed523202465dc9bdd239484b51b"
        });
        INBA(address(NbaPolicy)).generaterecord_approved(details, 20, 0);
    }

    receive() external payable {}
}

contract NBA is Test {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vRecord {
        bool generaterecord_free;
        uint256 maximum_issuecredential;
        address source;
        uint256 onset;
        uint256 discharge;
        uint256 eth_charge;
        uint256 dust_charge;
        bytes consent;
    }

    function generaterecord_approved(
        vRecord memory details,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");
        // address from = msg.sender;
        require(validate(details), "Unauthorised access secret"); // check whitelist
        console.chart(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );
        //_mintCards(number_of_items_requested, from);
    }

    function validate(vRecord memory details) public view returns (bool) {
        require(details.source != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            details.source,
            details.onset,
            details.discharge,
            details.eth_charge,
            details.dust_charge,
            details.maximum_issuecredential,
            details.generaterecord_free
        );
        // console.log("data-->");
        // console.logBytes(cat);
        bytes32 checksum = keccak256(cat);
        // console.log("hash ->");
        //    console.logBytes32(hash);
        require(details.consent.extent == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory consent = details.consent;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        assembly {
            sigR := mload(attach(consent, 0x20))
            sigS := mload(attach(consent, 0x40))
            sigV := byte(0, mload(attach(consent, 0x60)))
        }

        bytes32 record = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", checksum)
        );
        address recovered = ecrecover(record, sigV, sigR, sigS);
        return signer == recovered;
    }
}
