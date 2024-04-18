// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.2;


contract MkErc20 {
    string public name = 'My token';
    string public symbol = '$';
    uint8 public decimals = 4;
    uint256 public totalSupply;
    mapping(address=>uint256) public balanceOf;

    constructor (uint totalAmount) {
        balanceOf[msg.sender] = totalAmount;
        totalSupply = totalAmount;
    }

    function transfer(address to, uint256 amount) public returns(bool){
        address from = msg.sender;
        uint256 fromb = balanceOf[from];
        uint256 tob = balanceOf[to];
        balanceOf[from] = fromb - amount;
        balanceOf[to] = tob + amount;
        return true;
    }
}