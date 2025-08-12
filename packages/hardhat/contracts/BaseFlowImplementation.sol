// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./BaseFlowCore.sol";

/**
 * @title BaseFlowImplementation
 * @dev implementation of the BaseFlowCore abstract contract
 * This contract is used for deployment while inheriting all functionality from BaseFlowCore
 */
contract BaseFlowImplementation is BaseFlowCore {
    /**
     * @dev Constructor that initializes the contract with the USDC token address
     * @param _usdc Address of the USDC token contract
     */
    constructor(address _usdc) BaseFlowCore(_usdc) {}
}