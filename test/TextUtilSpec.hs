-- ------ language="Haskell" file="test/TextUtilSpec.hs"
module TextUtilSpec where

-- ------ begin <<import-text>>[0]
import qualified Data.Text as T
import Data.Text (Text)
-- ------ end
import Data.Maybe (catMaybes, isJust)
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Instances.Text

import TextUtil

propUnlines :: Maybe Text -> Bool
propUnlines t = 
    -- ------ begin <<test-unlines-inverse>>[0]
    t == mUnlines (mLines t)
    -- ------ end

propUnlineLists :: ([Text], [Text]) -> Bool
propUnlineLists (a, b) =
    -- ------ begin <<test-unlines-associative>>[0]
    mUnlines (catMaybes [mUnlines a, mUnlines b]) == mUnlines (a <> b)
    -- ------ end

genLine :: Gen Text
genLine = T.pack <$> (listOf $ elements ['!'..'~'])

genText :: Gen Text
genText = unlines' <$> listOf genLine

genPair :: Gen a -> Gen b -> Gen (a, b)
genPair x y = do
    i <- x
    j <- y
    return (i, j)

propIndent :: (Text, Text) -> Bool
propIndent (a, b) = unindent a (indent a b) == Just b

propUnindentFail :: (Text, Text) -> Bool
propUnindentFail (a, b) = (isJust $ unindent a b) == a `T.isPrefixOf` b

textUtilSpec :: Spec
textUtilSpec = do
    describe "property check" $ do
        it "mUnlines inverses mLines" $
            property $ propUnlines
        it "mUnlines can be nested (associativity)" $
            property $ propUnlineLists
        it "unindent inverts indent" $
            property $ forAll (genPair genLine genText)  propIndent
        it "unindent fails on wrong indent" $
            property $ forAll (genPair genLine genLine) propIndent
-- ------ end
