{-# LANGUAGE OverloadedStrings #-}
module Main where


--------------------------------------------------------------------------------

import Data.Functor ((<$>))
import Data.List (isPrefixOf)
import Data.Monoid (mappend)
import Data.Text (pack, unpack, replace, empty)

import           System.FilePath (replaceExtension, takeDirectory)
import qualified System.Process  as Process
import qualified Text.Pandoc     as Pandoc

--------------------------------------------------------------------------------

import Hakyll

main :: IO ()
main = hakyll $ do
    -- Build tags
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Compress CSS
    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    -- Copy Files
    match ("favicon.ico" .||. "files/**") $ do
        route   idRoute
        compile copyFileCompiler

    -- Render posts
    match "posts/*" $ do
        route   $ setExtension ".html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" (tagsCtx tags)
            >>= (externalizeUrls $ feedRoot feedConfiguration)
            >>= saveSnapshot "content"
            >>= (unExternalizeUrls $ feedRoot feedConfiguration)
            >>= loadAndApplyTemplate "templates/disqus.html" (tagsCtx tags)
            >>= loadAndApplyTemplate "templates/default.html" (tagsCtx tags)
            >>= relativizeUrls

    -- Render posts list
    create ["posts.html"] $ do
        route idRoute
        compile $ do
            posts <- loadAll "posts/*"
            sorted <- recentFirst posts
            itemTpl <- loadBody "templates/postitem.html"
            list <- applyTemplateList itemTpl postCtx sorted
            let postsCtx =
                    constField "tab_posts" "" `mappend`
                    allPostsCtx
            makeItem list
                >>= loadAndApplyTemplate "templates/posts.html" postsCtx
                >>= loadAndApplyTemplate "templates/default.html" postsCtx
                >>= relativizeUrls

    -- Index
    create ["index.html"] $ do
        route idRoute
        compile $ do
            posts <- loadAll "posts/*"
            sorted <- take 10 <$> recentFirst posts
            itemTpl <- loadBody "templates/postitem.html"
            list <- applyTemplateList itemTpl postCtx sorted
            let indexCtx =
                    constField "tab_index" "" `mappend`
                    (homeCtx tags list)
            makeItem list
                >>= loadAndApplyTemplate "templates/index.html" indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    -- Contact
    create ["contact.html"] $ do
        route idRoute
        compile $ do
            let contactCtx =
                    constField "tab_contact" "" `mappend`
                    constField "title" "Contact" `mappend`
                    defaultContext
            posts <- loadAll "posts/*"
            sorted <- take 10 <$> recentFirst posts
            itemTpl <- loadBody "templates/postitem.html"
            list <- applyTemplateList itemTpl postCtx sorted
            makeItem list
                >>= loadAndApplyTemplate "templates/contact.html" contactCtx
                >>= loadAndApplyTemplate "templates/default.html" contactCtx
                >>= relativizeUrls

    -- CV
    create ["cv.html"] $ do
        route idRoute
        compile $ do
            let cvCtx =
                    constField "tab_cv" "" `mappend`
                    defaultContext
            posts <- loadAll "posts/*"
            sorted <- take 10 <$> recentFirst posts
            itemTpl <- loadBody "templates/postitem.html"
            list <- applyTemplateList itemTpl postCtx sorted
            makeItem list
                >>= loadAndApplyTemplate "templates/cv.html" cvCtx
                >>= loadAndApplyTemplate "templates/default.html" cvCtx
                >>= relativizeUrls

    -- CV as PDF
    match "cv.md" $ version "pdf" $ do
        route   $ setExtension ".pdf"
        compile $ do getResourceBody
            >>= readPandoc
            >>= (return . fmap writeXeTex)
            >>= loadAndApplyTemplate "templates/cv.tex" defaultContext
            >>= xelatex

    -- Post tags
    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged " ++ tag
        route idRoute
        compile $ do
            list <- postList tags pattern recentFirst
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html"
                        (constField "title" title `mappend`
                            constField "body" list `mappend`
                            defaultContext)
                >>= loadAndApplyTemplate "templates/default.html"
                        (constField "title" title `mappend`
                            defaultContext)
                >>= relativizeUrls

    -- Render the 404 page
    match "404.html" $ do
        route idRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext

    -- Read templates
    match "templates/*" $ compile templateCompiler

writeXeTex =
        Pandoc.writeLaTeX Pandoc.def {Pandoc.writerTeXLigatures = False}

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

allPostsCtx :: Context String
allPostsCtx =
    constField "title" "Blog" `mappend`
    postCtx

homeCtx :: Tags -> String -> Context String
homeCtx tags list =
    constField "posts" list `mappend`
    constField "title" "Home" `mappend`
    field "taglist" (\_ -> renderTagList tags) `mappend`
    defaultContext

feedCtx :: Context String
feedCtx =
    bodyField "description" `mappend`
    postCtx

tagsCtx :: Tags -> Context String
tagsCtx tags =
    tagsField "prettytags" tags `mappend`
    postCtx

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Efraim Rodrigues - RSS feed"
    , feedDescription = ""
    , feedAuthorName  = "Efraim Rodrigues"
    , feedAuthorEmail = "efraimnaassom@gmail.com"
    , feedRoot        = "http://erodrigues.xyz"
    }

externalizeUrls :: String -> Item String -> Compiler (Item String)
externalizeUrls root item = return $ fmap (externalizeUrlsWith root) item

externalizeUrlsWith :: String -- ^ Path to the site root
                    -> String -- ^ HTML to externalize
                    -> String -- ^ Resulting HTML
externalizeUrlsWith root = withUrls ext
  where
    ext x = if isExternal x then x else root ++ x


--------------------------------------------------------------------------------
-- | Hacky.
xelatex :: Item String -> Compiler (Item TmpFile)
xelatex item = do
    TmpFile texPath <- newTmpFile "xelatex.tex"
    let tmpDir  = takeDirectory texPath
        pdfPath = replaceExtension texPath "pdf"

    unsafeCompiler $ do
        writeFile texPath $ itemBody item
        _ <- Process.system $ unwords ["xelatex", "-halt-on-error",
            "-output-directory", tmpDir, texPath, ">/dev/null", "2>&1"]
        return ()

    makeItem $ TmpFile pdfPath

--------------------------------------------------------------------------------
unExternalizeUrls :: String -> Item String -> Compiler (Item String)
unExternalizeUrls root item = return $ fmap (unExternalizeUrlsWith root) item

unExternalizeUrlsWith :: String -- ^ Path to the site root
                      -> String -- ^ HTML to unExternalize
                      -> String -- ^ Resulting HTML
unExternalizeUrlsWith root = withUrls unExt
  where
    unExt x = if root `isPrefixOf` x then unpack $ replace (pack root) empty (pack x) else x

postList :: Tags
         -> Pattern
         -> ([Item String] -> Compiler [Item String])
         -> Compiler String
postList tags pattern preprocess' = do
    postItemTpl <- loadBody "templates/postitem.html"
    posts <- loadAll pattern
    processed <- preprocess' posts
    applyTemplateList postItemTpl (tagsCtx tags) processed
