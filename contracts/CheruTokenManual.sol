//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/// @title CheruToken - Manual Token Contract without using ERC20
/// @author Sushant Reddy
/// @dev Understanding broad functions that need to be supported in a token contract

contract CheruTokenManual {

    // total token supply
    uint256 public totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals=18;

    // balances in all EOA accounts
    mapping(address => uint256) public balanceOf;

    // balances of contract accounts
    // we are only allowed to spend in a contract if such contract is mapped to allowance table
    mapping(address => mapping(address=>uint256)) public allowance;

    //error for insufficient balance
    error CheruToken__InsufficientBalance(address from, uint256 value);

    //error - wrongly sent to burn address
    error CheruToken__CantBurn(address from, address to, uint256 value);

    // error - overflows
    error CheruToken__TokenOverflow(address from, address to, uint256 value);

    // define a transfer event when there is a actual transfer 
    // from and to address are indexed -  remember, we can index upto 3 variales   
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Approval event triggered whenever approval txn signed by a EOA account
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @dev Burn event triggered whenever tokens are sent for burning from a specific address
    event Burn(address indexed from, uint256 value);


    /**
       * Constructor function initialized token supply, name and symbol 
     */
    constructor (string memory _name, string memory _symbol, uint256 _initialSupply)  {
        totalSupply = _initialSupply * 10**uint256(decimals);
        name = _name;
        symbol = _symbol;

        balanceOf[msg.sender] += totalSupply;
    }


    // transfer tokens
    // deduct tokens from transferor
    // add tokens to transferee
    // transfer tokens from one EOA to another

    /// @notice function to transfer funds from a from address to to address
    /// @dev Check for insufficient balance. Then adjust balanceOf mapping to account for transfer
    
    function _transfer(address _from, address _to, uint256 _value) internal {

          // check if from address exists in balanceOF
          if(balanceOf[_from] < _value){
                revert CheruToken__InsufficientBalance(_from, _value);
          }

          // prevent accidental burning - do that instead, explicitly, with burn function
          if(_to == address(0x0)){
            revert CheruToken__CantBurn(_from, _to, _value);
          }

          // prevent overflows
          if(balanceOf[_to] + _value < balanceOf[_to]){
            revert CheruToken__TokenOverflow(_from, _to, _value);
          }  

          uint256 _balanceBeforeTransfer = balanceOf[_from] + balanceOf[_to]; 

          // check if to address exists in balanaceOf mapping
          // if it doesn't, add it

          balanceOf[_from] -= _value;
          balanceOf[_to] += _value;

          uint256 _balanceAfterTransfer = balanceOf[_from] + balanceOf[_to];
          assert(_balanceBeforeTransfer == _balanceAfterTransfer);
 
          // emit transfer event when there is a transfer  
          emit Transfer(_from, _to, _value);  
    }

    /**
        @dev transfer function transfers tokens to 'to' address
        @param _to beneficiary address
        @param _value tokens to be transferred
     */
    function transfer(address _to, uint256 _value ) public returns(bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    /// @dev transferFrom is to be used for transfering amounts from one contract to an address
    // we check if the contract is approved to send tokens to a beneficiary
    /// @param _from address of the sender (contract)
    /// @param _to address of beneficiary
    /// @param _value transfer amount in wei
    function _transferFrom(address _from, address _to, uint256 _value) public payable returns (bool success) {
        // check if 
        if(allowance[_from][msg.sender] < _value){
            success = false;
            revert CheruToken__InsufficientBalance(_from, _value);            
        }

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        success = true;
    }     

    /**
        * Set allowance for another address
        * Allows spender to spend no more than pre-approved '_value' tokens on your behalf
     */
    /// @dev approve function approves transfer of tokens from sender account
    /// @param _spender address that requires permission to spend tokens
    /// @param _value amount of tokens for which permission is sought
    function _approve(address _spender, uint256 _value) public returns (bool success){
        // this function manages txn signing by a sender acocunt
        // only once txn is signed for approval, can a contract account move funds from account
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;            
    }

    /**
        * Destroy tokens - function burns tokens in a given address

     */
     /// @dev send tokens to a burn address
     /// @param _value - number of tokens to be burnt
     function burn(uint256 _value) public returns(bool success){
        if(balanceOf[msg.sender] < _value){
            revert CheruToken__InsufficientBalance(msg.sender, _value);
        }
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);

        return true;
     }

     /**
        * Function burns tokens in any specific contract
        /// @dev reducing tokens in mapping and total supply
        /// @param _from from current addrress
        /// @param _value amount of tokens to be burnt   
      */
     function burnFrom(address _from, uint256 _value) public  returns(bool success){
        if(balanceOf[_from] < _value){
            revert CheruToken__InsufficientBalance(msg.sender, _value);
        }
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        return true;

     }
}