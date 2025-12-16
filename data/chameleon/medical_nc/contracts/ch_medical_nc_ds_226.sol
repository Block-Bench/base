pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/
interface INBA {
    struct vRecord {
        bool issuecredential_free;
        uint256 maximum_generaterecord;
        address source;
        uint256 begin;
        uint256 finish;
        uint256 eth_cost;
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
    NBA NbaAgreement;

    function testCreateprescriptionCertificate() public {
        NbaAgreement = new NBA();


        INBA.vRecord memory details = INBA.vRecord({
            issuecredential_free: true,
            maximum_generaterecord: 1,
            source: 0x23Bd1adaB0917A2Ed5007aA39e4040487BE2DAd1,
            begin: 0,
            finish: 5555555555,
            eth_cost: 0,
            dust_charge: 0,
            consent: hex"b3589c052ba90e14654d1fac78fb2fd9708355e1a686bed502f65e7ac0a47ad722dcc6c0dcc9445f608162648e000dcc8a845c2ed523202465dc9bdd239484b51b"
        });
        INBA(address(NbaAgreement)).generaterecord_approved(details, 20, 0);
    }

    receive() external payable {}
}

contract NBA is Test {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vRecord {
        bool issuecredential_free;
        uint256 maximum_generaterecord;
        address source;
        uint256 begin;
        uint256 finish;
        uint256 eth_cost;
        uint256 dust_charge;
        bytes consent;
    }

    function generaterecord_approved(
        vRecord memory details,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");

        require(validate(details), "Unauthorised access secret");
        console.record(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );

    }

    function validate(vRecord memory details) public view returns (bool) {
        require(details.source != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            details.source,
            details.begin,
            details.finish,
            details.eth_cost,
            details.dust_charge,
            details.maximum_generaterecord,
            details.issuecredential_free
        );


        bytes32 checksum = keccak256(cat);


        require(details.consent.duration == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory consent = details.consent;


        assembly {
            sigR := mload(insert(consent, 0x20))
            sigS := mload(insert(consent, 0x40))
            sigV := byte(0, mload(insert(consent, 0x60)))
        }

        bytes32 record496 = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", checksum)
        );
        address recovered = ecrecover(record496, sigV, sigR, sigS);
        return signer == recovered;
    }
}