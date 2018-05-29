pragma solidity ^0.4.21;

//libraries import
import './Pausable.sol';
import './EIP20.sol';

/**
* Contract for DEX admin to add/remove ERC20 token
* Owner can also create new ERC20 token
*/


contract AdminAndERC20Dispatcher is Ownable,Pausable {

  //array used to hold existing ERC20 token
  
  //structure used to hold valid/unvalid bool for added token
  
  struct ExistingTokenStruct {
      
      bool isActive;
      
  }
  
  
  struct NewERC20TokenStruct {
      
      uint256 initialAmount;
      string tokenName;
      uint8 decimalUnits;
      string tokenSymbol;
      //ipfs hash for token icon to be added later
      bool isActive;
      
  }
  
  address[] public AddExistingTokenAddress;
  
  address[] public AddNewERC20TokenAddress;
  
  
  mapping (address => ExistingTokenStruct) AddExistingTokenStruct;
  
  mapping (address => NewERC20TokenStruct) AddNewERC20TokenStruct;
  
  //function used to add existing token
  
  function addExistingToken(address _tokenAddress) whenNotPaused onlyOwner public {
      
      ExistingTokenStruct new_token = AddExistingTokenStruct[_tokenAddress];
      
      //need to check weather token is already added, if true then do nothing
      //otherwise add it and include it in array
      if(new_token.isActive == true){
          revert();
      }else{
          new_token.isActive = true;
          AddExistingTokenAddress.push(_tokenAddress);
      }
      
  }
  
  function removeExistingToken(address _tokenAddress) whenNotPaused onlyOwner public {
      
      //do isActive false, that's all
      
      ExistingTokenStruct old_token = AddExistingTokenStruct[_tokenAddress];
      
      old_token.isActive = false;
      
  }
  
  //function to add new ERC20 token
  
  
  function createERC20Token(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) whenNotPaused onlyOwner public {
      
      //We will create erc20 token and will add in our mapping AddNewERC20TokenStruct
      //create new erc20 token
      EIP20 new_token = new EIP20(_initialAmount, _tokenName, _decimalUnits, _tokenSymbol, owner);
      
      NewERC20TokenStruct new_token_meta = AddNewERC20TokenStruct[address(new_token)];
      
      new_token_meta.initialAmount = _initialAmount;
      new_token_meta.tokenName = _tokenName;
      new_token_meta.decimalUnits = _decimalUnits;
      new_token_meta.tokenSymbol = _tokenSymbol;
      new_token_meta.isActive = true;
      
      //store same address inside array too
      AddNewERC20TokenAddress.push(address(new_token));
      
  }
  
  //function to disable existing erc20 token
  function removeERC20Token(address _tokenAddress) whenNotPaused onlyOwner public {
      
      NewERC20TokenStruct old_token_meta = AddNewERC20TokenStruct[_tokenAddress];
      
      old_token_meta.isActive = false;
      
  }
  
  
  
  function showAllTokens () whenNotPaused public returns (address[], address[]) {
      
      //throw array from here
      return (AddExistingTokenAddress, AddNewERC20TokenAddress);
      
  }
  
  function showExistingTokenStatus (address _tokenAddress) public returns (address, bool) {
      
      return(_tokenAddress, AddExistingTokenStruct[_tokenAddress].isActive);
      
  }
  
  function showNewTokenStatus (address _tokenAddress) public returns (address, bool) {
      
      return (_tokenAddress, AddNewERC20TokenStruct[_tokenAddress].isActive);
      
  }

  /*
    function to kill contract
  */

  function kill() onlyOwner {
    selfdestruct(owner);
  }

  /*
    transfer eth recived to owner account if any
  */
  function() payable {
    owner.transfer(msg.value);
  }

}
