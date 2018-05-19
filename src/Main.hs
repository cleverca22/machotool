{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString as BS
import           Data.List
import           Data.Macho
import           Data.Monoid
import           System.Environment
import           Formatting
import qualified Data.Text.Lazy as LT
import qualified Data.Text.Lazy.IO as LT
import           Data.String (fromString)

main :: IO ()
main = do
  [ executable ] <- getArgs
  rawfile <- BS.readFile executable
  let parsed = parseMacho rawfile
  print $ "load command size: " <> (show $ m_sizeofcmds parsed)
  print "commands:"
  let
    p (LoadCommand (LC_SYMTAB symbols other) size) = do
      print $ "LC_SYMTAB of size: " <> (show size) <> " with " <> (show $ length symbols) <> " symbols"
    p (LoadCommand (LC_SEGMENT_64 segment) size) = do
      print $ "LC_SEGMENT_64 of size: " <> (show size)
      LT.putStrLn $ format ("segment name: " % string % "\nvmaddr: " % hex % "\nvmsize: " % (bytes (fixed 2 % " "))) (seg_segname segment) (seg_vmaddr segment) (seg_vmsize segment)
      mapM_ p2 $ sortOn sec_size (seg_sections segment)
    p v = print v
    p2 sect = do
      LT.putStrLn $ format ("  section name: " % string % "\n  size: " % (bytes (fixed 2 % " "))) (sec_sectname sect) (sec_size sect)
    f (LoadCommand (LC_SEGMENT_64 _) _) = True
    f _ = False
  mapM_ p $ filter f $ sortOn lcSize (m_commands parsed)
