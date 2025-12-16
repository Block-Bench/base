pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    AlternateInventorybankManager buggyManager;
    InventorybankManagerV2 fixedManager;

    function setUp() public {
        buggyManager = new AlternateInventorybankManager();
        fixedManager = new InventorybankManagerV2();


        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyManager.addBanks(initialBanks, initialNames);
        fixedManager.addBanks(initialBanks, initialNames);


        emit log_string("Initial state of both bank managers:");
        emit log_named_uint("Alternate manager bank count", buggyManager.getFreightbankCount());
        emit log_named_uint("Fixed manager bank count", fixedManager.getFreightbankCount());
    }

    function testReturnVsBreak() public {

        emit log_string("\nRemoving banks marked for removal");


        address[] memory banksToRemove = new address[](3);
        banksToRemove[0] = address(0x1);
        banksToRemove[1] = address(0x2);
        banksToRemove[2] = address(0x3);
        console.log("------------Testing buggyManager---------------");

        buggyManager.removeBanksWithReturn(banksToRemove);
        emit log_named_uint("Alternate manager (with return) bank count after removal", buggyManager.getFreightbankCount());
        buggyManager.listBanks();

        console.log("------------Testing BankManagerV2---------------");

        fixedManager.removeBanksWithBreak(banksToRemove);
        emit log_named_uint("Fixed manager (with break) bank count after removal", fixedManager.getFreightbankCount());
        fixedManager.listBanks();
    }
}


contract CargobankManager {
    struct InventoryBank {
        address inventorybankAddress;
        string inventorybankName;
    }

    InventoryBank[] public banks;


    function addBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.length == names.length, "Arrays must have the same length");

        for (uint i = 0; i < addresses.length; i++) {
            banks.push(InventoryBank(addresses[i], names[i]));
        }
    }


    function getFreightbankCount() public view returns (uint) {
        return banks.length;
    }


    function getInventorybank(uint index) public view returns (address, string memory) {
        require(index < banks.length, "Index out of bounds");
        return (banks[index].inventorybankAddress, banks[index].inventorybankName);
    }


    function _removeBank(uint index) internal {
        require(index < banks.length, "Index out of bounds");


        if (index < banks.length - 1) {
            banks[index] = banks[banks.length - 1];
        }


        banks.pop();
    }
}


contract AlternateInventorybankManager is CargobankManager, Test {


    function removeBanksWithReturn(address[] memory banksToRemove) public {
        for (uint i = 0; i < banks.length; i++) {
            for (uint j = 0; j < banksToRemove.length; j++) {
                if (banks[i].inventorybankAddress == banksToRemove[j]) {
                    emit log_string(string(abi.encodePacked(
                        "Removing bank: ", banks[i].inventorybankName,
                        " (Address: ", toHexString(uint160(banks[i].inventorybankAddress)), ")"
                    )));

                    _removeBank(i);
                    return;
                }
            }
        }
    }


    function listBanks() public {
        emit log_string("Banks in buggy manager:");
        for (uint i = 0; i < banks.length; i++) {
            emit log_string(string(abi.encodePacked(
                "Bank ", toString(i), ": ",
                banks[i].inventorybankName, " (Address: ",
                toHexString(uint160(banks[i].inventorybankAddress)), ")"
            )));
        }
    }


    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    function toHexString(uint value) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint length = 40;
        bytes memory buffer = new bytes(2 + length);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + length - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}


contract InventorybankManagerV2 is CargobankManager, Test {


    function removeBanksWithBreak(address[] memory banksToRemove) public {

        for (int i = int(banks.length) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksToRemove.length; j++) {
                if (banks[uint(i)].inventorybankAddress == banksToRemove[j]) {
                    emit log_string(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].inventorybankName,
                        " (Address: ", toHexString(uint160(banks[uint(i)].inventorybankAddress)), ")"
                    )));

                    _removeBank(uint(i));
                    break;
                }
            }
        }
    }


    function listBanks() public {
        emit log_string("Banks in fixed manager:");
        for (uint i = 0; i < banks.length; i++) {
            emit log_string(string(abi.encodePacked(
                "Bank ", toString(i), ": ",
                banks[i].inventorybankName, " (Address: ",
                toHexString(uint160(banks[i].inventorybankAddress)), ")"
            )));
        }
    }


    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    function toHexString(uint value) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint length = 40;
        bytes memory buffer = new bytes(2 + length);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + length - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}