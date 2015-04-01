{-#LANGUAGE MultiParamTypeClasses #-}
{-#LANGUAGE OverloadedStrings #-}
{-#LANGUAGE ViewPatterns #-}

module Twilio.AuthorizedConnectApp
  ( -- * Resource
    AuthorizedConnectApp(..)
  , ConnectAppSID
  , Twilio.AuthorizedConnectApp.get
  ) where

import Control.Applicative
import Control.Monad
import Data.Aeson
import Data.Maybe
import Data.Time.Clock
import Network.URI

import Control.Monad.Twilio
import Twilio.Internal.Parser
import Twilio.Internal.Request
import Twilio.Internal.Resource as Resource
import Twilio.Types

{- Resource -}

data AuthorizedConnectApp = AuthorizedConnectApp
  { dateCreated  :: !UTCTime
  , dateUpdated  :: !UTCTime
  , accountSID   :: !AccountSID
--  , permissions  :: !Permissions
  , sid          :: !ConnectAppSID
  , friendlyName :: !String
  , description  :: !String
  , companyName  :: !String
  , homepageURL  :: !(Maybe URI)
  , uri          :: !URI
  } deriving (Show, Eq)

instance FromJSON AuthorizedConnectApp where
  parseJSON (Object v) = AuthorizedConnectApp
    <$> (v .: "date_created" >>= parseDateTime)
    <*> (v .: "date_updated" >>= parseDateTime)
    <*>  v .: "account_sid"
--    <*>  v .: "permissions"
    <*>  v .: "connect_app_sid"
    <*>  v .: "connect_app_friendly_name"
    <*>  v .: "connect_app_description"
    <*>  v .: "connect_app_company_name"
    <*> (v .: "connect_app_homepage_url" <&> fmap filterEmpty
                                         <&> fmap (fmap parseURI)
                                         >>= maybeReturn'')
    <*> (v .: "uri"                      <&> parseRelativeReference
                                         >>= maybeReturn)
  parseJSON _ = mzero

instance Get1 ConnectAppSID AuthorizedConnectApp where
  get1 (getSID -> sid) = request (fromJust . parseJSONFromResponse) =<< makeTwilioRequest
    ("/AuthorizedConnectApps/" ++ sid ++ ".json")

-- | Get an 'AuthorizedConnectApp' by 'ConnectAppSID'.
get :: Monad m => ConnectAppSID -> TwilioT m AuthorizedConnectApp
get = Resource.get
