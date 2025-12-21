 pragma solidity ^0.4.23;
 // produced by the Solididy File Flattener (c) David Appleton 2018
 // contact : dave@akomba.com
 // released under Apache 2.0 licence
 contract Token {
     /// total amount of tokens
     uint256 public _0x02207d;

     /// @param _owner The address from which the balance will be retrieved
     /// @return The balance
     function _0x7a50f5(address _0xb4f020) public constant returns (uint256 balance);

     /// @notice send `_value` token to `_to` from `msg.sender`
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function transfer(address _0xc5cf7b, uint256 _0xe31c93) public returns (bool _0x6b2fb3);

     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function _0x35dcd4(address _0x71cb94, address _0xc5cf7b, uint256 _0xe31c93) public returns (bool _0x6b2fb3);

     /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @param _value The amount of tokens to be approved for transfer
     /// @return Whether the approval was successful or not
     function _0x690a18(address _0x1b0bcc, uint256 _0xe31c93) public returns (bool _0x6b2fb3);

     /// @param _owner The address of the account owning tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent
     function _0xb017a9(address _0xb4f020, address _0x1b0bcc) public constant returns (uint256 _0x1c6162);

     event Transfer(address indexed _0x71cb94, address indexed _0xc5cf7b, uint256 _0xe31c93);
     event Approval(address indexed _0xb4f020, address indexed _0x1b0bcc, uint256 _0xe31c93);
 }

 library ECTools {

     // @dev Recovers the address which has signed a message
     // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
     function _0x36c534(bytes32 _0x07c3e8, string _0xd8a0f9) public pure returns (address) {
         require(_0x07c3e8 != 0x00);

         // need this for test RPC
         bytes memory _0x5c0dab = "\x19Ethereum Signed Message:\n32";
         bytes32 _0xe9a200 = _0x354166(abi._0x842403(_0x5c0dab, _0x07c3e8));

         if (bytes(_0xd8a0f9).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0xf8e8a7(_0x8c2ec7(_0xd8a0f9, 2, 132));
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
         return _0xe0d60c(_0xe9a200, v, r, s);
     }

     // @dev Verifies if the message is signed by an address
     function _0x56e8de(bytes32 _0x07c3e8, string _0xd8a0f9, address _0x416348) public pure returns (bool) {
         require(_0x416348 != 0x0);

         return _0x416348 == _0x36c534(_0x07c3e8, _0xd8a0f9);
     }

     // @dev Converts an hexstring to bytes
     function _0xf8e8a7(string _0x3992a6) public pure returns (bytes) {
         uint _0x28caa3 = bytes(_0x3992a6).length;
         require(_0x28caa3 % 2 == 0);

         bytes memory _0x024712 = bytes(new string(_0x28caa3 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0x28caa3; i += 2) {
             s = _0x8c2ec7(_0x3992a6, i, i + 1);
             if (true) { r = _0x8c2ec7(_0x3992a6, i + 1, i + 2); }
             uint p = _0xd1c3ce(s) * 16 + _0xd1c3ce(r);
             _0x024712[k++] = _0x5d1d19(p)[31];
         }
         return _0x024712;
     }

     // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
     function _0xd1c3ce(string _0x90ccd7) public pure returns (uint) {
         bytes memory _0x0da552 = bytes(_0x90ccd7);
         // bool decimals = false;
         if ((_0x0da552[0] >= 48) && (_0x0da552[0] <= 57)) {
             return uint(_0x0da552[0]) - 48;
         } else if ((_0x0da552[0] >= 65) && (_0x0da552[0] <= 70)) {
             return uint(_0x0da552[0]) - 55;
         } else if ((_0x0da552[0] >= 97) && (_0x0da552[0] <= 102)) {
             return uint(_0x0da552[0]) - 87;
         } else {
             revert();
         }
     }

     // @dev Converts a uint to a bytes32
     // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
     function _0x5d1d19(uint _0x7c1381) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0x7c1381)}
     }

     // @dev Hashes the signed message
     // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
     function _0x91e02f(string _0x91307e) public pure returns (bytes32) {
         uint _0x28caa3 = bytes(_0x91307e).length;
         require(_0x28caa3 > 0);
         bytes memory _0x5c0dab = "\x19Ethereum Signed Message:\n";
         return _0x354166(abi._0x842403(_0x5c0dab, _0x4c3d7f(_0x28caa3), _0x91307e));
     }

     // @dev Converts a uint in a string
     function _0x4c3d7f(uint _0x7c1381) public pure returns (string _0x844b68) {
         uint _0x28caa3 = 0;
         uint m = _0x7c1381 + 0;
         while (m != 0) {
             _0x28caa3++;
             m /= 10;
         }
         bytes memory b = new bytes(_0x28caa3);
         uint i = _0x28caa3 - 1;
         while (_0x7c1381 != 0) {
             uint _0x78b69b = _0x7c1381 % 10;
             _0x7c1381 = _0x7c1381 / 10;
             b[i--] = byte(48 + _0x78b69b);
         }
         _0x844b68 = string(b);
     }

     // @dev extract a substring
     // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
     function _0x8c2ec7(string _0x08a039, uint _0xeac617, uint _0x9f50dc) public pure returns (string) {
         bytes memory _0x2dd11e = bytes(_0x08a039);
         require(_0xeac617 <= _0x9f50dc);
         require(_0xeac617 >= 0);
         require(_0x9f50dc <= _0x2dd11e.length);

         bytes memory _0x7d72af = new bytes(_0x9f50dc - _0xeac617);
         for (uint i = _0xeac617; i < _0x9f50dc; i++) {
             _0x7d72af[i - _0xeac617] = _0x2dd11e[i];
         }
         return string(_0x7d72af);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0xc5cf7b, uint256 _0xe31c93) public returns (bool _0x6b2fb3) {
         //Default assumes totalSupply can't be over max (2^256 - 1).
         //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
         //Replace the if with this one instead.
         //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x78ae25[msg.sender] >= _0xe31c93);
         _0x78ae25[msg.sender] -= _0xe31c93;
         _0x78ae25[_0xc5cf7b] += _0xe31c93;
         emit Transfer(msg.sender, _0xc5cf7b, _0xe31c93);
         return true;
     }

     function _0x35dcd4(address _0x71cb94, address _0xc5cf7b, uint256 _0xe31c93) public returns (bool _0x6b2fb3) {

         //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x78ae25[_0x71cb94] >= _0xe31c93 && _0xa6fcf6[_0x71cb94][msg.sender] >= _0xe31c93);
         _0x78ae25[_0xc5cf7b] += _0xe31c93;
         _0x78ae25[_0x71cb94] -= _0xe31c93;
         _0xa6fcf6[_0x71cb94][msg.sender] -= _0xe31c93;
         emit Transfer(_0x71cb94, _0xc5cf7b, _0xe31c93);
         return true;
     }

     function _0x7a50f5(address _0xb4f020) public constant returns (uint256 balance) {
         return _0x78ae25[_0xb4f020];
     }

     function _0x690a18(address _0x1b0bcc, uint256 _0xe31c93) public returns (bool _0x6b2fb3) {
         _0xa6fcf6[msg.sender][_0x1b0bcc] = _0xe31c93;
         emit Approval(msg.sender, _0x1b0bcc, _0xe31c93);
         return true;
     }

     function _0xb017a9(address _0xb4f020, address _0x1b0bcc) public constant returns (uint256 _0x1c6162) {
       return _0xa6fcf6[_0xb4f020][_0x1b0bcc];
     }

     mapping (address => uint256) _0x78ae25;
     mapping (address => mapping (address => uint256)) _0xa6fcf6;
 }

 contract HumanStandardToken is StandardToken {

     /* Public variables of the token */

     string public _0x55ea72;                   //fancy name: eg Simon Bucks
     uint8 public _0x838205;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
     string public _0x2c3769;                 //An identifier: eg SBX
     string public _0x57364e = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

     constructor(
         uint256 _0xeef467,
         string _0x9a46e2,
         uint8 _0x71ea5b,
         string _0x076092
         ) public {
         _0x78ae25[msg.sender] = _0xeef467;               // Give the creator all initial tokens
         _0x02207d = _0xeef467;                        // Update total supply
         _0x55ea72 = _0x9a46e2;                                   // Set the name for display purposes
         _0x838205 = _0x71ea5b;                            // Amount of decimals for display purposes
         _0x2c3769 = _0x076092;                               // Set the symbol for display purposes
     }

     /* Approves and then calls the receiving contract */
     function _0x60df2d(address _0x1b0bcc, uint256 _0xe31c93, bytes _0x1558f0) public returns (bool _0x6b2fb3) {
         _0xa6fcf6[msg.sender][_0x1b0bcc] = _0xe31c93;
         emit Approval(msg.sender, _0x1b0bcc, _0xe31c93);

         //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
         //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
         //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
         require(_0x1b0bcc.call(bytes4(bytes32(_0x354166("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xe31c93, this, _0x1558f0));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0x0a667c = 0;

     event DidLCOpen (
         bytes32 indexed _0xa277f6,
         address indexed _0x91cc8a,
         address indexed _0x50755e,
         uint256 _0x209ee3,
         address _0x13c0e2,
         uint256 _0xa95854,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0xa277f6,
         uint256 _0x874872,
         uint256 _0x65ec63
     );

     event DidLCDeposit (
         bytes32 indexed _0xa277f6,
         address indexed _0x8a85f1,
         uint256 _0x27425e,
         bool _0x3dac84
     );

     event DidLCUpdateState (
         bytes32 indexed _0xa277f6,
         uint256 _0x48d586,
         uint256 _0xa1a04f,
         uint256 _0x209ee3,
         uint256 _0xa95854,
         uint256 _0x874872,
         uint256 _0x65ec63,
         bytes32 _0x1ecc33,
         uint256 _0x6414e0
     );

     event DidLCClose (
         bytes32 indexed _0xa277f6,
         uint256 _0x48d586,
         uint256 _0x209ee3,
         uint256 _0xa95854,
         uint256 _0x874872,
         uint256 _0x65ec63
     );

     event DidVCInit (
         bytes32 indexed _0xbbccb2,
         bytes32 indexed _0xde097c,
         bytes _0x717efe,
         uint256 _0x48d586,
         address _0x91cc8a,
         address _0x492a2c,
         uint256 _0x03d9a2,
         uint256 _0xead306
     );

     event DidVCSettle (
         bytes32 indexed _0xbbccb2,
         bytes32 indexed _0xde097c,
         uint256 _0xdd9462,
         uint256 _0xc5246a,
         uint256 _0x3e4ce4,
         address _0xf96c00,
         uint256 _0xd7a676
     );

     event DidVCClose(
         bytes32 indexed _0xbbccb2,
         bytes32 indexed _0xde097c,
         uint256 _0x03d9a2,
         uint256 _0xead306
     );

     struct Channel {
         //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
         address[2] _0xfed937; // 0: partyA 1: partyI
         uint256[4] _0x2ced75; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[4] _0x35c8db; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[2] _0xc6186d; // 0: eth 1: tokens
         uint256 _0x48d586;
         uint256 _0x7068e6;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0x6414e0; // when update LC times out
         bool _0x3e7c34; // true when both parties have joined
         bool _0xed157b;
         uint256 _0x45a45a;
         HumanStandardToken _0x13c0e2;
     }

     // virtual-channel state
     struct VirtualChannel {
         bool _0xfe28f1;
         bool _0xa2c5f7;
         uint256 _0x48d586;
         address _0xf96c00; // Initiator of challenge
         uint256 _0xd7a676; // when update VC times out
         // channel state
         address _0x91cc8a; // VC participant A
         address _0x492a2c; // VC participant B
         address _0x50755e; // LC hub
         uint256[2] _0x2ced75;
         uint256[2] _0x35c8db;
         uint256[2] _0x7d02d9;
         HumanStandardToken _0x13c0e2;
     }

     mapping(bytes32 => VirtualChannel) public _0x6b9c65;
     mapping(bytes32 => Channel) public Channels;

     function _0xd04f38(
         bytes32 _0xf6fc4f,
         address _0x04b590,
         uint256 _0x66a453,
         address _0xcb7d91,
         uint256[2] _0x0af9e8 // [eth, token]
     )
         public
         payable
     {
         require(Channels[_0xf6fc4f]._0xfed937[0] == address(0), "Channel has already been created.");
         require(_0x04b590 != 0x0, "No partyI address provided to LC creation");
         require(_0x0af9e8[0] >= 0 && _0x0af9e8[1] >= 0, "Balances cannot be negative");
         // Set initial ledger channel state
         // Alice must execute this and we assume the initial state
         // to be signed from this requirement
         // Alternative is to check a sig as in joinChannel
         Channels[_0xf6fc4f]._0xfed937[0] = msg.sender;
         Channels[_0xf6fc4f]._0xfed937[1] = _0x04b590;

         if(_0x0af9e8[0] != 0) {
             require(msg.value == _0x0af9e8[0], "Eth balance does not match sent value");
             Channels[_0xf6fc4f]._0x2ced75[0] = msg.value;
         }
         if(_0x0af9e8[1] != 0) {
             Channels[_0xf6fc4f]._0x13c0e2 = HumanStandardToken(_0xcb7d91);
             require(Channels[_0xf6fc4f]._0x13c0e2._0x35dcd4(msg.sender, this, _0x0af9e8[1]),"CreateChannel: token transfer failure");
             Channels[_0xf6fc4f]._0x35c8db[0] = _0x0af9e8[1];
         }

         Channels[_0xf6fc4f]._0x48d586 = 0;
         Channels[_0xf6fc4f]._0x7068e6 = _0x66a453;
         // is close flag, lc state sequence, number open vc, vc root hash, partyA...
         //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
         Channels[_0xf6fc4f].LCopenTimeout = _0x6bab64 + _0x66a453;
         Channels[_0xf6fc4f]._0xc6186d = _0x0af9e8;

         emit DidLCOpen(_0xf6fc4f, msg.sender, _0x04b590, _0x0af9e8[0], _0xcb7d91, _0x0af9e8[1], Channels[_0xf6fc4f].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0xf6fc4f) public {
         require(msg.sender == Channels[_0xf6fc4f]._0xfed937[0] && Channels[_0xf6fc4f]._0x3e7c34 == false);
         require(_0x6bab64 > Channels[_0xf6fc4f].LCopenTimeout);

         if(Channels[_0xf6fc4f]._0xc6186d[0] != 0) {
             Channels[_0xf6fc4f]._0xfed937[0].transfer(Channels[_0xf6fc4f]._0x2ced75[0]);
         }
         if(Channels[_0xf6fc4f]._0xc6186d[1] != 0) {
             require(Channels[_0xf6fc4f]._0x13c0e2.transfer(Channels[_0xf6fc4f]._0xfed937[0], Channels[_0xf6fc4f]._0x35c8db[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0xf6fc4f, 0, Channels[_0xf6fc4f]._0x2ced75[0], Channels[_0xf6fc4f]._0x35c8db[0], 0, 0);

         // only safe to delete since no action was taken on this channel
         delete Channels[_0xf6fc4f];
     }

     function _0xfa85d4(bytes32 _0xf6fc4f, uint256[2] _0x0af9e8) public payable {
         // require the channel is not open yet
         require(Channels[_0xf6fc4f]._0x3e7c34 == false);
         require(msg.sender == Channels[_0xf6fc4f]._0xfed937[1]);

         if(_0x0af9e8[0] != 0) {
             require(msg.value == _0x0af9e8[0], "state balance does not match sent value");
             Channels[_0xf6fc4f]._0x2ced75[1] = msg.value;
         }
         if(_0x0af9e8[1] != 0) {
             require(Channels[_0xf6fc4f]._0x13c0e2._0x35dcd4(msg.sender, this, _0x0af9e8[1]),"joinChannel: token transfer failure");
             Channels[_0xf6fc4f]._0x35c8db[1] = _0x0af9e8[1];
         }

         Channels[_0xf6fc4f]._0xc6186d[0]+=_0x0af9e8[0];
         Channels[_0xf6fc4f]._0xc6186d[1]+=_0x0af9e8[1];
         // no longer allow joining functions to be called
         Channels[_0xf6fc4f]._0x3e7c34 = true;
         _0x0a667c++;

         emit DidLCJoin(_0xf6fc4f, _0x0af9e8[0], _0x0af9e8[1]);
     }

     // additive updates of monetary state
     function _0x27425e(bytes32 _0xf6fc4f, address _0x8a85f1, uint256 _0x7374ac, bool _0x3dac84) public payable {
         require(Channels[_0xf6fc4f]._0x3e7c34 == true, "Tried adding funds to a closed channel");
         require(_0x8a85f1 == Channels[_0xf6fc4f]._0xfed937[0] || _0x8a85f1 == Channels[_0xf6fc4f]._0xfed937[1]);

         //if(Channels[_lcID].token)

         if (Channels[_0xf6fc4f]._0xfed937[0] == _0x8a85f1) {
             if(_0x3dac84) {
                 require(Channels[_0xf6fc4f]._0x13c0e2._0x35dcd4(msg.sender, this, _0x7374ac),"deposit: token transfer failure");
                 Channels[_0xf6fc4f]._0x35c8db[2] += _0x7374ac;
             } else {
                 require(msg.value == _0x7374ac, "state balance does not match sent value");
                 Channels[_0xf6fc4f]._0x2ced75[2] += msg.value;
             }
         }

         if (Channels[_0xf6fc4f]._0xfed937[1] == _0x8a85f1) {
             if(_0x3dac84) {
                 require(Channels[_0xf6fc4f]._0x13c0e2._0x35dcd4(msg.sender, this, _0x7374ac),"deposit: token transfer failure");
                 Channels[_0xf6fc4f]._0x35c8db[3] += _0x7374ac;
             } else {
                 require(msg.value == _0x7374ac, "state balance does not match sent value");
                 Channels[_0xf6fc4f]._0x2ced75[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0xf6fc4f, _0x8a85f1, _0x7374ac, _0x3dac84);
     }

     // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
     function _0xbeebf9(
         bytes32 _0xf6fc4f,
         uint256 _0xfacac8,
         uint256[4] _0x0af9e8, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x6584b2,
         string _0x0280ff
     )
         public
     {
         // assume num open vc is 0 and root hash is 0x0
         //require(Channels[_lcID].sequence < _sequence);
         require(Channels[_0xf6fc4f]._0x3e7c34 == true);
         uint256 _0x553c7e = Channels[_0xf6fc4f]._0xc6186d[0] + Channels[_0xf6fc4f]._0x2ced75[2] + Channels[_0xf6fc4f]._0x2ced75[3];
         uint256 _0xc9da0b = Channels[_0xf6fc4f]._0xc6186d[1] + Channels[_0xf6fc4f]._0x35c8db[2] + Channels[_0xf6fc4f]._0x35c8db[3];
         require(_0x553c7e == _0x0af9e8[0] + _0x0af9e8[1]);
         require(_0xc9da0b == _0x0af9e8[2] + _0x0af9e8[3]);

         bytes32 _0x2b825d = _0x354166(
             abi._0x842403(
                 _0xf6fc4f,
                 true,
                 _0xfacac8,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0xf6fc4f]._0xfed937[0],
                 Channels[_0xf6fc4f]._0xfed937[1],
                 _0x0af9e8[0],
                 _0x0af9e8[1],
                 _0x0af9e8[2],
                 _0x0af9e8[3]
             )
         );

         require(Channels[_0xf6fc4f]._0xfed937[0] == ECTools._0x36c534(_0x2b825d, _0x6584b2));
         require(Channels[_0xf6fc4f]._0xfed937[1] == ECTools._0x36c534(_0x2b825d, _0x0280ff));

         Channels[_0xf6fc4f]._0x3e7c34 = false;

         if(_0x0af9e8[0] != 0 || _0x0af9e8[1] != 0) {
             Channels[_0xf6fc4f]._0xfed937[0].transfer(_0x0af9e8[0]);
             Channels[_0xf6fc4f]._0xfed937[1].transfer(_0x0af9e8[1]);
         }

         if(_0x0af9e8[2] != 0 || _0x0af9e8[3] != 0) {
             require(Channels[_0xf6fc4f]._0x13c0e2.transfer(Channels[_0xf6fc4f]._0xfed937[0], _0x0af9e8[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0xf6fc4f]._0x13c0e2.transfer(Channels[_0xf6fc4f]._0xfed937[1], _0x0af9e8[3]),"happyCloseChannel: token transfer failure");
         }

         _0x0a667c--;

         emit DidLCClose(_0xf6fc4f, _0xfacac8, _0x0af9e8[0], _0x0af9e8[1], _0x0af9e8[2], _0x0af9e8[3]);
     }

     // Byzantine functions

     function _0xf013b1(
         bytes32 _0xf6fc4f,
         uint256[6] _0x257331, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
         bytes32 _0x195ea2,
         string _0x6584b2,
         string _0x0280ff
     )
         public
     {
         Channel storage _0xae40c9 = Channels[_0xf6fc4f];
         require(_0xae40c9._0x3e7c34);
         require(_0xae40c9._0x48d586 < _0x257331[0]); // do same as vc sequence check
         require(_0xae40c9._0x2ced75[0] + _0xae40c9._0x2ced75[1] >= _0x257331[2] + _0x257331[3]);
         require(_0xae40c9._0x35c8db[0] + _0xae40c9._0x35c8db[1] >= _0x257331[4] + _0x257331[5]);

         if(_0xae40c9._0xed157b == true) {
             require(_0xae40c9._0x6414e0 > _0x6bab64);
         }

         bytes32 _0x2b825d = _0x354166(
             abi._0x842403(
                 _0xf6fc4f,
                 false,
                 _0x257331[0],
                 _0x257331[1],
                 _0x195ea2,
                 _0xae40c9._0xfed937[0],
                 _0xae40c9._0xfed937[1],
                 _0x257331[2],
                 _0x257331[3],
                 _0x257331[4],
                 _0x257331[5]
             )
         );

         require(_0xae40c9._0xfed937[0] == ECTools._0x36c534(_0x2b825d, _0x6584b2));
         require(_0xae40c9._0xfed937[1] == ECTools._0x36c534(_0x2b825d, _0x0280ff));

         // update LC state
         _0xae40c9._0x48d586 = _0x257331[0];
         _0xae40c9._0x45a45a = _0x257331[1];
         _0xae40c9._0x2ced75[0] = _0x257331[2];
         _0xae40c9._0x2ced75[1] = _0x257331[3];
         _0xae40c9._0x35c8db[0] = _0x257331[4];
         _0xae40c9._0x35c8db[1] = _0x257331[5];
         _0xae40c9.VCrootHash = _0x195ea2;
         _0xae40c9._0xed157b = true;
         _0xae40c9._0x6414e0 = _0x6bab64 + _0xae40c9._0x7068e6;

         // make settlement flag

         emit DidLCUpdateState (
             _0xf6fc4f,
             _0x257331[0],
             _0x257331[1],
             _0x257331[2],
             _0x257331[3],
             _0x257331[4],
             _0x257331[5],
             _0x195ea2,
             _0xae40c9._0x6414e0
         );
     }

     // supply initial state of VC to "prime" the force push game
     function _0x9de65b(
         bytes32 _0xf6fc4f,
         bytes32 _0xd0a9df,
         bytes _0x496979,
         address _0x54b27f,
         address _0x7b5e17,
         uint256[2] _0x8f95ea,
         uint256[4] _0x0af9e8, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x99bb39
     )
         public
     {
         require(Channels[_0xf6fc4f]._0x3e7c34, "LC is closed.");
         // sub-channel must be open
         require(!_0x6b9c65[_0xd0a9df]._0xfe28f1, "VC is closed.");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         require(Channels[_0xf6fc4f]._0x6414e0 < _0x6bab64, "LC timeout not over.");
         // prevent rentry of initializing vc state
         require(_0x6b9c65[_0xd0a9df]._0xd7a676 == 0);
         // partyB is now Ingrid
         bytes32 _0x36b8e2 = _0x354166(
             abi._0x842403(_0xd0a9df, uint256(0), _0x54b27f, _0x7b5e17, _0x8f95ea[0], _0x8f95ea[1], _0x0af9e8[0], _0x0af9e8[1], _0x0af9e8[2], _0x0af9e8[3])
         );

         // Make sure Alice has signed initial vc state (A/B in oldState)
         require(_0x54b27f == ECTools._0x36c534(_0x36b8e2, _0x99bb39));

         // Check the oldState is in the root hash
         require(_0xd9e0b1(_0x36b8e2, _0x496979, Channels[_0xf6fc4f].VCrootHash) == true);

         _0x6b9c65[_0xd0a9df]._0x91cc8a = _0x54b27f; // VC participant A
         _0x6b9c65[_0xd0a9df]._0x492a2c = _0x7b5e17; // VC participant B
         _0x6b9c65[_0xd0a9df]._0x48d586 = uint256(0);
         _0x6b9c65[_0xd0a9df]._0x2ced75[0] = _0x0af9e8[0];
         _0x6b9c65[_0xd0a9df]._0x2ced75[1] = _0x0af9e8[1];
         _0x6b9c65[_0xd0a9df]._0x35c8db[0] = _0x0af9e8[2];
         _0x6b9c65[_0xd0a9df]._0x35c8db[1] = _0x0af9e8[3];
         _0x6b9c65[_0xd0a9df]._0x7d02d9 = _0x8f95ea;
         _0x6b9c65[_0xd0a9df]._0xd7a676 = _0x6bab64 + Channels[_0xf6fc4f]._0x7068e6;
         _0x6b9c65[_0xd0a9df]._0xa2c5f7 = true;

         emit DidVCInit(_0xf6fc4f, _0xd0a9df, _0x496979, uint256(0), _0x54b27f, _0x7b5e17, _0x0af9e8[0], _0x0af9e8[1]);
     }

     //TODO: verify state transition since the hub did not agree to this state
     // make sure the A/B balances are not beyond ingrids bonds
     // Params: vc init state, vc final balance, vcID
     function _0x9381f9(
         bytes32 _0xf6fc4f,
         bytes32 _0xd0a9df,
         uint256 _0xdd9462,
         address _0x54b27f,
         address _0x7b5e17,
         uint256[4] _0x81798d, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
         string _0x99bb39
     )
         public
     {
         require(Channels[_0xf6fc4f]._0x3e7c34, "LC is closed.");
         // sub-channel must be open
         require(!_0x6b9c65[_0xd0a9df]._0xfe28f1, "VC is closed.");
         require(_0x6b9c65[_0xd0a9df]._0x48d586 < _0xdd9462, "VC sequence is higher than update sequence.");
         require(
             _0x6b9c65[_0xd0a9df]._0x2ced75[1] < _0x81798d[1] && _0x6b9c65[_0xd0a9df]._0x35c8db[1] < _0x81798d[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0x6b9c65[_0xd0a9df]._0x7d02d9[0] == _0x81798d[0] + _0x81798d[1] &&
             _0x6b9c65[_0xd0a9df]._0x7d02d9[1] == _0x81798d[2] + _0x81798d[3],
             "Incorrect balances for bonded amount");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
         // fail if initVC() isn't called first
         // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
         require(Channels[_0xf6fc4f]._0x6414e0 < _0x6bab64); // for testing!

         bytes32 _0xb92127 = _0x354166(
             abi._0x842403(
                 _0xd0a9df,
                 _0xdd9462,
                 _0x54b27f,
                 _0x7b5e17,
                 _0x6b9c65[_0xd0a9df]._0x7d02d9[0],
                 _0x6b9c65[_0xd0a9df]._0x7d02d9[1],
                 _0x81798d[0],
                 _0x81798d[1],
                 _0x81798d[2],
                 _0x81798d[3]
             )
         );

         // Make sure Alice has signed a higher sequence new state
         require(_0x6b9c65[_0xd0a9df]._0x91cc8a == ECTools._0x36c534(_0xb92127, _0x99bb39));

         // store VC data
         // we may want to record who is initiating on-chain settles
         _0x6b9c65[_0xd0a9df]._0xf96c00 = msg.sender;
         _0x6b9c65[_0xd0a9df]._0x48d586 = _0xdd9462;

         // channel state
         _0x6b9c65[_0xd0a9df]._0x2ced75[0] = _0x81798d[0];
         _0x6b9c65[_0xd0a9df]._0x2ced75[1] = _0x81798d[1];
         _0x6b9c65[_0xd0a9df]._0x35c8db[0] = _0x81798d[2];
         _0x6b9c65[_0xd0a9df]._0x35c8db[1] = _0x81798d[3];

         _0x6b9c65[_0xd0a9df]._0xd7a676 = _0x6bab64 + Channels[_0xf6fc4f]._0x7068e6;

         emit DidVCSettle(_0xf6fc4f, _0xd0a9df, _0xdd9462, _0x81798d[0], _0x81798d[1], msg.sender, _0x6b9c65[_0xd0a9df]._0xd7a676);
     }

     function _0xf4789d(bytes32 _0xf6fc4f, bytes32 _0xd0a9df) public {
         // require(updateLCtimeout > now)
         require(Channels[_0xf6fc4f]._0x3e7c34, "LC is closed.");
         require(_0x6b9c65[_0xd0a9df]._0xa2c5f7, "VC is not in settlement state.");
         require(_0x6b9c65[_0xd0a9df]._0xd7a676 < _0x6bab64, "Update vc timeout has not elapsed.");
         require(!_0x6b9c65[_0xd0a9df]._0xfe28f1, "VC is already closed");
         // reduce the number of open virtual channels stored on LC
         Channels[_0xf6fc4f]._0x45a45a--;
         // close vc flags
         _0x6b9c65[_0xd0a9df]._0xfe28f1 = true;
         // re-introduce the balances back into the LC state from the settled VC
         // decide if this lc is alice or bob in the vc
         if(_0x6b9c65[_0xd0a9df]._0x91cc8a == Channels[_0xf6fc4f]._0xfed937[0]) {
             Channels[_0xf6fc4f]._0x2ced75[0] += _0x6b9c65[_0xd0a9df]._0x2ced75[0];
             Channels[_0xf6fc4f]._0x2ced75[1] += _0x6b9c65[_0xd0a9df]._0x2ced75[1];

             Channels[_0xf6fc4f]._0x35c8db[0] += _0x6b9c65[_0xd0a9df]._0x35c8db[0];
             Channels[_0xf6fc4f]._0x35c8db[1] += _0x6b9c65[_0xd0a9df]._0x35c8db[1];
         } else if (_0x6b9c65[_0xd0a9df]._0x492a2c == Channels[_0xf6fc4f]._0xfed937[0]) {
             Channels[_0xf6fc4f]._0x2ced75[0] += _0x6b9c65[_0xd0a9df]._0x2ced75[1];
             Channels[_0xf6fc4f]._0x2ced75[1] += _0x6b9c65[_0xd0a9df]._0x2ced75[0];

             Channels[_0xf6fc4f]._0x35c8db[0] += _0x6b9c65[_0xd0a9df]._0x35c8db[1];
             Channels[_0xf6fc4f]._0x35c8db[1] += _0x6b9c65[_0xd0a9df]._0x35c8db[0];
         }

         emit DidVCClose(_0xf6fc4f, _0xd0a9df, _0x6b9c65[_0xd0a9df]._0x35c8db[0], _0x6b9c65[_0xd0a9df]._0x35c8db[1]);
     }

     // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
     function _0x19f4fe(bytes32 _0xf6fc4f) public {
         Channel storage _0xae40c9 = Channels[_0xf6fc4f];

         // check settlement flag
         require(_0xae40c9._0x3e7c34, "Channel is not open");
         require(_0xae40c9._0xed157b == true);
         require(_0xae40c9._0x45a45a == 0);
         require(_0xae40c9._0x6414e0 < _0x6bab64, "LC timeout over.");

         // if off chain state update didnt reblance deposits, just return to deposit owner
         uint256 _0x553c7e = _0xae40c9._0xc6186d[0] + _0xae40c9._0x2ced75[2] + _0xae40c9._0x2ced75[3];
         uint256 _0xc9da0b = _0xae40c9._0xc6186d[1] + _0xae40c9._0x35c8db[2] + _0xae40c9._0x35c8db[3];

         uint256 _0x507694 = _0xae40c9._0x2ced75[0] + _0xae40c9._0x2ced75[1];
         uint256 _0x16a22c = _0xae40c9._0x35c8db[0] + _0xae40c9._0x35c8db[1];

         if(_0x507694 < _0x553c7e) {
             _0xae40c9._0x2ced75[0]+=_0xae40c9._0x2ced75[2];
             _0xae40c9._0x2ced75[1]+=_0xae40c9._0x2ced75[3];
         } else {
             require(_0x507694 == _0x553c7e);
         }

         if(_0x16a22c < _0xc9da0b) {
             _0xae40c9._0x35c8db[0]+=_0xae40c9._0x35c8db[2];
             _0xae40c9._0x35c8db[1]+=_0xae40c9._0x35c8db[3];
         } else {
             require(_0x16a22c == _0xc9da0b);
         }

         uint256 _0x2e5c54 = _0xae40c9._0x2ced75[0];
         uint256 _0x6168ec = _0xae40c9._0x2ced75[1];
         uint256 _0xc8ba07 = _0xae40c9._0x35c8db[0];
         uint256 _0xb0c428 = _0xae40c9._0x35c8db[1];

         _0xae40c9._0x2ced75[0] = 0;
         _0xae40c9._0x2ced75[1] = 0;
         _0xae40c9._0x35c8db[0] = 0;
         _0xae40c9._0x35c8db[1] = 0;

         if(_0x2e5c54 != 0 || _0x6168ec != 0) {
             _0xae40c9._0xfed937[0].transfer(_0x2e5c54);
             _0xae40c9._0xfed937[1].transfer(_0x6168ec);
         }

         if(_0xc8ba07 != 0 || _0xb0c428 != 0) {
             require(
                 _0xae40c9._0x13c0e2.transfer(_0xae40c9._0xfed937[0], _0xc8ba07),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0xae40c9._0x13c0e2.transfer(_0xae40c9._0xfed937[1], _0xb0c428),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0xae40c9._0x3e7c34 = false;
         _0x0a667c--;

         emit DidLCClose(_0xf6fc4f, _0xae40c9._0x48d586, _0x2e5c54, _0x6168ec, _0xc8ba07, _0xb0c428);
     }

     function _0xd9e0b1(bytes32 _0xf51eee, bytes _0x496979, bytes32 _0x30e58b) internal pure returns (bool) {
         bytes32 _0x997e28 = _0xf51eee;
         bytes32 _0x587a1a;

         for (uint256 i = 64; i <= _0x496979.length; i += 32) {
             assembly { _0x587a1a := mload(add(_0x496979, i)) }

             if (_0x997e28 < _0x587a1a) {
                 _0x997e28 = _0x354166(abi._0x842403(_0x997e28, _0x587a1a));
             } else {
                 _0x997e28 = _0x354166(abi._0x842403(_0x587a1a, _0x997e28));
             }
         }

         return _0x997e28 == _0x30e58b;
     }

     //Struct Getters
     function _0xdc14a4(bytes32 _0xdf6c4a) public view returns (
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
         Channel memory _0xae40c9 = Channels[_0xdf6c4a];
         return (
             _0xae40c9._0xfed937,
             _0xae40c9._0x2ced75,
             _0xae40c9._0x35c8db,
             _0xae40c9._0xc6186d,
             _0xae40c9._0x48d586,
             _0xae40c9._0x7068e6,
             _0xae40c9.VCrootHash,
             _0xae40c9.LCopenTimeout,
             _0xae40c9._0x6414e0,
             _0xae40c9._0x3e7c34,
             _0xae40c9._0xed157b,
             _0xae40c9._0x45a45a
         );
     }

     function _0x7c2950(bytes32 _0xdf6c4a) public view returns(
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
         VirtualChannel memory _0xb9f714 = _0x6b9c65[_0xdf6c4a];
         return(
             _0xb9f714._0xfe28f1,
             _0xb9f714._0xa2c5f7,
             _0xb9f714._0x48d586,
             _0xb9f714._0xf96c00,
             _0xb9f714._0xd7a676,
             _0xb9f714._0x91cc8a,
             _0xb9f714._0x492a2c,
             _0xb9f714._0x50755e,
             _0xb9f714._0x2ced75,
             _0xb9f714._0x35c8db,
             _0xb9f714._0x7d02d9
         );
     }
 }
