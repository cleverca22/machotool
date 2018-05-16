module Main where

import qualified Data.ByteString as BS
import System.Environment
import Data.Macho
import Data.Monoid

main :: IO ()
main = do
  [ executable ] <- getArgs
  rawfile <- BS.readFile executable
  let parsed = parseMacho rawfile
  print $ "load command size: " <> (show $ m_sizeofcmds parsed)
  print "commands:"
  let
    p (LC_SYMTAB _ _) = print "LC_SYMTAB"
    p v = print v
  mapM_ p $ m_commands parsed
