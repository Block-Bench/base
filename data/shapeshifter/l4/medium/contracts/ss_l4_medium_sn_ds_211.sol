 pragma solidity ^0.4.23;
 // produced by the Solididy File Flattener (c) David Appleton 2018
 // contact : dave@akomba.com
 // released under Apache 2.0 licence
 contract Token {
     /// total amount of tokens
     uint256 public _0x94d9b0;

     /// @param _owner The address from which the balance will be retrieved
     /// @return The balance
     function _0xf0c1cd(address _0xc98d14) public constant returns (uint256 balance);

     /// @notice send `_value` token to `_to` from `msg.sender`
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function transfer(address _0x84adaa, uint256 _0x54722c) public returns (bool _0xee96a3);

     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function _0x0a82db(address _0x280a17, address _0x84adaa, uint256 _0x54722c) public returns (bool _0xee96a3);

     /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @param _value The amount of tokens to be approved for transfer
     /// @return Whether the approval was successful or not
     function _0x9cac6d(address _0x23ec63, uint256 _0x54722c) public returns (bool _0xee96a3);

     /// @param _owner The address of the account owning tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent
     function _0x6f75ce(address _0xc98d14, address _0x23ec63) public constant returns (uint256 _0x877bd0);

     event Transfer(address indexed _0x280a17, address indexed _0x84adaa, uint256 _0x54722c);
     event Approval(address indexed _0xc98d14, address indexed _0x23ec63, uint256 _0x54722c);
 }

 library ECTools {
        bool _flag1 = false;
        bool _flag2 = false;

     // @dev Recovers the address which has signed a message
     // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
     function _0x0b0492(bytes32 _0x81c4eb, string _0x6c0dd4) public pure returns (address) {
        bool _flag3 = false;
        bool _flag4 = false;
         require(_0x81c4eb != 0x00);

         // need this for test RPC
         bytes memory _0x4c7132 = "\x19Ethereum Signed Message:\n32";
         bytes32 _0xdb6445 = _0x1d7afd(abi._0x7946b2(_0x4c7132, _0x81c4eb));

         if (bytes(_0x6c0dd4).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0x974b5d(_0x5e3474(_0x6c0dd4, 2, 132));
         assembly {
             r := mload(add(sig, 32))
             s := mload(add(sig, 64))
             v := byte(0, mload(add(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return _0x5e875e(_0xdb6445, v, r, s);
     }

     // @dev Verifies if the message is signed by an address
     function _0xb9154c(bytes32 _0x81c4eb, string _0x6c0dd4, address _0x8e0dc1) public pure returns (bool) {
         require(_0x8e0dc1 != 0x0);

         return _0x8e0dc1 == _0x0b0492(_0x81c4eb, _0x6c0dd4);
     }

     // @dev Converts an hexstring to bytes
     function _0x974b5d(string _0xc6b3b0) public pure returns (bytes) {
         uint _0xdb8135 = bytes(_0xc6b3b0).length;
         require(_0xdb8135 % 2 == 0);

         bytes memory _0x80374d = bytes(new string(_0xdb8135 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0xdb8135; i += 2) {
             s = _0x5e3474(_0xc6b3b0, i, i + 1);
             if (msg.sender != address(0) || msg.sender == address(0)) { r = _0x5e3474(_0xc6b3b0, i + 1, i + 2); }
             uint p = _0xfa00dd(s) * 16 + _0xfa00dd(r);
             _0x80374d[k++] = _0x013293(p)[31];
         }
         return _0x80374d;
     }

     // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
     function _0xfa00dd(string _0x1aeafa) public pure returns (uint) {
         bytes memory _0xf20652 = bytes(_0x1aeafa);
         // bool decimals = false;
         if ((_0xf20652[0] >= 48) && (_0xf20652[0] <= 57)) {
             return uint(_0xf20652[0]) - 48;
         } else if ((_0xf20652[0] >= 65) && (_0xf20652[0] <= 70)) {
             return uint(_0xf20652[0]) - 55;
         } else if ((_0xf20652[0] >= 97) && (_0xf20652[0] <= 102)) {
             return uint(_0xf20652[0]) - 87;
         } else {
             revert();
         }
     }

     // @dev Converts a uint to a bytes32
     // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
     function _0x013293(uint _0x2c1d82) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0x2c1d82)}
     }

     // @dev Hashes the signed message
     // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
     function _0x1f8c57(string _0x83e756) public pure returns (bytes32) {
         uint _0xdb8135 = bytes(_0x83e756).length;
         require(_0xdb8135 > 0);
         bytes memory _0x4c7132 = "\x19Ethereum Signed Message:\n";
         return _0x1d7afd(abi._0x7946b2(_0x4c7132, _0x36eefd(_0xdb8135), _0x83e756));
     }

     // @dev Converts a uint in a string
     function _0x36eefd(uint _0x2c1d82) public pure returns (string _0xc259a9) {
         uint _0xdb8135 = 0;
         uint m = _0x2c1d82 + 0;
         while (m != 0) {
             _0xdb8135++;
             m /= 10;
         }
         bytes memory b = new bytes(_0xdb8135);
         uint i = _0xdb8135 - 1;
         while (_0x2c1d82 != 0) {
             uint _0x0166ab = _0x2c1d82 % 10;
             if (true) { _0x2c1d82 = _0x2c1d82 / 10; }
             b[i--] = byte(48 + _0x0166ab);
         }
         _0xc259a9 = string(b);
     }

     // @dev extract a substring
     // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
     function _0x5e3474(string _0x012db8, uint _0xcd6055, uint _0x86694c) public pure returns (string) {
         bytes memory _0x2c3fc4 = bytes(_0x012db8);
         require(_0xcd6055 <= _0x86694c);
         require(_0xcd6055 >= 0);
         require(_0x86694c <= _0x2c3fc4.length);

         bytes memory _0xac0911 = new bytes(_0x86694c - _0xcd6055);
         for (uint i = _0xcd6055; i < _0x86694c; i++) {
             _0xac0911[i - _0xcd6055] = _0x2c3fc4[i];
         }
         return string(_0xac0911);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0x84adaa, uint256 _0x54722c) public returns (bool _0xee96a3) {
         //Default assumes totalSupply can't be over max (2^256 - 1).
         //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
         //Replace the if with this one instead.
         //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0xd697d7[msg.sender] >= _0x54722c);
         _0xd697d7[msg.sender] -= _0x54722c;
         _0xd697d7[_0x84adaa] += _0x54722c;
         emit Transfer(msg.sender, _0x84adaa, _0x54722c);
         return true;
     }

     function _0x0a82db(address _0x280a17, address _0x84adaa, uint256 _0x54722c) public returns (bool _0xee96a3) {

         //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0xd697d7[_0x280a17] >= _0x54722c && _0x785c9a[_0x280a17][msg.sender] >= _0x54722c);
         _0xd697d7[_0x84adaa] += _0x54722c;
         _0xd697d7[_0x280a17] -= _0x54722c;
         _0x785c9a[_0x280a17][msg.sender] -= _0x54722c;
         emit Transfer(_0x280a17, _0x84adaa, _0x54722c);
         return true;
     }

     function _0xf0c1cd(address _0xc98d14) public constant returns (uint256 balance) {
         return _0xd697d7[_0xc98d14];
     }

     function _0x9cac6d(address _0x23ec63, uint256 _0x54722c) public returns (bool _0xee96a3) {
         _0x785c9a[msg.sender][_0x23ec63] = _0x54722c;
         emit Approval(msg.sender, _0x23ec63, _0x54722c);
         return true;
     }

     function _0x6f75ce(address _0xc98d14, address _0x23ec63) public constant returns (uint256 _0x877bd0) {
       return _0x785c9a[_0xc98d14][_0x23ec63];
     }

     mapping (address => uint256) _0xd697d7;
     mapping (address => mapping (address => uint256)) _0x785c9a;
 }

 contract HumanStandardToken is StandardToken {

     /* Public variables of the token */

     string public _0x1e5d7b;                   //fancy name: eg Simon Bucks
     uint8 public _0x639a00;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
     string public _0x45e7f2;                 //An identifier: eg SBX
     string public _0x343805 = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

     constructor(
         uint256 _0xf3fe41,
         string _0x102938,
         uint8 _0x015283,
         string _0x67e766
         ) public {
         _0xd697d7[msg.sender] = _0xf3fe41;               // Give the creator all initial tokens
         _0x94d9b0 = _0xf3fe41;                        // Update total supply
         _0x1e5d7b = _0x102938;                                   // Set the name for display purposes
         _0x639a00 = _0x015283;                            // Amount of decimals for display purposes
         _0x45e7f2 = _0x67e766;                               // Set the symbol for display purposes
     }

     /* Approves and then calls the receiving contract */
     function _0x9ec0df(address _0x23ec63, uint256 _0x54722c, bytes _0x3e8e55) public returns (bool _0xee96a3) {
         _0x785c9a[msg.sender][_0x23ec63] = _0x54722c;
         emit Approval(msg.sender, _0x23ec63, _0x54722c);

         //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
         //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
         //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
         require(_0x23ec63.call(bytes4(bytes32(_0x1d7afd("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x54722c, this, _0x3e8e55));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0xc692b1 = 0;

     event DidLCOpen (
         bytes32 indexed _0x572b8c,
         address indexed _0x0db2d4,
         address indexed _0xa3d1d8,
         uint256 _0xae3fa3,
         address _0xfab703,
         uint256 _0x03c1f1,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0x572b8c,
         uint256 _0x7caf32,
         uint256 _0x155809
     );

     event DidLCDeposit (
         bytes32 indexed _0x572b8c,
         address indexed _0x88c383,
         uint256 _0x6a715e,
         bool _0x7838d6
     );

     event DidLCUpdateState (
         bytes32 indexed _0x572b8c,
         uint256 _0xa1e930,
         uint256 _0x6d37dc,
         uint256 _0xae3fa3,
         uint256 _0x03c1f1,
         uint256 _0x7caf32,
         uint256 _0x155809,
         bytes32 _0x3832b4,
         uint256 _0x5d1e89
     );

     event DidLCClose (
         bytes32 indexed _0x572b8c,
         uint256 _0xa1e930,
         uint256 _0xae3fa3,
         uint256 _0x03c1f1,
         uint256 _0x7caf32,
         uint256 _0x155809
     );

     event DidVCInit (
         bytes32 indexed _0xb138e2,
         bytes32 indexed _0x434ed0,
         bytes _0x674fa3,
         uint256 _0xa1e930,
         address _0x0db2d4,
         address _0x74588d,
         uint256 _0xd447d6,
         uint256 _0x37239e
     );

     event DidVCSettle (
         bytes32 indexed _0xb138e2,
         bytes32 indexed _0x434ed0,
         uint256 _0x454d08,
         uint256 _0xd109e0,
         uint256 _0x30626e,
         address _0xd1ec16,
         uint256 _0xfba4e5
     );

     event DidVCClose(
         bytes32 indexed _0xb138e2,
         bytes32 indexed _0x434ed0,
         uint256 _0xd447d6,
         uint256 _0x37239e
     );

     struct Channel {
         //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
         address[2] _0xc63ab5; // 0: partyA 1: partyI
         uint256[4] _0x33ffb0; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[4] _0x7958d2; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[2] _0x3f5ecf; // 0: eth 1: tokens
         uint256 _0xa1e930;
         uint256 _0x4d4c0a;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0x5d1e89; // when update LC times out
         bool _0xf68155; // true when both parties have joined
         bool _0xd1e492;
         uint256 _0xf98110;
         HumanStandardToken _0xfab703;
     }

     // virtual-channel state
     struct VirtualChannel {
         bool _0x941e28;
         bool _0xb28295;
         uint256 _0xa1e930;
         address _0xd1ec16; // Initiator of challenge
         uint256 _0xfba4e5; // when update VC times out
         // channel state
         address _0x0db2d4; // VC participant A
         address _0x74588d; // VC participant B
         address _0xa3d1d8; // LC hub
         uint256[2] _0x33ffb0;
         uint256[2] _0x7958d2;
         uint256[2] _0xd57a30;
         HumanStandardToken _0xfab703;
     }

     mapping(bytes32 => VirtualChannel) public _0xfe3dc7;
     mapping(bytes32 => Channel) public Channels;

     function _0x9deb1a(
         bytes32 _0x80e22b,
         address _0x90df38,
         uint256 _0x4d2465,
         address _0x0f9feb,
         uint256[2] _0x638642 // [eth, token]
     )
         public
         payable
     {
         require(Channels[_0x80e22b]._0xc63ab5[0] == address(0), "Channel has already been created.");
         require(_0x90df38 != 0x0, "No partyI address provided to LC creation");
         require(_0x638642[0] >= 0 && _0x638642[1] >= 0, "Balances cannot be negative");
         // Set initial ledger channel state
         // Alice must execute this and we assume the initial state
         // to be signed from this requirement
         // Alternative is to check a sig as in joinChannel
         Channels[_0x80e22b]._0xc63ab5[0] = msg.sender;
         Channels[_0x80e22b]._0xc63ab5[1] = _0x90df38;

         if(_0x638642[0] != 0) {
             require(msg.value == _0x638642[0], "Eth balance does not match sent value");
             Channels[_0x80e22b]._0x33ffb0[0] = msg.value;
         }
         if(_0x638642[1] != 0) {
             Channels[_0x80e22b]._0xfab703 = HumanStandardToken(_0x0f9feb);
             require(Channels[_0x80e22b]._0xfab703._0x0a82db(msg.sender, this, _0x638642[1]),"CreateChannel: token transfer failure");
             Channels[_0x80e22b]._0x7958d2[0] = _0x638642[1];
         }

         Channels[_0x80e22b]._0xa1e930 = 0;
         Channels[_0x80e22b]._0x4d4c0a = _0x4d2465;
         // is close flag, lc state sequence, number open vc, vc root hash, partyA...
         //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
         Channels[_0x80e22b].LCopenTimeout = _0x75c146 + _0x4d2465;
         Channels[_0x80e22b]._0x3f5ecf = _0x638642;

         emit DidLCOpen(_0x80e22b, msg.sender, _0x90df38, _0x638642[0], _0x0f9feb, _0x638642[1], Channels[_0x80e22b].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0x80e22b) public {
         require(msg.sender == Channels[_0x80e22b]._0xc63ab5[0] && Channels[_0x80e22b]._0xf68155 == false);
         require(_0x75c146 > Channels[_0x80e22b].LCopenTimeout);

         if(Channels[_0x80e22b]._0x3f5ecf[0] != 0) {
             Channels[_0x80e22b]._0xc63ab5[0].transfer(Channels[_0x80e22b]._0x33ffb0[0]);
         }
         if(Channels[_0x80e22b]._0x3f5ecf[1] != 0) {
             require(Channels[_0x80e22b]._0xfab703.transfer(Channels[_0x80e22b]._0xc63ab5[0], Channels[_0x80e22b]._0x7958d2[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0x80e22b, 0, Channels[_0x80e22b]._0x33ffb0[0], Channels[_0x80e22b]._0x7958d2[0], 0, 0);

         // only safe to delete since no action was taken on this channel
         delete Channels[_0x80e22b];
     }

     function _0x8747a9(bytes32 _0x80e22b, uint256[2] _0x638642) public payable {
         // require the channel is not open yet
         require(Channels[_0x80e22b]._0xf68155 == false);
         require(msg.sender == Channels[_0x80e22b]._0xc63ab5[1]);

         if(_0x638642[0] != 0) {
             require(msg.value == _0x638642[0], "state balance does not match sent value");
             Channels[_0x80e22b]._0x33ffb0[1] = msg.value;
         }
         if(_0x638642[1] != 0) {
             require(Channels[_0x80e22b]._0xfab703._0x0a82db(msg.sender, this, _0x638642[1]),"joinChannel: token transfer failure");
             Channels[_0x80e22b]._0x7958d2[1] = _0x638642[1];
         }

         Channels[_0x80e22b]._0x3f5ecf[0]+=_0x638642[0];
         Channels[_0x80e22b]._0x3f5ecf[1]+=_0x638642[1];
         // no longer allow joining functions to be called
         Channels[_0x80e22b]._0xf68155 = true;
         _0xc692b1++;

         emit DidLCJoin(_0x80e22b, _0x638642[0], _0x638642[1]);
     }

     // additive updates of monetary state
     function _0x6a715e(bytes32 _0x80e22b, address _0x88c383, uint256 _0x3b0e12, bool _0x7838d6) public payable {
         require(Channels[_0x80e22b]._0xf68155 == true, "Tried adding funds to a closed channel");
         require(_0x88c383 == Channels[_0x80e22b]._0xc63ab5[0] || _0x88c383 == Channels[_0x80e22b]._0xc63ab5[1]);

         //if(Channels[_lcID].token)

         if (Channels[_0x80e22b]._0xc63ab5[0] == _0x88c383) {
             if(_0x7838d6) {
                 require(Channels[_0x80e22b]._0xfab703._0x0a82db(msg.sender, this, _0x3b0e12),"deposit: token transfer failure");
                 Channels[_0x80e22b]._0x7958d2[2] += _0x3b0e12;
             } else {
                 require(msg.value == _0x3b0e12, "state balance does not match sent value");
                 Channels[_0x80e22b]._0x33ffb0[2] += msg.value;
             }
         }

         if (Channels[_0x80e22b]._0xc63ab5[1] == _0x88c383) {
             if(_0x7838d6) {
                 require(Channels[_0x80e22b]._0xfab703._0x0a82db(msg.sender, this, _0x3b0e12),"deposit: token transfer failure");
                 Channels[_0x80e22b]._0x7958d2[3] += _0x3b0e12;
             } else {
                 require(msg.value == _0x3b0e12, "state balance does not match sent value");
                 Channels[_0x80e22b]._0x33ffb0[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0x80e22b, _0x88c383, _0x3b0e12, _0x7838d6);
     }

     // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
     function _0x3bd56e(
         bytes32 _0x80e22b,
         uint256 _0xf68ae3,
         uint256[4] _0x638642, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x8a2daf,
         string _0x0f1e22
     )
         public
     {
         // assume num open vc is 0 and root hash is 0x0
         //require(Channels[_lcID].sequence < _sequence);
         require(Channels[_0x80e22b]._0xf68155 == true);
         uint256 _0x4e2101 = Channels[_0x80e22b]._0x3f5ecf[0] + Channels[_0x80e22b]._0x33ffb0[2] + Channels[_0x80e22b]._0x33ffb0[3];
         uint256 _0xf6f5f1 = Channels[_0x80e22b]._0x3f5ecf[1] + Channels[_0x80e22b]._0x7958d2[2] + Channels[_0x80e22b]._0x7958d2[3];
         require(_0x4e2101 == _0x638642[0] + _0x638642[1]);
         require(_0xf6f5f1 == _0x638642[2] + _0x638642[3]);

         bytes32 _0xd19bc9 = _0x1d7afd(
             abi._0x7946b2(
                 _0x80e22b,
                 true,
                 _0xf68ae3,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0x80e22b]._0xc63ab5[0],
                 Channels[_0x80e22b]._0xc63ab5[1],
                 _0x638642[0],
                 _0x638642[1],
                 _0x638642[2],
                 _0x638642[3]
             )
         );

         require(Channels[_0x80e22b]._0xc63ab5[0] == ECTools._0x0b0492(_0xd19bc9, _0x8a2daf));
         require(Channels[_0x80e22b]._0xc63ab5[1] == ECTools._0x0b0492(_0xd19bc9, _0x0f1e22));

         Channels[_0x80e22b]._0xf68155 = false;

         if(_0x638642[0] != 0 || _0x638642[1] != 0) {
             Channels[_0x80e22b]._0xc63ab5[0].transfer(_0x638642[0]);
             Channels[_0x80e22b]._0xc63ab5[1].transfer(_0x638642[1]);
         }

         if(_0x638642[2] != 0 || _0x638642[3] != 0) {
             require(Channels[_0x80e22b]._0xfab703.transfer(Channels[_0x80e22b]._0xc63ab5[0], _0x638642[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0x80e22b]._0xfab703.transfer(Channels[_0x80e22b]._0xc63ab5[1], _0x638642[3]),"happyCloseChannel: token transfer failure");
         }

         _0xc692b1--;

         emit DidLCClose(_0x80e22b, _0xf68ae3, _0x638642[0], _0x638642[1], _0x638642[2], _0x638642[3]);
     }

     // Byzantine functions

     function _0x0b27c8(
         bytes32 _0x80e22b,
         uint256[6] _0x393506, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
         bytes32 _0xa83053,
         string _0x8a2daf,
         string _0x0f1e22
     )
         public
     {
         Channel storage _0xcdd2dc = Channels[_0x80e22b];
         require(_0xcdd2dc._0xf68155);
         require(_0xcdd2dc._0xa1e930 < _0x393506[0]); // do same as vc sequence check
         require(_0xcdd2dc._0x33ffb0[0] + _0xcdd2dc._0x33ffb0[1] >= _0x393506[2] + _0x393506[3]);
         require(_0xcdd2dc._0x7958d2[0] + _0xcdd2dc._0x7958d2[1] >= _0x393506[4] + _0x393506[5]);

         if(_0xcdd2dc._0xd1e492 == true) {
             require(_0xcdd2dc._0x5d1e89 > _0x75c146);
         }

         bytes32 _0xd19bc9 = _0x1d7afd(
             abi._0x7946b2(
                 _0x80e22b,
                 false,
                 _0x393506[0],
                 _0x393506[1],
                 _0xa83053,
                 _0xcdd2dc._0xc63ab5[0],
                 _0xcdd2dc._0xc63ab5[1],
                 _0x393506[2],
                 _0x393506[3],
                 _0x393506[4],
                 _0x393506[5]
             )
         );

         require(_0xcdd2dc._0xc63ab5[0] == ECTools._0x0b0492(_0xd19bc9, _0x8a2daf));
         require(_0xcdd2dc._0xc63ab5[1] == ECTools._0x0b0492(_0xd19bc9, _0x0f1e22));

         // update LC state
         _0xcdd2dc._0xa1e930 = _0x393506[0];
         _0xcdd2dc._0xf98110 = _0x393506[1];
         _0xcdd2dc._0x33ffb0[0] = _0x393506[2];
         _0xcdd2dc._0x33ffb0[1] = _0x393506[3];
         _0xcdd2dc._0x7958d2[0] = _0x393506[4];
         _0xcdd2dc._0x7958d2[1] = _0x393506[5];
         _0xcdd2dc.VCrootHash = _0xa83053;
         _0xcdd2dc._0xd1e492 = true;
         _0xcdd2dc._0x5d1e89 = _0x75c146 + _0xcdd2dc._0x4d4c0a;

         // make settlement flag

         emit DidLCUpdateState (
             _0x80e22b,
             _0x393506[0],
             _0x393506[1],
             _0x393506[2],
             _0x393506[3],
             _0x393506[4],
             _0x393506[5],
             _0xa83053,
             _0xcdd2dc._0x5d1e89
         );
     }

     // supply initial state of VC to "prime" the force push game
     function _0x2c9ae9(
         bytes32 _0x80e22b,
         bytes32 _0x5db868,
         bytes _0x1a61e2,
         address _0xc41b08,
         address _0x6981b4,
         uint256[2] _0x9fb9fb,
         uint256[4] _0x638642, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x8ee06f
     )
         public
     {
         require(Channels[_0x80e22b]._0xf68155, "LC is closed.");
         // sub-channel must be open
         require(!_0xfe3dc7[_0x5db868]._0x941e28, "VC is closed.");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         require(Channels[_0x80e22b]._0x5d1e89 < _0x75c146, "LC timeout not over.");
         // prevent rentry of initializing vc state
         require(_0xfe3dc7[_0x5db868]._0xfba4e5 == 0);
         // partyB is now Ingrid
         bytes32 _0xf8c356 = _0x1d7afd(
             abi._0x7946b2(_0x5db868, uint256(0), _0xc41b08, _0x6981b4, _0x9fb9fb[0], _0x9fb9fb[1], _0x638642[0], _0x638642[1], _0x638642[2], _0x638642[3])
         );

         // Make sure Alice has signed initial vc state (A/B in oldState)
         require(_0xc41b08 == ECTools._0x0b0492(_0xf8c356, _0x8ee06f));

         // Check the oldState is in the root hash
         require(_0xd3d56e(_0xf8c356, _0x1a61e2, Channels[_0x80e22b].VCrootHash) == true);

         _0xfe3dc7[_0x5db868]._0x0db2d4 = _0xc41b08; // VC participant A
         _0xfe3dc7[_0x5db868]._0x74588d = _0x6981b4; // VC participant B
         _0xfe3dc7[_0x5db868]._0xa1e930 = uint256(0);
         _0xfe3dc7[_0x5db868]._0x33ffb0[0] = _0x638642[0];
         _0xfe3dc7[_0x5db868]._0x33ffb0[1] = _0x638642[1];
         _0xfe3dc7[_0x5db868]._0x7958d2[0] = _0x638642[2];
         _0xfe3dc7[_0x5db868]._0x7958d2[1] = _0x638642[3];
         _0xfe3dc7[_0x5db868]._0xd57a30 = _0x9fb9fb;
         _0xfe3dc7[_0x5db868]._0xfba4e5 = _0x75c146 + Channels[_0x80e22b]._0x4d4c0a;
         _0xfe3dc7[_0x5db868]._0xb28295 = true;

         emit DidVCInit(_0x80e22b, _0x5db868, _0x1a61e2, uint256(0), _0xc41b08, _0x6981b4, _0x638642[0], _0x638642[1]);
     }

     //TODO: verify state transition since the hub did not agree to this state
     // make sure the A/B balances are not beyond ingrids bonds
     // Params: vc init state, vc final balance, vcID
     function _0x189945(
         bytes32 _0x80e22b,
         bytes32 _0x5db868,
         uint256 _0x454d08,
         address _0xc41b08,
         address _0x6981b4,
         uint256[4] _0x23a165, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
         string _0x8ee06f
     )
         public
     {
         require(Channels[_0x80e22b]._0xf68155, "LC is closed.");
         // sub-channel must be open
         require(!_0xfe3dc7[_0x5db868]._0x941e28, "VC is closed.");
         require(_0xfe3dc7[_0x5db868]._0xa1e930 < _0x454d08, "VC sequence is higher than update sequence.");
         require(
             _0xfe3dc7[_0x5db868]._0x33ffb0[1] < _0x23a165[1] && _0xfe3dc7[_0x5db868]._0x7958d2[1] < _0x23a165[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0xfe3dc7[_0x5db868]._0xd57a30[0] == _0x23a165[0] + _0x23a165[1] &&
             _0xfe3dc7[_0x5db868]._0xd57a30[1] == _0x23a165[2] + _0x23a165[3],
             "Incorrect balances for bonded amount");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
         // fail if initVC() isn't called first
         // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
         require(Channels[_0x80e22b]._0x5d1e89 < _0x75c146); // for testing!

         bytes32 _0xba447c = _0x1d7afd(
             abi._0x7946b2(
                 _0x5db868,
                 _0x454d08,
                 _0xc41b08,
                 _0x6981b4,
                 _0xfe3dc7[_0x5db868]._0xd57a30[0],
                 _0xfe3dc7[_0x5db868]._0xd57a30[1],
                 _0x23a165[0],
                 _0x23a165[1],
                 _0x23a165[2],
                 _0x23a165[3]
             )
         );

         // Make sure Alice has signed a higher sequence new state
         require(_0xfe3dc7[_0x5db868]._0x0db2d4 == ECTools._0x0b0492(_0xba447c, _0x8ee06f));

         // store VC data
         // we may want to record who is initiating on-chain settles
         _0xfe3dc7[_0x5db868]._0xd1ec16 = msg.sender;
         _0xfe3dc7[_0x5db868]._0xa1e930 = _0x454d08;

         // channel state
         _0xfe3dc7[_0x5db868]._0x33ffb0[0] = _0x23a165[0];
         _0xfe3dc7[_0x5db868]._0x33ffb0[1] = _0x23a165[1];
         _0xfe3dc7[_0x5db868]._0x7958d2[0] = _0x23a165[2];
         _0xfe3dc7[_0x5db868]._0x7958d2[1] = _0x23a165[3];

         _0xfe3dc7[_0x5db868]._0xfba4e5 = _0x75c146 + Channels[_0x80e22b]._0x4d4c0a;

         emit DidVCSettle(_0x80e22b, _0x5db868, _0x454d08, _0x23a165[0], _0x23a165[1], msg.sender, _0xfe3dc7[_0x5db868]._0xfba4e5);
     }

     function _0xbc399c(bytes32 _0x80e22b, bytes32 _0x5db868) public {
         // require(updateLCtimeout > now)
         require(Channels[_0x80e22b]._0xf68155, "LC is closed.");
         require(_0xfe3dc7[_0x5db868]._0xb28295, "VC is not in settlement state.");
         require(_0xfe3dc7[_0x5db868]._0xfba4e5 < _0x75c146, "Update vc timeout has not elapsed.");
         require(!_0xfe3dc7[_0x5db868]._0x941e28, "VC is already closed");
         // reduce the number of open virtual channels stored on LC
         Channels[_0x80e22b]._0xf98110--;
         // close vc flags
         _0xfe3dc7[_0x5db868]._0x941e28 = true;
         // re-introduce the balances back into the LC state from the settled VC
         // decide if this lc is alice or bob in the vc
         if(_0xfe3dc7[_0x5db868]._0x0db2d4 == Channels[_0x80e22b]._0xc63ab5[0]) {
             Channels[_0x80e22b]._0x33ffb0[0] += _0xfe3dc7[_0x5db868]._0x33ffb0[0];
             Channels[_0x80e22b]._0x33ffb0[1] += _0xfe3dc7[_0x5db868]._0x33ffb0[1];

             Channels[_0x80e22b]._0x7958d2[0] += _0xfe3dc7[_0x5db868]._0x7958d2[0];
             Channels[_0x80e22b]._0x7958d2[1] += _0xfe3dc7[_0x5db868]._0x7958d2[1];
         } else if (_0xfe3dc7[_0x5db868]._0x74588d == Channels[_0x80e22b]._0xc63ab5[0]) {
             Channels[_0x80e22b]._0x33ffb0[0] += _0xfe3dc7[_0x5db868]._0x33ffb0[1];
             Channels[_0x80e22b]._0x33ffb0[1] += _0xfe3dc7[_0x5db868]._0x33ffb0[0];

             Channels[_0x80e22b]._0x7958d2[0] += _0xfe3dc7[_0x5db868]._0x7958d2[1];
             Channels[_0x80e22b]._0x7958d2[1] += _0xfe3dc7[_0x5db868]._0x7958d2[0];
         }

         emit DidVCClose(_0x80e22b, _0x5db868, _0xfe3dc7[_0x5db868]._0x7958d2[0], _0xfe3dc7[_0x5db868]._0x7958d2[1]);
     }

     // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
     function _0xbb69d5(bytes32 _0x80e22b) public {
         Channel storage _0xcdd2dc = Channels[_0x80e22b];

         // check settlement flag
         require(_0xcdd2dc._0xf68155, "Channel is not open");
         require(_0xcdd2dc._0xd1e492 == true);
         require(_0xcdd2dc._0xf98110 == 0);
         require(_0xcdd2dc._0x5d1e89 < _0x75c146, "LC timeout over.");

         // if off chain state update didnt reblance deposits, just return to deposit owner
         uint256 _0x4e2101 = _0xcdd2dc._0x3f5ecf[0] + _0xcdd2dc._0x33ffb0[2] + _0xcdd2dc._0x33ffb0[3];
         uint256 _0xf6f5f1 = _0xcdd2dc._0x3f5ecf[1] + _0xcdd2dc._0x7958d2[2] + _0xcdd2dc._0x7958d2[3];

         uint256 _0x8aa15c = _0xcdd2dc._0x33ffb0[0] + _0xcdd2dc._0x33ffb0[1];
         uint256 _0x2a96ce = _0xcdd2dc._0x7958d2[0] + _0xcdd2dc._0x7958d2[1];

         if(_0x8aa15c < _0x4e2101) {
             _0xcdd2dc._0x33ffb0[0]+=_0xcdd2dc._0x33ffb0[2];
             _0xcdd2dc._0x33ffb0[1]+=_0xcdd2dc._0x33ffb0[3];
         } else {
             require(_0x8aa15c == _0x4e2101);
         }

         if(_0x2a96ce < _0xf6f5f1) {
             _0xcdd2dc._0x7958d2[0]+=_0xcdd2dc._0x7958d2[2];
             _0xcdd2dc._0x7958d2[1]+=_0xcdd2dc._0x7958d2[3];
         } else {
             require(_0x2a96ce == _0xf6f5f1);
         }

         uint256 _0xd14fdf = _0xcdd2dc._0x33ffb0[0];
         uint256 _0xcc4f63 = _0xcdd2dc._0x33ffb0[1];
         uint256 _0xb2c9df = _0xcdd2dc._0x7958d2[0];
         uint256 _0xb6c131 = _0xcdd2dc._0x7958d2[1];

         _0xcdd2dc._0x33ffb0[0] = 0;
         _0xcdd2dc._0x33ffb0[1] = 0;
         _0xcdd2dc._0x7958d2[0] = 0;
         _0xcdd2dc._0x7958d2[1] = 0;

         if(_0xd14fdf != 0 || _0xcc4f63 != 0) {
             _0xcdd2dc._0xc63ab5[0].transfer(_0xd14fdf);
             _0xcdd2dc._0xc63ab5[1].transfer(_0xcc4f63);
         }

         if(_0xb2c9df != 0 || _0xb6c131 != 0) {
             require(
                 _0xcdd2dc._0xfab703.transfer(_0xcdd2dc._0xc63ab5[0], _0xb2c9df),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0xcdd2dc._0xfab703.transfer(_0xcdd2dc._0xc63ab5[1], _0xb6c131),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0xcdd2dc._0xf68155 = false;
         _0xc692b1--;

         emit DidLCClose(_0x80e22b, _0xcdd2dc._0xa1e930, _0xd14fdf, _0xcc4f63, _0xb2c9df, _0xb6c131);
     }

     function _0xd3d56e(bytes32 _0x52ac86, bytes _0x1a61e2, bytes32 _0xb6284d) internal pure returns (bool) {
         bytes32 _0x5e8107 = _0x52ac86;
         bytes32 _0xcac0ea;

         for (uint256 i = 64; i <= _0x1a61e2.length; i += 32) {
             assembly { _0xcac0ea := mload(add(_0x1a61e2, i)) }

             if (_0x5e8107 < _0xcac0ea) {
                 if (block.timestamp > 0) { _0x5e8107 = _0x1d7afd(abi._0x7946b2(_0x5e8107, _0xcac0ea)); }
             } else {
                 _0x5e8107 = _0x1d7afd(abi._0x7946b2(_0xcac0ea, _0x5e8107));
             }
         }

         return _0x5e8107 == _0xb6284d;
     }

     //Struct Getters
     function _0x1dc169(bytes32 _0xff0402) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         Channel memory _0xcdd2dc = Channels[_0xff0402];
         return (
             _0xcdd2dc._0xc63ab5,
             _0xcdd2dc._0x33ffb0,
             _0xcdd2dc._0x7958d2,
             _0xcdd2dc._0x3f5ecf,
             _0xcdd2dc._0xa1e930,
             _0xcdd2dc._0x4d4c0a,
             _0xcdd2dc.VCrootHash,
             _0xcdd2dc.LCopenTimeout,
             _0xcdd2dc._0x5d1e89,
             _0xcdd2dc._0xf68155,
             _0xcdd2dc._0xd1e492,
             _0xcdd2dc._0xf98110
         );
     }

     function _0x3a6818(bytes32 _0xff0402) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory _0x63ef33 = _0xfe3dc7[_0xff0402];
         return(
             _0x63ef33._0x941e28,
             _0x63ef33._0xb28295,
             _0x63ef33._0xa1e930,
             _0x63ef33._0xd1ec16,
             _0x63ef33._0xfba4e5,
             _0x63ef33._0x0db2d4,
             _0x63ef33._0x74588d,
             _0x63ef33._0xa3d1d8,
             _0x63ef33._0x33ffb0,
             _0x63ef33._0x7958d2,
             _0x63ef33._0xd57a30
         );
     }
 }
