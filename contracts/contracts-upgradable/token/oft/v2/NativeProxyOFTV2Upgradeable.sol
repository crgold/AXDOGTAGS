// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";
import "./BaseOFTV2Upgradeable.sol";

/**
 * This contract is based on "NativeOFTV2" and "ProxyOFTV2", and takes advantage of
 * the "NativeMinter" Avalanche Subnet precompile to mint and burn native currency
 * on-the-fly instead of locking it up.
 *
 * https://docs.avax.network/build/subnet/upgrade/customize-a-subnet#minting-native-coins
 */

interface INativeMinter {
  function mintNativeCoin(address addr, uint256 amount) external;
}

contract NativeProxyOFTV2Upgradeable is Initializable, BaseOFTV2Upgradeable, Proxied {
    uint internal ld2sdRate;
    uint internal supply;
    INativeMinter internal constant nativeMinter = INativeMinter(address(0x0200000000000000000000000000000000000001));

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint8 _nativeDecimals, uint8 _sharedDecimals, address _lzEndpoint) public initializer {
        __BaseOFTV2Upgradeable_init(_sharedDecimals, _lzEndpoint);

        require(_sharedDecimals <= _nativeDecimals, "NativeMinterOFTV2: sharedDecimals must be <= nativeDecimals");
        ld2sdRate = 10 ** (_nativeDecimals - _sharedDecimals);
    }

    receive() external payable {}

    /************************************************************************
    * public functions
    ************************************************************************/
    function sendFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, LzCallParams calldata _callParams) public payable virtual override {
        _send(_from, _dstChainId, _toAddress, _amount, _callParams.refundAddress, _callParams.zroPaymentAddress, _callParams.adapterParams);
    }

    function sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, LzCallParams calldata _callParams) public payable virtual override {
        _sendAndCall(_from, _dstChainId, _toAddress, _amount, _payload, _dstGasForCall, _callParams.refundAddress, _callParams.zroPaymentAddress, _callParams.adapterParams);
    }

    function token() public view virtual override returns (address) {
        return address(0);
    }

    function circulatingSupply() public view virtual override returns (uint) {
        return supply;
    }

    /************************************************************************
    * internal functions
    ************************************************************************/
    function _send(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) internal virtual override returns (uint amount) {
        _checkAdapterParams(_dstChainId, PT_SEND, _adapterParams, NO_EXTRA_GAS);

        (amount,) = _removeDust(_amount);
        require(amount > 0, "NativeMinterOFTV2: amount too small");
        uint messageFee = _debitFrom(amount);

        bytes memory lzPayload = _encodeSendPayload(_toAddress, _ld2sd(amount));
        _lzSend(_dstChainId, lzPayload, _refundAddress, _zroPaymentAddress, _adapterParams, messageFee);

        emit SendToChain(_dstChainId, _from, _toAddress, amount);
    }

    function _sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes memory _payload, uint64 _dstGasForCall, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) internal virtual override returns (uint amount) {
        _checkAdapterParams(_dstChainId, PT_SEND_AND_CALL, _adapterParams, _dstGasForCall);

        (amount,) = _removeDust(_amount);
        require(amount > 0, "NativeMinterOFTV2: amount too small");
        uint messageFee = _debitFrom(amount);

        // encode the msg.sender into the payload instead of _from
        bytes memory lzPayload = _encodeSendAndCallPayload(msg.sender, _toAddress, _ld2sd(amount), _payload, _dstGasForCall);
        _lzSend(_dstChainId, lzPayload, _refundAddress, _zroPaymentAddress, _adapterParams, messageFee);

        emit SendToChain(_dstChainId, _from, _toAddress, amount);
    }

    function _debitFrom(uint _amount) internal virtual returns (uint) {
        return _debitFrom(address(0), 0, 0x0, _amount);
    }

    function _debitFrom(address, uint16, bytes32, uint _amount) internal virtual override returns (uint messageFee) {
        require(msg.value >= _amount, "NativeMinterOFTV2: Insufficient msg.value");
        // update the messageFee to take out the token amount
        messageFee = msg.value - _amount;

        // burn native tokens
        _burnNative(_amount);

        return messageFee;
    }

    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns (uint) {
        // mint native tokens
        _mintNative(_toAddress, _amount);

        return _amount;
    }

    function _transferFrom(address, address, uint _amount) internal virtual override returns (uint) {
        // native currency is transferred together with this tx already
        return _amount;
    }

    // mints native currency (gas tokens) by calling Avalanche's NativeMinter precompile
    function _mintNative(address _toAddress, uint _amount) internal virtual {
        uint newBalance = msg.sender.balance + _amount;
        nativeMinter.mintNativeCoin(_toAddress, _amount);

        require(msg.sender.balance == newBalance, "NativeMinterOFTV2: Minting native tokens failed.");

        // update tracker
        supply = supply + _amount;
    }

    // burn native tokens
    function _burnNative(uint _amount) internal virtual {
        (bool success, ) = address(0).call{value: _amount}("");

        require(success, "NativeMinterOFTV2: Burning native tokens failed.");

        // update tracker
        supply = supply > _amount ? supply - _amount : 0;
    }

    function _ld2sdRate() internal view virtual override returns (uint) {
        return ld2sdRate;
    }
}