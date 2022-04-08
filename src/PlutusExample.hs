{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module PlutusExample where

import           Control.Monad        hiding (fmap)
import           Data.Aeson           (FromJSON, ToJSON)
import           Data.Map             as Map
import           Data.Text            (Text)
import           Data.Void            (Void)
import           GHC.Generics         (Generic)
import           Plutus.Contract
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..), unless)
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as Scripts
import           Ledger.Ada           as Ada
import           Playground.Contract  (printJson, printSchemas, ensureKnownCurrencies, stage, ToSchema)
import           Playground.TH        (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types     (KnownCurrency (..))
import           Prelude              (IO, Semigroup (..), String, Show)
import           Text.Printf          (printf)

-- Define a general Datum as an example
data MyDatum = MyDatum
    { secretInteger :: Integer
    } deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

-- Define a general Redeemer as an example
data MyRedeemer = MyRedeemer
    { guess :: Integer
    } deriving (Generic, FromJSON, ToJSON, ToSchema)

-- Define some general info that is native and fixed to the plutus script
data ContractInfo = ContractInfo
    { someInteger :: Integer
    } deriving (Generic, FromJSON, ToJSON, ToSchema)

contractInfo :: ContractInfo
contractInfo = ContractInfo 42

-- Lift the datum, redeemer and contract info so that it can be used with
-- template haskell.
PlutusTx.makeIsDataIndexed ''MyDatum [('MyDatum, 0)]
PlutusTx.makeLift ''MyDatum
PlutusTx.makeIsDataIndexed ''MyRedeemer [('MyRedeemer, 0)]
PlutusTx.makeLift ''MyRedeemer
PlutusTx.makeLift ''ContractInfo

-- This is the onchain validator written in haskell. It should at least
-- use a datum redeemer and script context and return a bool.
{-# INLINABLE mkValidator #-}
mkValidator :: ContractInfo -> MyDatum -> MyRedeemer -> ScriptContext -> Bool
mkValidator (ContractInfo i) (MyDatum j) (MyRedeemer k) _ = j == (i * k)

-- Make explicit which types are used for the datum and the redeemer to
-- compile a typed plutus validator script to plutus core.
data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = MyDatum
    type instance RedeemerType Typed = MyRedeemer

-- Create a typed plutus core script from our above defined haskell
-- typed validator. Also we pre-apply the contract info to the plutus
-- validator.
typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
    ($$(PlutusTx.compile [|| mkValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode contractInfo)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @MyDatum @MyRedeemer

-- Convert the script to an onchain validator.
validator :: Validator
validator = Scripts.validatorScript typedValidator

valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator

