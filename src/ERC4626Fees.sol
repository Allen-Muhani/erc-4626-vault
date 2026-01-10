// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error InvalidFeeBasePoints();

abstract contract ERC4626Fees is ERC4626 {
    using Math for uint256;

    uint256 private constant _BASE_POINT_SCALE = 1e4;

    address internal _FEE_RECIPIENT;

    uint256 private _FEE_BASE_POUNTS;

    constructor(address feeRecipient, uint256 feeBasisPoints) {
        _FEE_RECIPIENT = feeRecipient;
        _FEE_BASE_POUNTS = feeBasisPoints;
    }

    /**
     * @dev Updates the fee basis points.
     * @param newFeeBasisPoints the new fee baase point.
     */
    function updateFeeBasePoints(uint256 newFeeBasisPoints) external {
        if (newFeeBasisPoints > _BASE_POINT_SCALE || newFeeBasisPoints <= 0) {
            revert InvalidFeeBasePoints();
        }
        _FEE_BASE_POUNTS = newFeeBasisPoints;
    }

    /**
     * Returns the fee basis points.
     */
    function getFeeBasePoints() public view returns (uint256) {
        return _FEE_BASE_POUNTS;
    }

    /**
     * Returns the fee recipient address.
     */
    function getFeeRecipientAddress() public view returns (address) {
        return _FEE_RECIPIENT;
    }

    /**
     * Provides a preview of shares received when depositing `assets` minus entry fees.
     * @param assets the assets(containing fees) that are to be calculated to the equivalent shares.
     * returns the equivalent shares of the `assets`-fees value.
     */
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        return super.previewDeposit(assets - fee);
    }

    /**
     * Provides a preview of assets required to mint `shares` including entry fees.
     * @param shares the shares equivalent of assets without entry fees.
     * returns the equivalent assets including entry fees.
     */
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        uint256 assets = super.previewMint(shares);
        uint256 fee = _feeOnRaw(assets, _entryFeeBasisPoints());
        return assets + fee;
    }

    /**
     * Provides a preview of assets received when redeeming `shares` minus exit fees.
     * @param shares the shares equivalent of assets(net) without entry fees.
     * returns the equivalent assets minus exit fees.
     */
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        uint256 assets = super.previewRedeem(shares);
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        return assets - fee;
    }

    /**
     * Deopsites assset token in excange for shares, collecting entry fees.
     * @param caller initiator of the trabnsaction.
     * @param receiver the one receiving the shares.
     * @param assets amount  assett tokens to be deposited.
     * @param shares the shares to be mined/sent to the receiver.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual override {
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        super._deposit(caller, receiver, assets, shares);
        collectFee(fee);
    }

    /**
     * Withdraws asset tokens in exchange for shares, collecting exit fees.
     * @param caller initiator of the trabnsaction.
     * @param receiver the one receiving the asset tokens.
     * @param owner the owner of the shares.
     * @param assets amount  assett tokens to be withdrawn.
     * @param shares the shares to be burned/sent from the owner.
     */
    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
        virtual
        override
    {
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        super._withdraw(caller, receiver, owner, assets, shares);
        collectFee(fee);
    }

    /**
     * Collects the fee by transferring `fee` amount of assets to the fee recipient.
     * @param fee the amount of fee to be collected.
     */
    function collectFee(uint256 fee) internal {
        if (fee > 0) {
            SafeERC20.safeTransfer(IERC20(asset()), _FEE_RECIPIENT, fee);
        }
    }

    /**
     * Returns the entry fee in basis points applied on deposits.
     */
    function _entryFeeBasisPoints() internal view virtual returns (uint256) {
        return _FEE_BASE_POUNTS;
    }

    /**
     * Calculates the fee on raw `assets`.
     * @param assets the amount of money(assests) that is included in `assets`.
     * @param feeBasisPoints the fee in basis points to be calculated on raw `assets`.
     * returns the fee amount calculated on raw `assets`.
     */
    function _feeOnRaw(uint256 assets, uint256 feeBasisPoints) internal pure returns (uint256) {
        return assets.mulDiv(feeBasisPoints, _BASE_POINT_SCALE, Math.Rounding.Ceil);
    }

    /**
     * Calculates the fee on total `assets`.
     * @param assets the amount of money(assests) that is included in `assets`.
     * @param feeBasisPoints the fee in basis points to be calculated on total `assets`.
     * returns the fee amount calculated on total `assets`.
     */
    function _feeOnTotal(uint256 assets, uint256 feeBasisPoints) internal pure returns (uint256) {
        return assets.mulDiv(feeBasisPoints, feeBasisPoints + _BASE_POINT_SCALE, Math.Rounding.Ceil);
    }
}
